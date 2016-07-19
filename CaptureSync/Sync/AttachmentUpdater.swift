//
//  AttachmentUpdater.swift
//  Current
//
//  Created by Scott Jones on 4/1/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class AttachmentUpdater: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<Attachment>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [Attachment], context: ChangeProcessorContextType) {
        processChangedAttachments(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return Attachment.markedForRemoteVerificationPredicate
    }
    
}

extension AttachmentUpdater {
    
    func processChangedAttachments(attachments: [Attachment], context: ChangeProcessorContextType) {
        guard let attachment = attachments.first else {
            return
        }
        context.remote.updateAttachment(attachment, completion: context.performGroupedBlock { [unowned self] remoteAttachment, error in
            guard let _ = remoteAttachment else {
                self.elementsInProgress.markObjectsAsComplete([attachment])
                return
            }
            
            attachment.unMarkForNeedsRemoteVerification()
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete([attachment])
        })
    }

}