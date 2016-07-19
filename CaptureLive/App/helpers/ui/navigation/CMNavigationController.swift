//
//  CMHomeNavigationController.swift
//  Current
//
//  Created by Scott Jones on 1/20/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureModel
import CaptureCore
import CaptureUI
import CaptureSync

protocol NavGesturable {
    var navGesturer:CMNavigationController? { get }
}
extension NavGesturable where Self:UIViewController {
    var navGesturer:CMNavigationController? {
        return navigationController as? CMNavigationController
    }
}

class CMNavigationController: UINavigationController, SegueHandlerType {
    
    var navAnimationManager:NavigationAnimatable!
    var gestureRecognizer:GestureNavigatorRecognizer?
    var statusBarStyle:UIStatusBarStyle {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        statusBarStyle                      = .LightContent
        super.init(coder: aDecoder)
        navAnimationManager                 = NavigationStackAnimator(nav:self)
    }
    
    func removeGestureRecognizers() {
        gestureRecognizer?.untie()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func usePushLeftPopRightGestureRecognizer() {
        self.removeGestureRecognizers()
        self.gestureRecognizer              = GestureNavigatorRecognizer.SwipeRightNavigatorRecognizer(navAnimationManager)
    }
    
    func usePushRightPopLeftGestureRecognizer() {
        self.removeGestureRecognizers()
        self.gestureRecognizer              = GestureNavigatorRecognizer.SwipeLeftNavigatorRecognizer(navAnimationManager)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disable() {
        self.navAnimationManager?.disable()
    }
    
    func enable() {
        self.navAnimationManager?.enable()
    }
    
    func denyGestures() {
        self.gestureRecognizer?.denyGestures()
    }
    
    func acceptGestures() {
        self.gestureRecognizer?.acceptGestures()
    }
  
    enum SegueIdentifier:String {
        case UnwindFromHiredModal               = "unwindFromHiredModal"
        case UnwindFromReminder1HourModal       = "unwindFromReminder1HourModal"
        case UnwindFromReminder24HoursModal     = "unwindFromReminder24HoursModal"
        case UnwindFromStream                   = "unwindFromStream"
        case UnwindFromCancelledModal           = "unwindFromCancelledModal"
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
        
        guard let key = identifier else {
            return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
        }
        switch segueForIdentifier(key) {
        case .UnwindFromHiredModal:
            return HiredModalUnwindSegue(identifier:key, source:fromViewController, destination:toViewController)
        case .UnwindFromReminder1HourModal:
            return ReminderModal1HourUnwindSegue(identifier:key, source:fromViewController, destination:toViewController)
        case .UnwindFromReminder24HoursModal:
            return ReminderModal24HoursUnwindSegue(identifier:key, source:fromViewController, destination:toViewController)
        case .UnwindFromCancelledModal:
            return CancelModalUnwindSegue(identifier:key, source:fromViewController, destination:toViewController)
        case .UnwindFromStream:
            return CMUnwindLiveStreamSegue(identifier:key, source:fromViewController, destination:toViewController)
        }
    }
   
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
    
}

extension CMNavigationController {

    func showHiredModal(note:Notification) {
        guard let _ = note.contractSource else { return }
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(ModalHiredViewController.self) {
                return
            }
        }
        
        let hiredModal                      = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("ModalHiredViewController") as! ModalHiredViewController
        hiredModal.notification             = note
        hiredModal.managedObjectContext     = appDelegate?.managedObjectContext
        hiredModal.remoteService            = appDelegate?.apiService
      
        presentViewController(hiredModal, animated: true, completion: nil)
    }
    
    func show1HourReminderModal(note:Notification) {
        guard let _ = note.contractSource else { return }
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(ModalReminder1HourViewController.self) {
                return
            }
        }
        
        let reminderModal                   = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("ModalReminder1HourViewController") as! ModalReminder1HourViewController
        reminderModal.notification          = note
        reminderModal.managedObjectContext  = appDelegate?.managedObjectContext
        reminderModal.remoteService         = appDelegate?.apiService
        
        presentViewController(reminderModal, animated: true, completion: nil)
    }
    
