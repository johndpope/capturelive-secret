//
//  JobHistoryViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/31/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

extension JobHistoryViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return { [unowned self] in
            self.performSegueWithIdentifier(self.segue.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if segue == .ShowSideNav {
            return AddSideNavAnimator()
        }
        return nil
    }
}

class JobHistoryViewController: UIViewController, SegueHandlerType, RemoteAndLocallyServiceable, NavGesturable, SideNavPopable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var segue: SegueIdentifier              = SegueIdentifier.ShowSideNav
    var selectedEvent: Event?               = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    enum SegueIdentifier:String {
        case ShowSideNav                    = "showSideNav"
        case ShowCompletedEvent             = "showCompletedEvent"
    }
    
    var refreshControl: UIRefreshControl!
    
    var theView:JobHistoryView {
        guard let v = self.view as? JobHistoryView else { fatalError("Not a JobHistoryView!") }
        return v
    }
    
    private typealias Data = FetchedResultsDataViewModelProvider<JobHistoryViewController, Event>
    private var dataSource: TableViewDataSource<JobHistoryViewController, Data, EndedJobTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false

        refreshControl                      = UIRefreshControl()
        refreshControl.attributedTitle      = NSAttributedString(string: "Pull to refresh")
        theView.tableView?.insertSubview(refreshControl, atIndex: 0)
        
        self.theView.didLoad()
        createDataProviders()
    }
    
    func createDataProviders() {
        let request                         = NSFetchRequest(entityName: Event.entityName)
        request.predicate                   = Event.contractIsHistoryPredicate
        request.returnsObjectsAsFaults      = false
        request.fetchBatchSize              = 50
        request.sortDescriptors             = [NSSortDescriptor(key:"startTime", ascending:false)]
        
        let frc                             = NSFetchedResultsController(
            fetchRequest:request
            ,managedObjectContext:managedObjectContext
            ,sectionNameKeyPath:nil
            ,cacheName:nil
        )
        dataProvider                        = FetchedResultsDataViewModelProvider(fetchedResultsController:frc, delegate:self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self

        if dataProvider.numRecordsForRequest() == 0 {
            theView.zeroStateView?.animateIn()
        } else {
            theView.zeroStateView?.animateOut()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
        segue                               = .ShowSideNav
        navGesturer?.usePushLeftPopRightGestureRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    @IBAction func unwindFromCancelledModal(sender:UIStoryboardSegue) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    //MARK: Navigation
    func updateUI() {
        refreshControl.endRefreshing()
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(handleNewEvents(_:)), name: CoordinaterDidFetchNewRemoteDataNotification, object: nil)
        theView.backButton?.addTarget(self, action:#selector(showSideNav), forControlEvents:.TouchUpInside)
        refreshControl.addTarget(self, action:#selector(refresh(_:)), forControlEvents:.ValueChanged)
    }
    
    func removeEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:CoordinaterDidFetchNewRemoteDataNotification, object:nil)
        theView.backButton?.removeTarget(self, action:#selector(showSideNav), forControlEvents:.TouchUpInside)
        refreshControl.removeTarget(self, action:#selector(refresh(_:)), forControlEvents:.ValueChanged)
    }
    
    // MARK: API
    func fetchNewEvents() {
        NSNotificationCenter.defaultCenter().postNotificationName(CaptureRequestsFetchRemoteDataNotification, object: nil, userInfo: nil)
    }
    
    // MARK: Buttons
    func showSideNav() {
        segue = .ShowSideNav
        performSeguePush()
    }
    
    func refresh(sender:AnyObject) {
        fetchNewEvents()
    }
   
    
    //MARK: Notification
    func handleNewEvents(notification:NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.updateUI()
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
        
        if let event = selectedEvent {
            switch segueIdentifierForSegue(segue) {
            case .ShowCompletedEvent:
                guard let vc = segue.destinationViewController as? CompletedJobViewController else { fatalError("Wrong view controller type") }
                vc.event = event
            default: break
            }
            selectedEvent = nil
        }
    }
        
}

extension JobHistoryViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EndedJobTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        theView.tableView?.deselectRowAtIndexPath(indexPath, animated:false)
        let eventModel          = dataProvider.objectAtIndexPath(indexPath)
        selectedEvent           = Event.fetchInContext(managedObjectContext) { request in
            request.predicate   = NSPredicate(format:"%K == %@", RemoteComparableKeys.UrlHash.rawValue, eventModel.urlHash)
        }.first
        segue                   = .ShowCompletedEvent
        performSegue(segue)
    }
    
}

extension JobHistoryViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<EventTableCellViewModel>]?) {
        dataSource.processUpdates(updates)
    }
}

extension JobHistoryViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:EventTableCellViewModel) -> String {
        return EndedJobTableViewCell.Identifier
    }
}
