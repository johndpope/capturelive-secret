//
//  JobReceiptViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

class JobReceiptViewController: UIViewController, RemoteAndLocallyServiceable, SegueHandlerType  {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    var theView:JobReceiptView {
        guard let v = self.view as? JobReceiptView else { fatalError("Not a JobReceiptView!") }
        return v
    }
   
    enum SegueIdentifier:String {
        case PushToCompletedJob             = "pushCompletedJob"
    }
    
    var event:Event!
   
    private typealias Data = DefaultDataProvider<JobReceiptViewController>
    private var dataSource: TableViewDataSource<JobReceiptViewController, Data, JobReceiptTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        theView.didLoad()
        guard let contract = event.contract else {
            fatalError("event has not contract!")
        }
        theView.populate(event.tableCellViewModel(), attachments:contract.uploadedAttachmentCollectionModels.reverse())
        
        dataProvider                        = DefaultDataProvider(items:contract.descriptionStrings, delegate :self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        managedObjectContext.performChanges { [unowned self] in
            self.event.contract?.markNotificationAsRead(.Hired)
            self.event.contract?.markNotificationAsRead(.JobStartsIn24Hours)
            self.event.contract?.markNotificationAsRead(.JobStartsIn1Hour)
            self.event.contract?.markNotificationAsRead(.Arrived)
            self.event.contract?.markNotificationAsRead(.JobCompleted)
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        theView.jobSummaryButton?.addTarget(self, action:#selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.jobSummaryButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        performSegue(.PushToCompletedJob)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    
        switch segueIdentifierForSegue(segue) {
        case .PushToCompletedJob:
            guard let completedVC = segue.destinationViewController as? CompletedJobViewController else { fatalError("Wrong view controller type") }
            completedVC.event         = event
        }
    }

}

extension JobReceiptViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return JobReceiptTableViewCellHeight
    }
    
}

extension JobReceiptViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<String>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension JobReceiptViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:String) -> String {
        return JobReceiptTableViewCell.Identifier
    }
}
