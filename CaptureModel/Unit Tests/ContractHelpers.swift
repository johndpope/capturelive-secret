//
//  ContractHelpers.swift
//  Current
//
//  Created by Scott Jones on 3/22/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CaptureModel

let acquiredContract = [
    "unix_created_at" : 1458588073,
    "unix_updated_at" : 1458589872,
    "url_hash" : "2c4486f",
    "acquired" : 1,
    "arrival_radius" : 0.0475,
    "event_url_hash" : "c1080fr",
    "in_arrival_radius" : 1,
    "resolution" : "open",
    "stream_application" : "capture",
    "stream_host" : "54.167.38.119",
    "stream_name" : "2c4486f",
    "stream_port" : "1935",
    "stream_protocol" : "rtsp",
    "stream_signal_fps" : "normal_normal",
    "payment_status":"pending",
    "started":1,
    "event" :[
        "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
        "creator_name"      : "TIMMYS DREAM",
        "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200",
        "description" : "WHOOOO!!!!!",
        "latitude" : 40.721933282753,
        "location_name" :"494 Broadway, New York, NY 10012, USA",
        "longitude": -73.99944259999999,
        "payment_amount" : 100,
        "public_url" : "https://mobile.capture.com/events/c1080fr",
        "radius" : 0.337514799477102,
        "title" : "MOBILE CHECKIN EVENT",
        "unix_created_at" : 1458570555,
        "unix_hiring_cutoff_time" : NSDate().hoursFromNow(2).timeIntervalSince1970,
        "unix_start_time" : NSDate().hoursFromNow(1).timeIntervalSince1970,
        "unix_updated_at" : 1458677055,
        "url_hash" : "c1080fr"
    ],
    "publisher" :[
        "avatar_url" : "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg",
        "first_name" : "Jonny;",
        "last_name" : "Publishoo",
        "phone_number" : "+15404552569",
        "team_url_hash" : "aabbccd",
        "unix_created_at" : 1458587563,
        "unix_updated_at" : 1458587563,
        "url_hash" : "0e4b98t"
    ],
    "team" :[
        "name" : "Damage, Inc.",
        "unix_created_at" : 1458587546,
        "unix_updated_at" : 1458587587,
        "url_hash" : "aabbccd"
    ]
]

let unacquiredContract = [
    "unix_created_at" : 1458588073,
    "unix_updated_at" : 1458589872,
    "url_hash" : "2c4486f",
    "acquired" : 0,
    "arrival_radius" : 0.0475,
    "event_url_hash" : "c1080fr",
    "in_arrival_radius" : 1,
    "resolution" : "open",
    "stream_application" : "capture",
    "stream_host" : "54.167.38.119",
    "stream_name" : "2c4486f",
    "stream_port" : "1935",
    "stream_protocol" : "rtsp",
    "stream_signal_fps" : "normal_normal",
    "payment_status" :"pending",
    "started":0,
    "event" :[
        "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
        "creator_name"      : "TIMMYS DREAM",
        "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200",
        "description" : "WHOOOO!!!!!",
        "latitude" : 40.721933282753,
        "location_name" :"494 Broadway, New York, NY 10012, USA",
        "longitude": -73.99944259999999,
        "payment_amount" : 100,
        "public_url" : "https://mobile.capture.com/events/c1080fr",
        "radius" : 0.337514799477102,
        "title" : "MOBILE CHECKIN EVENT",
        "unix_created_at" : 1458570555,
        "unix_hiring_cutoff_time" : NSDate().hoursFromNow(2).timeIntervalSince1970,
        "unix_start_time" : NSDate().hoursFromNow(1).timeIntervalSince1970,
        "unix_updated_at" : 1458677055,
        "url_hash" : "c1080fr"
    ],
    "publisher" :[
        "avatar_url" : "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg",
        "first_name" : "Jonny;",
        "last_name" : "Publishoo",
        "phone_number" : "+15404552569",
        "team_url_hash" : "aabbccd",
        "unix_created_at" : 1458587563,
        "unix_updated_at" : 1458587563,
        "url_hash" : "0e4b98t"
    ],
    "team" :[
        "name" : "Damage, Inc.",
        "unix_created_at" : 1458587546,
        "unix_updated_at" : 1458587587,
        "url_hash" : "aabbccd"
    ]
]

func createContract(JSON:[String:AnyObject], moc:NSManagedObjectContext)->Contract {
    let remoteContract      = RemoteContract(contract:JSON)
    var contract:Contract!  = nil
    moc.performChanges {
        contract            = remoteContract.insertIntoContext(moc)
    }

    waitForManagedObjectContextToBeDone(moc)
    return contract
}

