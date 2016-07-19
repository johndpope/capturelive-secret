//
//  RemoteUserUpdater.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import CoreData
import CaptureModel

final class RemoteUserDownloader : ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<User>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects:[User], context:ChangeProcessorContextType) {
        processChangedUser(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        context.remote.fetchLoggedInUser { [unowned self] remoteUser, error in
            if let _ = error {
                completion()
                return
            }
            guard let user = remoteUser else {
                completion()
                return
            }
            self.updateRemoteUser(user, inContext:context.managedObjectContext)
            context.delayedSaveOrRollback()
            completion()
        }
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return User.markedForNeedsPaypalEmailPredicate
    }
    
}

extension RemoteUserDownloader {
    
    private func updateRemoteUser(remoteUser:RemoteUser, inContext moc:NSManagedObjectContext) {
        remoteUser.insertIntoContext(moc)
    }
    
    func processChangedUser(changes: [User], context: ChangeProcessorContextType) {
        guard let user = changes.first else {
            return
        }
        context.remote.fetchLoggedInUser { [unowned self] remoteUser, error in
            if let _ = error {
                self.elementsInProgress.markObjectsAsComplete([user])
                return
            }
            guard let rUser = remoteUser else {
                self.elementsInProgress.markObjectsAsComplete([user])
                return
            }
            context.performGroupedBlock({ [unowned self] in
                rUser.mapTo(user)
                if User.hasPaypalEmailPredicate.evaluateWithObject(user) {
                    user.markAsPaypalEmailVerified()
                    context.delayedSaveOrRollback()
                }
                self.elementsInProgress.markObjectsAsComplete([user])
            })
        }
    }
    
}