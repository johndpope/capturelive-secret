//
//  TeamHelpers.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

var contractTeam =  [
    "name"              : "Damage, Inc.",
    "icon_url"          : "https://s3.amazonaws.com/capture-static/default-team-icon-mobile.png",
    "unix_created_at"   : 1458587546,
    "unix_updated_at"   : 1458587587,
    "url_hash"          : "aabbccd"
]

func createTeam(JSON:[String:AnyObject], moc:NSManagedObjectContext)->Team {
    let remoteTeam      = RemoteTeam(team:JSON)
    var team:Team!      = nil
    moc.performChanges {
        team            = remoteTeam.insertIntoContext(moc)
    }
    waitForManagedObjectContextToBeDone(moc)
    return team
}