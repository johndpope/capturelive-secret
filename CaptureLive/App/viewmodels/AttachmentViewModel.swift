//
//  AttachmentViewModel.swift
//  Current
//
//  Created by Scott Jones on 4/4/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import Foundation
import CaptureUI

struct AttachmentCollectionViewModel {
    let thumbnailPathString:String?
    let durationString:String
    let size:UInt64
    let isUploaded:Bool
}

extension AttachmentCollectionViewModel {
    
    var sizeString:String {
        return CMDisk.memoryFormatter(Int64(size))
    }
    
    var detailString:String {
        return "File size:\(sizeString)  Length of video: \(durationString)"
    }

}