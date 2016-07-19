//
//  CMEventsListViewController.swift
//  Current
//
//  Created by Scott Jones on 2/23/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

extension EventsListViewController : CYNavigationPush {
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

class EventsListViewController: UIViewController, SegueHandlerType, RemoteAndLocallyServiceable, NavGesturable, SideNavPopable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var segue: SegueIdentifier              = SegueIdentifier.ShowSideNav
    var selectedEvent: Event?      = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    enum SegueIdentifier:String {
        case ShowSideNav                    = "showSideNav"
        case ShowEventDetail                = "showEventDetailUnaccepted"
        case ShowEventDetailOnTheJob        = "showEventDetailOnTheJob"
    }

    var theView:EventsListView {
        guard let v = self.view as? EventsListView else { fatalError("Not a EventsListView!") }
        return v
    }
    
    var refreshControl: UIRefreshControl!
    var frc: NSFetchedResultsController!
    
    private typealias Data = FetchedResultsDataViewModelProvider<EventsListViewController, Event>
    private var dataSource: TableViewDataSource<EventsListViewController, Data, EventTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        theView.didLoad()
       
        refreshControl                      = UIRefreshControl()
        refreshControl.attributedTitle      = NSAttributedString(string:"Pull to refresh")
        theView.tableView?.insertSubview(refreshControl, atIndex: 0)
        
        gatherData()
    }
    
    func gatherData() {
        if let _ = Contract.fetchActiveContract(managedObjectContext)  {
            hiredSelectedNoAnimate()
        } else {
            availableSelectedNoAnimate()
        }
    }
    
    func updateDataSource() {
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self
        
        if dataProvider.numRecordsForRequest() == 0 {
            theView.zeroStateView?.animateIn()
        } else {
            theView.zeroStateView?.animateOut()
        }
    }

    func useUnhiredDataSource() {
        let request                         = NSFetchRequest(entityName: Event.entityName)
        request.predicate                   = Event.notExpiredAndAppliedOrUnappliedPredicate
        request.returnsObjectsAsFaults      = false
        request.fetchBatchSize              = 100
        
        let compareContract                 = NSSortDescriptor(key:"contract", ascending: false, selector: #selector(Contract.compare(_:)))
        let startTimeContract               = NSSortDescriptor(key:"startTime", ascending:false)
        request.sortDescriptors             = [compareContract, startTimeContract]

        frc                                 = NSFetchedResultsController(
            fetchRequest:request
            ,managedObjectContext:managedObjectContext
            ,sectionNameKeyPath:nil
            ,cacheName:"unhired_cache"
        )
        dataProvider                        = FetchedResultsDataViewModelProvider(fetchedResultsController:frc, delegate:self)
        updateDataSource()
    }
    
    func useHiredDataSource() {
        let request                         = NSFetchRequest(entityName: Event.entityName)
        request.predicate                   = Event.contractIsOpenAndAcquiredPredicate
        request.sortDescriptors             = [NSSortDescriptor(key:"startTime", ascending:true)]
        request.returnsObjectsAsFaults      = false
        request.fetchBatchSize              = 100
 
        frc                                 = NSFetchedResultsController(
             fetchRequest:request
            ,managedObjectContext:managedObjectContext
            ,sectionNameKeyPath:nil
            ,cacheName:"hired_cache"
        )
        dataProvider                        = FetchedResultsDataViewModelProvider(fetchedResultsController:frc, delegate:self)
        updateDataSource()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
//        gatherData()
        segue = .ShowSideNav
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @IBAction func unwindFromHiredModal(segue:UIStoryboardSegue) {}
    @IBAction func unwindFromReminder1HourModal(segue:UIStoryboardSegue) {}
    @IBAction func unwindFromReminder24HoursModal(segue:UIStoryboardSegue) {}
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(handleNewEvents(_:)), name: CoordinaterDidFetchNewRemoteDataNotification, object: nil)
        theView.backButton?.addTarget(self, action:#selector(showSideNav), forControlEvents:.TouchUpInside)
        theView.availableButton?.addTarget(self, action: #selector(availableSelected), forControlEvents: .TouchUpInside)
        theView.hiredButton?.addTarget(self, action: #selector(hiredSelected), forControlEvents: .TouchUpInside)
        refreshControl.addTarget(self, action:#selector(refresh(_:)), forControlEvents:.ValueChanged)
    }
    
    func removeEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:CoordinaterDidFetchNewRemoteDataNotification, object:nil)
        theView.backButton?.removeTarget(self, action:#selector(showSideNav), forControlEvents:.TouchUpInside)
        theView.availableButton?.removeTarget(self, action: #selector(availableSelected), forControlEvents: .TouchUpInside)
        theView.hiredButton?.removeTarget(self, action: #selector(hiredSelected), forControlEvents: .TouchUpInside)
        refreshControl.removeTarget(self, action:#selector(refresh(_:)), forControlEvents:.ValueChanged)
    }
    
    // MARK: API
    func fetchNewEvents() {
        NSNotificationCenter.defaultCenter().postNotificationName(CaptureRequestsFetchRemoteDataNotification, object: nil, userInfo: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
        
        if let event = selectedEvent {
            switch segueIdentifierForSegue(segue) {
            case .ShowEventDetail:
                guard let vc = segue.destinationViewController as? EventDetailViewController else { fatalError("Wrong view controller type") }
                vc.event = event
                vc.contract = event.contract
            case .ShowEventDetailOnTheJob:
                guard let vc = segue.destinationViewController as? OnTheJobViewController else { fatalError("Wrong view controller type") }
                vc.event = event
                vc.contract = event.contract
            default: break
            }
            selectedEvent = nil
        }
    }
    
    
    //MARK: Button handles
    func showSideNav() {
        segue = .ShowSideNav
        performSeguePush()
    }
    
    func pushToSettings() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func refresh(sender:AnyObject) {
        fetchNewEvents()
    }

    func availableSelected() {
        theView.animateAvailableSelected()
        useUnhiredDataSource()
    }
    
    func hiredSelected() {
        theView.animateHiredSelected()
        useHiredDataSource()
    }
    
    func availableSelectedNoAnimate() {
        theView.noAnimateAvailableSelected()
        useUnhiredDataSource()
    }
    
    func hiredSelectedNoAnimate() {
        theView.noAnimateHiredSelected()
        useHiredDataSource()
    }
    
    //MARK: Notification
    func handleNewEvents(notification:NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

}

extension EventsListViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        theView.tableView?.deselectRowAtIndexPath(indexPath, animated:false)
        let eventModel          = dataProvider.objectAtIndexPath(indexPath)
        selectedEvent           = Event.fetchInContext(managedObjectContext) { request in
            request.predicate = NSPredicate(format:"%K == %@", RemoteComparableKeys.UrlHash.rawValue, eventModel.urlHash)
        }.first
        guard let event = selectedEvent else { fatalError("The event does not exist") }
        
        switch event.contractStatus {
        case .ACQUIRED:
            guard let contract  = event.contract else { fatalError("The contract does not exist") }
            if contract.started || event.isPastCameraAccessTime {
                self.segue      = .ShowEventDetailOnTheJob
            } else {
                self.segue      = .ShowEventDetail
            }
        case .APPLIED, .EXPIRED, .NONE:
            self.segue          = .ShowEventDetail
        }
        self.performSegue(self.segue)
    }
    
}

extension EventsListViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<EventTableCellViewModel>]?) {
        print(updates)
        dataSource.processUpdates(updates)
    }
}

extension EventsListViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:EventTableCellViewModel) -> String {
        return EventTableViewCell.Identifier
    }
}