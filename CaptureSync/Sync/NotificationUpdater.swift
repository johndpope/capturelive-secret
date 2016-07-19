//
//  NotificationUpdater.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel

final class NotificationUpdater : ElementChangeProcessorType {
    var elementsInProgress = InProgressTracker<Notification>()

    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }

    func processChangedLocalElements(objects: [Notification], context: ChangeProcessorContextType) {
        processNewNotifications(objects, context:context)
    }

    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }

    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }

    var predicateForLocallyTrackedElements:NSPredicate {
        return Notification.markedForRemoteVerificationPredicate
    }
}


extension NotificationUpdater {

    func processNewNotifications(notifications:[Notification], context:ChangeProcessorContextType) {
        guard let notification = notifications.first else {
            return
        }
        context.remote.updateRemoteNotification(notification, completion: context.performGroupedBlock { [unowned self] error in
            if let _ = error {
                self.elementsInProgress.markObjectsAsComplete([notification])
            } else {
                notification.unMarkForNeedsRemoteVerification()
                context.delayedSaveOrRollback()
                self.elementsInProgress.markObjectsAsComplete([notification])
            }
        })
    }

}