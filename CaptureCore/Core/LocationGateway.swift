//
//  OnboardManager.swift
//  CaptureMedia-Acme
//
//  Created by hatebyte on 9/3/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

import Foundation
import CoreLocation

public typealias ValidUpdate = (Bool)->()

public class LocationGateway: NSObject {
    
    let locationManger                                          = CMUserMovementManager.shared
    var lastLocation:CLLocation?
    var movementThreshold:Double                                = 10.0
    var backgroundTask:UIBackgroundTaskIdentifier? = UIBackgroundTaskInvalid
  
    public func startTrackingPreciseLocation() {
        self.stopBackgroundTracking()
        if self.backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
        }
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
        })
        locationManger.startPreciseLocation { [unowned self] (location:CLLocation, transportation:CMMotionTransportation) -> Void in
            self.callback(location, transportation:transportation, com: { [unowned self] (success:Bool) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = UIBackgroundTaskInvalid

            })
        }
    }
    
    public func startTrackingSemiPreciseLocation() {
        self.stopBackgroundTracking()
        if self.backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
        }
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
        })
        locationManger.startSemiPreciseLocation { [unowned self] (location:CLLocation, transportation:CMMotionTransportation) -> Void in
            self.callback(location, transportation:transportation, com: { [unowned self] (success:Bool) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = UIBackgroundTaskInvalid
            })
        }
    }
    
    public func startTrackingSignificantLocation() {
        if self.backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
        }
        self.backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
        })
        locationManger.startSignificantLocation { [unowned self] (location:CLLocation, transportation:CMMotionTransportation) -> Void in
            self.callback(location, transportation:transportation, com: { [unowned self] (success:Bool) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = UIBackgroundTaskInvalid
            })
        }
    }
    
    public func stopTrackingSignificantLocation() {
        locationManger.stopTrackingSignificantLocation()
    }
    
    public func stopBackgroundTracking() {
        locationManger.stopBackgroundUpdating()
    }
    
    public func callback(location:CLLocation, transportation:CMMotionTransportation, com:ValidUpdate) {
        com(true)
    }
    
    public func hasTraveledEnough(location:CLLocation)->Bool {
        if let ll = self.lastLocation {
            let meters                      = ll.distanceFromLocation(location)
            if meters > self.movementThreshold {
                self.lastLocation           = location
                return true
            }
        } else {
            self.lastLocation               = location
            return true
        }
        return false
    }

}