let acceptedContractEvent:[String:AnyObject] = [
    "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
    "creator_name"      : "TIMMYS DREAM",
    "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200",
    "description" : "WHOOOO!!!!!",
    "latitude" : 40.721933282753,
    "location_name" :"494 Broadway, New York, NY 10012, USA",
    "longitude": -73.99944259999999,
    "payment_amount" : 100,
    "public_url" : "https://mobile.capture.com/events/c1080fr",
    "radius" : 0.337514799477102,
    "title" : "MOBILE CHECKIN EVENT",
    "unix_created_at" : 1458570555,
    "unix_hiring_cutoff_time" : NSDate().hoursFromNow(2).timeIntervalSince1970,
    "unix_start_time" : NSDate().hoursFromNow(1).timeIntervalSince1970,
    "unix_updated_at" : 1458677055,
    "url_hash" : "c1080fr"
]
let acceptedContractFullEvent:[String:AnyObject] = [
    "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
    "creator_name"      : "TIMMYS DREAM",
    "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200",
    "unix_created_at" : 1458588073,
    "unix_updated_at" : 1458589872,
    "url_hash" : "2c4486f",
    "acquired" : false,
    "started":0,
    "arrival_radius" : 0.0475,
    "event_url_hash" : "c1080fr",
    "in_arrival_radius" : 1,
    "resolution" : "open",
    "stream_application" : "capture",
    "stream_host" : "54.167.38.119",
    "stream_name" : "2c4486f",
    "stream_port" : "1935",
    "stream_protocol" : "rtsp",
    "stream_signal_fps" : "normal_normal",
    "payment_status":"pending",
    "event" : acceptedContractEvent
]
let acceptedContractNoEvent:[String:AnyObject] = [
    "banner_image_url"  : "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png",
    "creator_name"      : "TIMMYS DREAM",
    "creator_icon_url"  : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200",
    "unix_created_at" : 1458588073,
    "unix_updated_at" : 1458589872,
    "url_hash" : "2c4486f",
    "acquired" : false,
    "started":0,
    "arrival_radius" : 0.0475,
    "event_url_hash" : "c1080fr",
    "in_arrival_radius" : 1,
    "resolution" : "open",
    "stream_application" : "capture",
    "stream_host" : "54.167.38.119",
    "stream_name" : "2c4486f",
    "stream_port" : "1935",
    "stream_protocol" : "rtsp",
    "stream_signal_fps" : "normal_normal",
    "payment_status":"pending",
]




let completedContract:[String:AnyObject] = [
     "unix_created_at" : NSDate().timeIntervalSince1970
    ,"unix_updated_at" : NSDate().timeIntervalSince1970
    ,"url_hash" : "2c4486f"
    ,"acquired" : 1
    ,"started":1
    ,"arrival_radius" : 0.0475
    ,"event_url_hash" : "c1080fr"
    ,"in_arrival_radius" : 1
    ,"resolution" : "completed"
    ,"stream_application" : "capture"
    ,"stream_host" : "54.167.38.119"
    ,"stream_name" : "2c4486f"
    ,"stream_port" : "1935"
    ,"stream_protocol" : "rtsp"
    ,"stream_signal_fps" : "normal_normal"
    ,"event" : [
         "description" : "WHOOOO!!!!!"
        ,"latitude" : 40.721933282753
        ,"location_name" :"494 Broadway, New York, NY 10012, USA"
        ,"longitude": -73.99944259999999
        ,"payment_amount" : 100
        ,"public_url" : "https://mobile.capture.com/events/c1080fr"
        ,"radius" : 0.337514799477102
        ,"title" : "MOBILE CHECKIN EVENT"
        ,"unix_created_at" : NSDate().timeIntervalSince1970
        ,"unix_hiring_cutoff_time" : NSDate().timeIntervalSince1970
        ,"unix_start_time" : NSDate().timeIntervalSince1970
        ,"unix_updated_at" : NSDate().timeIntervalSince1970
        ,"url_hash" : "c1080fr"
    ]
    ,"publisher" : [
         "avatar_url" : "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg"
        ,"first_name" : "Jonny;"
        ,"last_name" : "Publishoo"
        ,"phone_number" : "+15404552569"
        ,"team_url_hash" : "aabbccd"
        ,"unix_created_at" : NSDate().timeIntervalSince1970
        ,"unix_updated_at" : NSDate().timeIntervalSince1970
        ,"url_hash" : "0e4b98t"
    ]
    ,"team" : [
         "name" : "Damage, Inc."
        ,"unix_created_at" : NSDate().timeIntervalSince1970
        ,"unix_updated_at" : NSDate().timeIntervalSince1970
        ,"url_hash" : "aabbccd"
    ]
    ,"attachments": [[
         "uuid": "b96b57c2-7d8d-4a1b-842c-c8c8384868b6"
        ,"source": "mobile"
        ,"contract_url_hash": "f7c26bv"
        ,"thumbnail_url": "http://capture-media-mobile.s3.amazonaws.com/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/thumbnail.jpg"
        ,"hd_chunks": [
            [
                 "uuid": "im_a_uuid_0"
                ,"video_path": "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4"
                ,"video_index": 0
                ,"size":              12543
                ,"duration":        762359
                ,"unix_created_at": NSDate().hoursFromNow(0).timeIntervalSince1970
                ,"unix_updated_at": NSDate().hoursFromNow(0).timeIntervalSince1970
            ]
            ,[
                 "uuid": "im_a_uuid_1"
                ,"video_path": "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4"
                ,"video_index": 1
                ,"size":              12543
                ,"duration":        762359
                ,"unix_created_at": NSDate().hoursFromNow(1).timeIntervalSince1970
                ,"unix_updated_at": NSDate().hoursFromNow(1).timeIntervalSince1970
            ]
        ]
        ,"unix_created_at": NSDate().timeIntervalSince1970
        ,"unix_updated_at": NSDate().timeIntervalSince1970
        ,"latitude": 40.7219618
        ,"longitude": -73.9998685
    ]]
]
