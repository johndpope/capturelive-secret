//
//  UIApplication+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/28/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel
import CoreData

extension UIApplication {

    public func updateBadgeNumberForUnreadNotifications(moc:NSManagedObjectContext) {
        let numUnreadNotifcations           = Notification.fetchTotalNumberOfUnread(moc)
        self.applicationIconBadgeNumber     = numUnreadNotifcations
    }
    
    public func dialNumber(number:String) {
        openURL(NSURL(string:"telprompt://\(number)")!)
    }
    public func textNumber(number:String) {
        openURL(NSURL(string:"sms:\(number)")!)
    }
    
}