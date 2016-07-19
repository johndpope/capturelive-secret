//
//  NotificationHelpers.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CaptureModel

func createNotification(JSON:[String:AnyObject?], moc:NSManagedObjectContext)->Notification {
    let remoteNotification      = RemoteNotification(notification:JSON)
    var notification:Notification!  = nil
    moc.performChanges {
        notification            = remoteNotification.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return notification
}

func createContractNotification(noteJSON:[String:AnyObject?], noteUrlHash:String, contractHash:String, moc:NSManagedObjectContext)->Notification {
    var notificationJSON                = noteJSON
    notificationJSON["url_hash"]        = noteUrlHash
    notificationJSON["payload_source"]  = "contract"
    notificationJSON["payload_object_url_hash"] = contractHash
    return createNotification(notificationJSON, moc:moc)
}

func createEventNotification(noteJSON:[String:AnyObject?], noteUrlHash:String, eventHash:String, moc:NSManagedObjectContext)->Notification {
    var notificationJSON                = noteJSON
    notificationJSON["url_hash"]        = noteUrlHash
    notificationJSON["payload_source"]  = "event"
    notificationJSON["payload_object_url_hash"] = eventHash
    return createNotification(notificationJSON, moc:moc)
}

func createContractForNotifications(contractHash:String, eventHash:String, moc:NSManagedObjectContext)->Contract {
    var eventJSON                       = acceptedContractEvent
    eventJSON["url_hash"]               = eventHash
    
    var contractJSON                    = acceptedContractNoEvent
    contractJSON["url_hash"]            = contractHash
    
    contractJSON["event"]               = eventJSON
    contractJSON["event_url_hash"]      = eventHash
    return createContract(contractJSON, moc:moc)
}


let testNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "Test push oh yeah",
    "payload_source"            : "test", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let availNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
//    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "New Job",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let hiredNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 40,
    "message"                   : "You've been hired",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let arrivedNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
//    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 41,
    "message"                   : "You've arrived",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let cancelHiredNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 42,
    "message"                   : "Job cancelled by Theodore S.",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let getToLocNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 60,
    "message"                   : "Job Starts in 1 hour. Get to the location!",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let pendingNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "PENDING APPROVAL",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let underReviewNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "UNDER REVIEW by Capture Live",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]

let deniedNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "DENIED PAYMENT by Theodore S.",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]


let grantedNotifJSON:[String:AnyObject?] = [
    "url_hash"                  : "aassddsda",
    "unix_created_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    "unix_updated_at"           : NSDate().hoursFromNow(-2).timeIntervalSince1970,
    //    "unix_read_at"              : NSNull(),// or null
    "push_type"                 : 10,
    "message"                   : "PAYMENT GRANTED by Capture Live",
    "payload_source"            : "contract", // or "event", or "default"?
    "payload_object_url_hash"   : "aabbcc", // null
]


