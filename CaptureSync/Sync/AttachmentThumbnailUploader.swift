//
//  AttachmentThumbnailUploader.swift
//  Current
//
//  Created by Scott Jones on 4/4/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class AttachmentThumbnailUploader: ElementChangeProcessorType {
    
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
        return Attachment.markedForS3VerificationPredicate
    }
    
}

extension AttachmentThumbnailUploader {
    
    func processChangedAttachments(attachments: [Attachment], context: ChangeProcessorContextType) {
        guard let attachment = attachments.first else {
            return
        }
        context.remote.uploadLocalThumbnailToRemote(attachment, completion: context.performGroupedBlock { [unowned self] remoteThumbnailPath, error in
            
            guard let remotePath = remoteThumbnailPath else {
                self.elementsInProgress.markObjectsAsComplete([attachment])
                if error?.code == 260 {
                    attachment.unMarkForNeedsS3Verification()
                    context.delayedSaveOrRollback()
                }
                return
            }
            
            attachment.remoteThumbnailPath = remotePath
            attachment.unMarkForNeedsS3Verification()
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete([attachment])
            
        })
    }
    
}