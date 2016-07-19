//
//  FixtureUtilies.swift
//  Current
//
//  Created by Scott Jones on 3/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

let fakeUser = [
    "url_hash"              : "b6a910c",
    "unix_created_at"       : 1456845403,
    "unix_updated_at"       : 1457961208,
    "first_name"            : "Scoats",
    "last_name"             : "Maloats",
    "phone_number"          : "9085818600",
    "contact_email"         : "scott+v3@capture.com",
    "instagram_username"    : "hatebyte",
    "paypal_email"          : "hatebyte@gmail.com",
    "avatar"                : "https://capture-media-mobile.s3.amazonaws.com/uploads/user/avatar/48/retina_1456845450.jpg",
    "age_range_min"         : 21,
    "bio"                   : "I like turtles"
]

let partialCreatedUser = [
    "url_hash"              : "b6a910c",
    "unix_created_at"       : 1456845403,
    "unix_updated_at"       : 1457961208,
    "first_name"            : "Scoats",
    "last_name"             : "",
    "phone_number"          : "9085818600",
    "contact_email"         : "scott+v3@capture.com",
]

let needsPaypalUser = [
    "url_hash"              : "b6a910c",
    "unix_created_at"       : 1456845403,
    "unix_updated_at"       : 1457961208,
    "first_name"            : "Scoats",
    "last_name"             : "Maloats",
    "phone_number"          : "9085818600",
    "contact_email"         : "scott+v3@capture.com",
    "instagram_username"    : "hatebyte",
    "paypal_confirmed"      : 0,
    "paypal_email"          : "",
]

let needsAvatar = [
    "url_hash"              : "b6a910c",
    "unix_created_at"       : 1456845403,
    "unix_updated_at"       : 1457961208,
    "first_name"            : "Scoats",
    "last_name"             : "Maloats",
    "phone_number"          : "9085818600",
    "contact_email"         : "scott+v3@capture.com",
    "instagram_username"    : "hatebyte",
    "paypal_email"          : "hatebyte@gmail.com",
    "avatar"                : ""
]

let facebookUser = [
    "first_name"    : "Scott",
    "gender"        : "male",
    "id"            : "100007054787196",
    "last_name"     : "Jones",
    "link"          : "https://www.facebook.com/app_scoped_user_id/100007054787196/",
    "locale"        : "en_US",
    "name"          : "Scott Jones",
    "timezone"      : "-4",
    "updated_time"  : "2014-02-11T16:56:52+0000",
    "email"         : "scott@capture.com",
    "verified"      : 1,
    "age_range"     : [
        "min"           : 21
    ],
    "picture"       : [
        "data"          : [
            "is_silhouette" : 0,
            "url"           : "https://scontent.xx.fbcdn.net/hprofile-xfa1/v/t1.0-1/c13.0.50.50/p50x50/1621906_1420531514858728_163635241_n.jpg?oh=7bfb0fd47a802b26f2dfd0c216ed1bd2&oe=5772EE65"
        ]
    ]
]

func createUser(JSON:[String:AnyObject], moc:NSManagedObjectContext)->User {
    let remoteUser          = RemoteUser(user:JSON)
    var user:User!          = nil
    moc.performChanges {
        user                = remoteUser.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return user
}

func loginUser(user:User, moc:NSManagedObjectContext) {
    moc.performChanges {
        user.setAsLoggedInUser()
    }
    waitForManagedObjectContextToBeDone(moc)
}

func attemptingLoginUser(user:User, moc:NSManagedObjectContext) {
    moc.performChanges {
        user.setAsAttemptingLoginUser()
    }
    waitForManagedObjectContextToBeDone(moc)
}