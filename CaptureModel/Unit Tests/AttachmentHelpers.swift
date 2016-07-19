//
//  AttachmentHelpers.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/28/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import CaptureModel

var attachmentJSON:[String:AnyObject?] = [
     "uuid"                     : "b96b57c2-7d8d-4a1b-842c-c8c8384868b6"
    ,"source"                   : "mobile"
    ,"contract_url_hash"        : "f7c26bv"
    ,"thumbnail_url"            : "http://capture-media-mobile.s3.amazonaws.com/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/thumbnail.jpg"
    ,"hd_chunks" : [
        [
             "uuid"             : "im_a_uuid"
            ,"video_path"       : "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4"
            ,"video_index"      : 1
            ,"size"             : 12543
            ,"duration"         : 7623623
            ,"unix_created_at"  : 1457708802
            ,"unix_updated_at"  : 1458678297
        ]
    ]
    ,"unix_created_at"          : 1466531862
    ,"unix_updated_at"          : 1466531887
    ,"latitude"                 : 40.7219618
    ,"longitude"                : -73.9998685
]

func getHdChunks(numChunks:Int)->[[String:AnyObject]] {
    var arr:[[String:AnyObject]] = []
    for i in 0..<numChunks {
        let n:[String : AnyObject] = [
             "uuid"             : "im_a_uuid_\(i)"
            ,"video_path"       : "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4"
            ,"video_index"      : i
            ,"size"             : 12543
            ,"duration"         : 7623623
            ,"unix_created_at"  : NSDate().timeIntervalSince1970
            ,"unix_updated_at"  : NSDate().timeIntervalSince1970
        ]
        arr.append(n)
    }
    return arr
}

func acquiredContract(moc:NSManagedObjectContext)->Contract {
    var eventContract       = eventWithContract()
    eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
    eventContract.contract["acquired"] = true
    eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
    createEvent(eventContract.event, moc: moc)
    return createContract(eventContract.contract, moc: moc)
}

func createAttachment(moc:NSManagedObjectContext)->Attachment {
    let contract            = acquiredContract(moc)
    let coordinate          = CLLocationCoordinate2D(latitude: 2.0, longitude: 3.0)
    return Attachment.insertAttachment(contract: contract, directory:"",  location:coordinate, managedObjectContext:moc)
}

func createAttachment(JSON:[String:AnyObject?], moc:NSManagedObjectContext)->Attachment {
    let remoteAttachment    = RemoteAttachment(attachment:JSON)
    var attachment:Attachment!        = nil
    moc.performChanges {
        attachment          = remoteAttachment.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return attachment
}















