//
//  NotificationDownloader.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

final class NotificationDownloader : ChangeProcessorType {
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        context.remote.fetchLatestRemoteNotifications { remoteNotifications in
            context.performGroupedBlock {
                self.insertRemoteNotifications(remoteNotifications, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
                completion()
            }
        }
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        context.remote.fetchLatestRemoteNotifications { remoteNotifications in
            context.performGroupedBlock {
                self.insertRemoteNotifications(remoteNotifications, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
            }
        }
    }
    
    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        return nil
    }
    
}

extension NotificationDownloader {
    
    private func insertRemoteNotifications(remoteNotifications:[RemoteNotification], inContext moc:NSManagedObjectContext) {
        for notification in remoteNotifications {
            notification.insertIntoContext(moc)
        }
    }
    
}

