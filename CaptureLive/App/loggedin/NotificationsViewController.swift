//
//  NotificationsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

extension NotificationsViewController : CYNavigationPush {
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

class NotificationsViewController: UIViewController, SegueHandlerType, SideNavPopable, NavGesturable, RemoteAndLocallyServiceable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var segue:SegueIdentifier       = SegueIdentifier.ShowSideNav
   
//    private typealias Data = DefaultDataProvider<NotificationsViewController>
//    private var dataSource:TableViewDataSource<NotificationsViewController, Data, NotificationTableCell>!
//    private var dataProvider: Data!
    
    enum SegueIdentifier:String {
        case ShowSideNav                        = "showSideNav"
        case ShowEventDetailOnTheJob            = "showEventDetailOnTheJob"
        case ShowEventDetail                    = "showEventDetail"
        case ShowJobReceipt                     = "showJobReceipt"
        case ShowCompletedJob                   = "showCompletedJob"
        case ShowPublisherCancelledJob          = "showPublisherCancelledJob"
//        case ReminderModalSegue                 = "reminderModalSegue"
//        case ArrivedModalSegue                  = "arrivedModalSegue"
    }
    
    var theView:NotificationsView {
        guard let v = self.view as? NotificationsView else { fatalError("Not a NotificationsView!") }
        return v
    }
    
    var tableSource:NotificationTableSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        theView.didLoad()
        
        tableSource = NotificationTableSource(tableView:theView.tableView!, moc:managedObjectContext, notificatioDelegate: self)
        tableSource.fetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segue = .ShowSideNav
        addHandlers()
        tableSource.fetch()
        managedObjectContext.performChanges { [unowned self] in
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navGesturer?.usePushLeftPopRightGestureRecognizer()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func addHandlers() {
        removeHandlers()
        theView.backButton?.addTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
        if segueIdentifierForSegue(segue) == .ShowSideNav {
            return
        }
        guard let indexPath = theView.tableView?.indexPathForSelectedRow else { fatalError("Tableview has not indexPath selected") }
        let event                                       = tableSource.events[indexPath.row]
        guard let contract = event.contract else { fatalError("Event for bossVC has no contract!") }
 
        switch segueIdentifierForSegue(segue) {
        case .ShowEventDetailOnTheJob:
            guard let bossVC                            = vc as? OnTheJobViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to OnTheJobViewController") }
            bossVC.event                                = event
            bossVC.contract                             = contract
        case .ShowEventDetail:
            guard let gtjVC                           = vc as? EventDetailViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to EventDetailViewController") }
            gtjVC.event                               = event
            gtjVC.contract                            = contract
        case .ShowCompletedJob:
            guard let gtjVC                           = vc as? CompletedJobViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to CompletedJobViewController") }
            gtjVC.event                               = event
        case .ShowJobReceipt:
            guard let jrVC                           = vc as? JobReceiptViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to JobReceiptViewController") }
            jrVC.event                               = event
        case .ShowPublisherCancelledJob:
            guard let cancelVC                           = vc as? ModalCancelledViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to ModalCancelledViewController") }
            guard let cancelledNote = event.notification(.Canceled) else {
                fatalError("The cancelled notification does not exist even though you clicked on it!")
            }
            cancelVC.notification                     = cancelledNote
        default: break
        }
    }

    //MARK: Button handlers
    func showSideNav() {
        segue = .ShowSideNav
        performSeguePush()
    }

}

extension NotificationsViewController : NotificationTableProtocol {

    func didSelectEvent(event:Event) {
        guard let contract = event.contract else { fatalError("Event has no contract!") }
        if contract.acquired == true {
            guard let note = event.mostRecentNotification else { fatalError("Event has no recent notification") }
           
            switch note.pushType {
                case .NewJobs, .BreakingJob:
                    break
                case .Hired,
                     .JobStartsIn1Hour,
                     .JobStartsIn24Hours:
                    if event.isPastCameraAccessTime {
                        self.segue  = .ShowEventDetailOnTheJob
                    } else {
                        self.segue  = .ShowEventDetail
                    }
                case .Arrived:
                    self.segue      = .ShowEventDetailOnTheJob
                case .JobCompleted:
                    self.segue      = .ShowJobReceipt
                case .PaymenUnderReview,
                     .PaymentDenied,
                     .PaymentAvailable:
                    self.segue      = .ShowCompletedJob
                case .Canceled:
                    self.segue      = .ShowPublisherCancelledJob
            }
            performSeguePush()
        } else {
            guard let indexPath = theView.tableView?.indexPathForSelectedRow else { return }
            theView.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
}










