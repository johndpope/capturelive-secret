//
//  CMAppNavigationViewController.swift
//  Current
//
//  Created by hatebyte on 7/17/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

//class NotificationModalModel: NSObject {
//    
//    let managedObjectContext:NSManagedObjectContext!
//    init(managedObjectContext:NSManagedObjectContext) {
//        self.managedObjectContext = managedObjectContext
//    }
//
//}

class NotificationManager: NSObject {
    
    weak var navigationController:CMNavigationController!
    let managedObjectContext:NSManagedObjectContext!
    var infoControlCenter:[NSObject:AnyObject]? = nil
    
    init(navigationController:CMNavigationController, managedObjectContext:NSManagedObjectContext) {
        self.navigationController   = navigationController
        self.managedObjectContext   = managedObjectContext
        super.init()
    }
    
    func checkForNotifiables() {
        guard let lastVC = navigationController.viewControllers.last else { return }
        if lastVC.isKindOfClass(LiveStreamViewController) { return }

        let numUnreadNotifcations   = Notification.fetchTotalNumberOfUnread(managedObjectContext)
        if numUnreadNotifcations > 0 {
            // it was notification tapped from control center or banner
            if let info = managedObjectContext.cachedNotificationUserInfo() {
                guard let urlHash       = info["payload_object_url_hash"] as? String else { return }
                guard let type          = info["type"] as? Int else { return }
                guard let pushType      = NotificationType(rawValue: UInt16(type)) else { return }
                
                let hiredNotePredicate  = Notification.predicateForNotificationWith(pushType, contractSourceUrlHash:urlHash)
                guard let tappedNote = Notification.findOrFetchInContext(managedObjectContext, matchingPredicate: hiredNotePredicate) else { return }
                launchedWith(tappedNote)
            }
            // any other unread notification
            else {
                if let activeContract = Contract.fetchActiveContract(managedObjectContext)  {
                    guard let lastNote = activeContract.mostRecentUnreadNotification(favoringFirst: .Hired) else { return }
                    addressInAppWithModal(lastNote)
                } else {
                    guard let lastNote = Notification.fetchFirstUnread(managedObjectContext) else { return }
                    addressInAppWithModal(lastNote)
                }
            }
        }
    }
    
    func addressInAppWithModal(note:Notification) {
        switch note.pushType {
        case .Hired:
            navigationController.showHiredModal(note)
        case .JobStartsIn1Hour:
            navigationController.show1HourReminderModal(note)
        case .Canceled:
            navigationController.showCancelledModal(note)
        default: break
        }
    }
   
    func launchedWith(note:Notification) {
        switch note.pushType {
        case .NewJobs:
            navigationController.showNewestEvents()
        case .BreakingJob:
            break
        case .JobStartsIn24Hours:
            navigationController.showEventDetail(contract: note.contractSource)
        case .Arrived:
            navigationController.showOnTheJob(contract: note.contractSource)
        case .JobCompleted:
            navigationController.showContractCompletedReceipt(contract: note.contractSource)
        case .PaymenUnderReview:
            navigationController.showContractHistoryReceipt(contract: note.contractSource)
        case .PaymentDenied:
            navigationController.showContractHistoryReceipt(contract: note.contractSource)
        case .PaymentAvailable:
            navigationController.showContractHistoryReceipt(contract: note.contractSource)
        case .Hired:
            navigationController.showHiredModal(note)
        case .JobStartsIn1Hour:
            navigationController.show1HourReminderModal(note)
        case .Canceled:
            navigationController.showCancelledModal(note)
        }
    }
    
}

















