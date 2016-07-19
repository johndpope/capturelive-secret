//
//  PublisherHelpers.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

var contractPublisher =  [
    "avatar_url"        : "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg",
    "first_name"        : "Jonny;",
    "last_name"         : "Publishoo",
    "phone_number"      : "+15404552569",
    "team_url_hash"     : "aabbccd",
    "unix_created_at"   : 1458587563,
    "unix_updated_at"   : 1458587563,
    "url_hash"          : "0e4b98t"
]

func createPublisher(JSON:[String:AnyObject], moc:NSManagedObjectContext)->Publisher {
    let remotePublisher         = RemotePublisher(publisher:JSON)
    var publisher:Publisher!    = nil
    moc.performChanges {
        publisher               = remotePublisher.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return publisher
}