//
//  NotificationJSONCachable.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/14/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreDataHelpers
import CoreData

private let TappedNotificationJsonKey             = "com.capturelive.notificationjson.tappedtoenter"
protocol NotificationJSONCachable {
    func cachedNotificationUserInfo()->[String:AnyObject]?
    func cacheNotification(userInfo:[NSObject:AnyObject])
}

extension NSManagedObjectContext : NotificationJSONCachable {
    
    public func cachedNotificationUserInfo()->[String:AnyObject]? {
        guard let userInfo = metaData[TappedNotificationJsonKey] as? [String:AnyObject] else {
            return nil
        }
        setMetaData(nil, key: TappedNotificationJsonKey)
        return userInfo
    }
    
    public func cacheNotification(userInfo:[NSObject:AnyObject]) {
        setMetaData(userInfo as? [String:AnyObject], key: TappedNotificationJsonKey)
    }
    
}









