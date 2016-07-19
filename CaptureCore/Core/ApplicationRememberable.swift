//
//  PermissionsValidatable.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreData
import CoreDataHelpers

public protocol ApplicationRememberable :ApplicationReportable {
    var hasBeenAskedForLocationInformation:Bool { get }
    func saveHasBeenAskedForLocationInformation()
    var hasBeenAskedForPushNotifications:Bool { get }
    func saveHasBeenAskForPushNotifications()
    var hasAcceptedPermissions:Bool { get }
    var lastUsedNumber:String? {get}
    func setLastUsedNumber(numberString:String)

}

public let AcceptedPushPermissionsKey         = "com.capture.ios.pushnotifications.key"
public let AcceptedLocationPermissionsKey     = "com.capture.ios.locationtrakcing.key"
public let LastUsedNumberKey                  = "com.capture.ios.lastusernumber.key"

extension NSManagedObjectContext:ApplicationRememberable {
    
    public var hasBeenAskedForLocationInformation:Bool {
        guard let val = metaData[AcceptedLocationPermissionsKey] as? Bool else {
            return false
        }
        return val
    }
    
    public func saveHasBeenAskedForLocationInformation() {
        setMetaData(true, key:AcceptedLocationPermissionsKey)
    }
    
    public var hasBeenAskedForPushNotifications:Bool {
        guard let val = metaData[AcceptedPushPermissionsKey] as? Bool else {
            return false
        }
        return val
    }
    
    public func saveHasBeenAskForPushNotifications() {
        setMetaData(true, key:AcceptedPushPermissionsKey)
    }
    
    public var lastUsedNumber:String? {
        return metaData[LastUsedNumberKey] as? String
    }
    
    public func setLastUsedNumber(numberString:String) {
        setMetaData(numberString, key:LastUsedNumberKey)
    }
    
    public var hasAcceptedPermissions:Bool {
        return hasBeenAskedForPushNotifications && hasBeenAskedForLocationInformation
    }
   
}
