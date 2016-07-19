//
//  Attachment+Util.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

extension Attachment {
    
    func collectionViewModel()->AttachmentCollectionViewModel {
        let formattedTime               = ClockFormatter()
        formattedTime.time              = Double(Float64(duration) / 1000)
        return AttachmentCollectionViewModel(
             thumbnailPathString        : remoteThumbnailPath ?? localThumbnailPath
            ,durationString             : formattedTime.clockString
            ,size                       : totalFileBytes
            ,isUploaded                 : uploaded
        )
    }
    
}