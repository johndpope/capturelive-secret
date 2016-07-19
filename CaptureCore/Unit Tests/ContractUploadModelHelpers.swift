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

func createContractWithAttachments(moc:NSManagedObjectContext, numAttachments:UInt, numFilesForAttachments:UInt)->Contract {
    var contract:Contract!  = nil
    moc.performChanges {
        contract = createContract(moc)
        for i in 0..<numAttachments {
            createAttachment(contract, numRemoteFiles:numFilesForAttachments, index:i)
        }
    }
    waitForManagedObjectContextToBeDone(moc)
    return contract
}

func createAttachment(contract:Contract, numRemoteFiles:UInt, index:UInt)->Attachment {
    let location = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    let attachment = Attachment.insertAttachment(
         contract       : contract
        ,directory      : ""
        ,location       : location
        ,managedObjectContext: contract.managedObjectContext!
    )
    var files:[String] = []
    for i in 0..<numRemoteFiles {
        files += ["attachment_\(index)_file_\(i)"]
    }
    attachment.completeMedia(
        ""
        ,files          : files
//        ,duration       : Float(2.4)
//        ,thumbnailPath  : "attachment_local_thumbnail_path"
    )
    return attachment
}

func createContract(moc:NSManagedObjectContext)->Contract {
    let remoteContract      = RemoteContract(contract:acquiredContract)
    return remoteContract.insertIntoContext(moc)
}

//let acquiredContractJSON = [
//    "unix_created_at" : 1458588073,
//    "unix_updated_at" : 1458589872,
//    "url_hash" : "2c4486f",
//    "acquired" : 1,
//    "arrival_radius" : 0.0475,
//    "event_url_hash" : "c1080fr",
//    "in_arrival_radius" : 1,
//    "resolution" : "open",
//    "stream_application" : "capture",
//    "stream_host" : "54.167.38.119",
//    "stream_name" : "2c4486f",
//    "stream_port" : "1935",
//    "stream_protocol" : "rtsp",
//    "stream_signal_fps" : "normal_normal",
//    "event" :[
//        "description" : "WHOOOO!!!!!",
//        "latitude" : 40.721933282753,
//        "location_name" :"494 Broadway, New York, NY 10012, USA",
//        "longitude": -73.99944259999999,
//        "payment_amount" : 100,
//        "public_url" : "https://mobile.capture.com/events/c1080fr",
//        "radius" : 0.337514799477102,
//        "title" : "MOBILE CHECKIN EVENT",
//        "unix_created_at" : 1458570555,
//        "unix_hiring_cutoff_time" : NSDate().hoursFromNow(2).timeIntervalSince1970,
//        "unix_start_time" : NSDate().hoursFromNow(1).timeIntervalSince1970,
//        "unix_updated_at" : 1458677055,
//        "url_hash" : "c1080fr"
//    ],
//    "publisher" :[
//        "avatar_url" : "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg",
//        "first_name" : "Jonny;",
//        "last_name" : "Publishoo",
//        "phone_number" : "+15404552569",
//        "team_url_hash" : "aabbccd",
//        "unix_created_at" : 1458587563,
//        "unix_updated_at" : 1458587563,
//        "url_hash" : "0e4b98t"
//    ],
//    "team" :[
//        "name" : "Damage, Inc.",
//        "unix_created_at" : 1458587546,
//        "unix_updated_at" : 1458587587,
//        "url_hash" : "aabbccd"
//    ]
//]