    func show24HourReminderModal(note:Notification) {
        guard let _ = note.contractSource else { return }
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(ModalReminder24HoursViewController.self) {
                return
            }
        }
        
        let reminderModal                   = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("ModalReminder24HoursViewController") as! ModalReminder24HoursViewController
        reminderModal.notification          = note
        reminderModal.managedObjectContext  = appDelegate?.managedObjectContext
        reminderModal.remoteService         = appDelegate?.apiService
        
        presentViewController(reminderModal, animated: true, completion: nil)
    }
    
    func showCancelledModal(note:Notification) {
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(ModalCancelledViewController.self) {
                return
            }
        }
 
        let cancelledModal                  = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("ModalCancelledViewController") as! ModalCancelledViewController
        cancelledModal.notification         = note
        cancelledModal.managedObjectContext = appDelegate?.managedObjectContext
        cancelledModal.remoteService        = appDelegate?.apiService
       
        presentViewController(cancelledModal, animated: true, completion: nil)
    }
    
    func showNewestEvents() {
        
    }
    
    func showEventDetail(contract c:Contract?) {
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(EventDetailViewController.self) {
                return
            }
        }
        
        guard let contract                  = c else { return }
        let eventsList                      = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("EventsListViewController") as! EventsListViewController
        eventsList.managedObjectContext     = appDelegate?.managedObjectContext
        eventsList.remoteService            = appDelegate?.apiService

        let eventDetail                     = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        eventDetail.managedObjectContext    = appDelegate?.managedObjectContext
        eventDetail.remoteService           = appDelegate?.apiService
        eventDetail.contract                = contract
        eventDetail.event                   = contract.event

        appDelegate!.navigationController.viewControllers = [eventsList, eventDetail]
    }
   
    func showOnTheJob(contract c:Contract?) {
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(OnTheJobViewController.self) {
                return
            }
        }
        
        guard let contract                  = c else { return }
        let eventsList                      = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("EventsListViewController") as! EventsListViewController
        eventsList.managedObjectContext     = appDelegate?.managedObjectContext
        eventsList.remoteService            = appDelegate?.apiService
        
        let onJobScreen                     = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("OnTheJobViewController") as! OnTheJobViewController
        onJobScreen.managedObjectContext    = appDelegate?.managedObjectContext
        onJobScreen.remoteService           = appDelegate?.apiService
        onJobScreen.contract                = contract
        onJobScreen.event                   = contract.event
        
        appDelegate!.navigationController.viewControllers = [eventsList, onJobScreen]
    }
    
    func showContractCompletedReceipt(contract c:Contract?) {
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(JobReceiptViewController.self) {
                return
            }
        }
        
        guard let contract                  = c else { return }
        let receiptScreen                   = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("JobReceiptViewController") as! JobReceiptViewController
        receiptScreen.managedObjectContext  = appDelegate?.managedObjectContext
        receiptScreen.remoteService         = appDelegate?.apiService
        receiptScreen.event                 = contract.event
        
        appDelegate!.navigationController.viewControllers = [receiptScreen]
    }
    
    func showContractHistoryReceipt(contract c:Contract?) {
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.navigationController.visibleViewController {
            if vc.isKindOfClass(CompletedJobViewController.self) {
                return
            }
        }
        
        guard let contract                  = c else { return }
        let historyList                     = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("JobHistoryViewController") as! JobHistoryViewController
        historyList.managedObjectContext    = appDelegate?.managedObjectContext
        historyList.remoteService           = appDelegate?.apiService
        
        let completedJobScreen              = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("CompletedJobViewController") as! CompletedJobViewController
        completedJobScreen.managedObjectContext = appDelegate?.managedObjectContext
        completedJobScreen.remoteService    = appDelegate?.apiService
        completedJobScreen.event            = contract.event
        
        appDelegate!.navigationController.viewControllers = [historyList, completedJobScreen]
    }
    
}



























