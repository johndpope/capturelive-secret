//
//  File.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CaptureModel
import CoreLocation

var remoteFileJSON:[String:AnyObject?] = [
     "uuid"                 : "im_a_uuid"
    ,"video_path"           : "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4"
    ,"video_index"          : 1
    ,"size"                 : 12543
    ,"duration"             : 1234399
    ,"unix_created_at"      : 1457708802
    ,"unix_updated_at"      : 1458678297
]

func createRemoteFile(JSON:[String:AnyObject?], attachment:Attachment, moc:NSManagedObjectContext)->RemoteFile {
    let remoteRemoteFile            = RemoteRemoteFile(remoteFile:JSON)
    var remoteFile:RemoteFile!      = nil
    moc.performChanges {
        remoteFile                  = remoteRemoteFile.insertIntoContext(moc)
        remoteFile.attachment       = attachment
    }
    waitForManagedObjectContextToBeDone(moc)
    return remoteFile
}

func createContractWithAttachments(moc:NSManagedObjectContext, numAttachments:UInt, numRemoteFiles:UInt)->Contract {
    var contract:Contract!  = nil
    moc.performChanges {
        contract = createContract(moc)
        for _ in 0..<numAttachments {
            createAttachment(contract, numRemoteFiles:numRemoteFiles)
        }
    }
    waitForManagedObjectContextToBeDone(moc)
    return contract
}

func createAttachment(contract:Contract, numRemoteFiles:UInt = 5)->Attachment {
    let location = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    let attachment = Attachment.insertAttachment(
         contract       : contract
        ,directory      : ""
        ,location       : location
        ,managedObjectContext: contract.managedObjectContext!
    )
    var files:[String] = []
    for i in 0..<numRemoteFiles {
        files += ["attachment_file_\(i)"]
    }
    attachment.completeMedia(
        ""
        ,files          : files
//        ,thumbnailPath  : "attachment_local_thumbnail_path"
    )
    attachment.localThumbnailPath = "attachment_local_thumbnail_path"
    return attachment
}

func createContract(moc:NSManagedObjectContext)->Contract {
    let remoteContract      = RemoteContract(contract:acquiredContract)
    return remoteContract.insertIntoContext(moc)
}