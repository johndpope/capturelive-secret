//
//  CMPermissionsManager+PushNotification.swift
//  Capture-Live
//
//  Created by hatebyte on 6/29/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

extension CMPermissionsManager {
    
    public func askForPushPermission(accepted:Accepted, denied:Denied) {
        self.accepted                               = accepted
        self.denied                                 = denied
        if self.hasNotificationsTurnedOn() == true || self.hasBeenAskForPushNotifications() == true{
            pushSettingsResponse()
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CMPermissionsManager.pushSettingsResponse), name:UIApplicationDidBecomeActiveNotification, object:nil)
        }
        self.askForPushPermission()
    }
    
    func pushSettingsResponse() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIApplicationDidBecomeActiveNotification, object:nil)
        if self.hasNotificationsTurnedOn() {
            self.accepted()
        } else {
            self.denied()
        }
        self.accepted                               = nil
        self.denied                                 = nil
    }
    
    public func hasBeenAskForPushNotifications()->Bool {
        return persistanceLayer.hasBeenAskedForLocationInformation
    }
    
}
