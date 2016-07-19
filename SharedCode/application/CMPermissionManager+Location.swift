//
//  CMPermissionManager+Location.swift
//  Capture-Live
//
//  Created by hatebyte on 6/29/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

extension CMPermissionsManager {
      
    public func askForLocationPermission(accepted:Accepted, denied:Denied) {
        self.accepted                               = accepted
        self.denied                                 = denied
       
        if self.hasLocationSettingsTurnedOn() == true || self.hasBeenAskedForLocationTracking() == true {
            locationSettingResponse()
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CMPermissionsManager.locationSettingResponse), name:UIApplicationDidBecomeActiveNotification, object:nil)
            askForLocationPermission()
        }
    }
    
    func locationSettingResponse() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIApplicationDidBecomeActiveNotification, object:nil)
        if self.hasLocationSettingsTurnedOn() {
            self.accepted()
        } else {
            self.denied()
        }
        self.accepted                               = nil
        self.denied                                 = nil
    }
    
    func hasBeenAskedForLocationTracking()->Bool {
        return persistanceLayer.hasBeenAskedForLocationInformation
    }
    
}
