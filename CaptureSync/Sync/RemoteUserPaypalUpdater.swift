//
//  RemoteUserPaypalUpdater.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel

final class RemoteUserPaypalUpdater: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<User>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [User], context: ChangeProcessorContextType) {
        processChangedUsers(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return User.markedForNeedsPaypalVerificationPredicate
    }
    
}

extension RemoteUserPaypalUpdater {
    
    func processChangedUsers(changes: [User], context: ChangeProcessorContextType) {
        guard let user = changes.first else {
            return
        }
        context.remote.updateLoggedInUser(user, completion: context.performGroupedBlock { [unowned self] remoteUser, error in
            guard let _ = remoteUser else {
                self.elementsInProgress.markObjectsAsComplete(changes)
                return
            }

            context.performGroupedBlock({ [unowned self] in
                user.unMarkForNeedsPaypalVerification()
                context.delayedSaveOrRollback()
                self.elementsInProgress.markObjectsAsComplete([user])
            })
        })
    }
    
}