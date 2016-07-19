//
//  UserUpdateChangeProcessor.swift
//  Current
//
//  Created by Scott Jones on 3/17/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class RemoteUserUpdater: ElementChangeProcessorType {
    
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
        return NSCompoundPredicate(andPredicateWithSubpredicates: [User.hasNoValidationErrorPredicate, User.markedForRemoteVerificationPredicate])
    }
    
}

extension RemoteUserUpdater {
    
    func processChangedUsers(changes: [User], context: ChangeProcessorContextType) {
        guard let user = changes.first else {
           return
        }
        context.remote.updateLoggedInUser(user, completion: context.performGroupedBlock { [unowned self] remoteUser, error in
            if let rUser = remoteUser {
                if rUser.urlHash == user.urlHash {
                    context.performGroupedBlock({
                        rUser.mapTo(user)
                        context.managedObjectContext.saveOrRollback()
                    })
                    context.performGroupedBlock({ [unowned self] in
                        user.unMarkForNeedsRemoteVerification()
                        context.delayedSaveOrRollback()
                        self.elementsInProgress.markObjectsAsComplete(changes)
                    })
                    return
                }
            }
            if let validationError = error {
                print(validationError.userInfo)
                if validationError.code == 422 {
                    user.validationError = validationError.userInfo as? [String: AnyObject]
                    context.delayedSaveOrRollback()
                    self.elementsInProgress.markObjectsAsComplete(changes)
                }
            }
        })
    }
    
}






