//
//  EventHelpers.swift
//  Current
//
//  Created by Scott Jones on 3/22/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

var eventJSON = [
    "description"       : "Don't forget ice",
    "latitude"          : 40.721935965506,
    "location_name"     : "42 Greene St, New York, NY 10013, USA",
    "longitude"         : -74.00171711324469,
    "payment_amount"    : 100,
    "public_url"        : "https://mobile.capture.com/events/b8f20al",
    "radius"            : 0.337514785876185,
    "title"             : "Buy some wiskey for Pavel",
    "unix_created_at"   : 1457708802,
    "unix_hiring_cutoff_time" : 1459422300,
    "unix_start_time"   : 1458736200,
    "unix_updated_at"   : 1458678297,
    "url_hash"          : "b8f20al",
    "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
    "creator_name"      : "TIMMYS DREAM",
    "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
]

func createEvent(JSON:[String:AnyObject], moc:NSManagedObjectContext)->Event {
    let remoteEvent          = RemoteEvent(event:JSON)
    var event:Event!        = nil
    moc.performChanges {
        event               = remoteEvent.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return event
}

func eventWithContract()->(event:[String:AnyObject], contract:[String:AnyObject]) {
    let event = eventJSON
    var contract = unacquiredContract
    contract["event_url_hash"] = event["url_hash"]!
    contract["event"] = event
    return (event:event, contract:contract)
}
    