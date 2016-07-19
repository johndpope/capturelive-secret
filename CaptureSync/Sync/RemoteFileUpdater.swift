//
//  RemoteFileUpdater.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class RemoteFileUpdater: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<RemoteFile>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [RemoteFile], context: ChangeProcessorContextType) {
        processChangedRemoteFiles(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return RemoteFile.markedForRemoteVerificationPredicate
    }
    
}

extension RemoteFileUpdater {
    
    func processChangedRemoteFiles(remoteFiles: [RemoteFile], context: ChangeProcessorContextType) {
        guard let remoteFile = remoteFiles.first else {
            return
        }
        context.remote.updateRemoteFile(remoteFile, completion: context.performGroupedBlock { [unowned self] error in
            if let _ = error {
                self.elementsInProgress.markObjectsAsComplete([remoteFile])
                return
            }

            remoteFile.unMarkForNeedsRemoteVerification()
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete([remoteFile])
        })
    }
    
}




