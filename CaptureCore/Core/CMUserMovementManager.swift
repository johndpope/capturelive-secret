//
//  LocationManager.swift
//  Current-Tools
//
//  Created by hatebyte on 7/16/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

public typealias UpdateLocation = (location:CLLocation, transportation:CMMotionTransportation)->()

public protocol CoordinateParsable {
    func distanceFromLocation(location:CLLocation)->Double
    static func distance(location1:CLLocation, location2:CLLocation)->Double
}

public enum CMMotionTransportation : String {
    case Unknown                        = "unknown"
    case Stationary                     = "stationary"
    case Walking                        = "walking"
    case Running                        = "running"
    case Cycling                        = "cycling"
    case Automotive                     = "automotive"
}
public class CMUserMovementManager: NSObject, CLLocationManagerDelegate {
    
    public static let CMLocationUpdated        = "com.current.location.manager.location.updated"
    public static let CMLongitude              = "com.current.location.manager.longitude"
    public static let CMLatitude               = "com.current.location.manager.latitude"
    public static let CMTransportation         = "com.current.location.manager.transportation"
    
    var update:UpdateLocation?
    var sigUpdate:UpdateLocation?
    public var locationRetrievable:LocationRetrievable?
   
    public class var shared :CMUserMovementManager {
        struct Singleton {
            static let instance = CMUserMovementManager()
        }
        return Singleton.instance
    }
    
    lazy var motionManager: CMMotionActivityManager? = {
        if CMMotionActivityManager.isActivityAvailable() {
            return CMMotionActivityManager()
        } else {
            return nil
        }
    }()
    
    lazy var locationManager: CLLocationManager! = {
        let manager                     = CLLocationManager()
        manager.desiredAccuracy         = kCLLocationAccuracyBest
        manager.delegate                = self
        
//        if #available(iOS 8.0, *) {
            manager.requestAlwaysAuthorization()
//        }
        return manager
    }()

    public func startPreciseLocation(update:UpdateLocation) {
        self.update                     = update;
//        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
//        }
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
//        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter  = kCLDistanceFilterNone
//        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
//        motionManager?.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (act:CMMotionActivity?) -> Void in
//            if let activity = act {
//                self.saveMotion(activity)
//            }
//        })
    }
    
    public func startSemiPreciseLocation(update:UpdateLocation) {
        self.update                     = update;
//        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
//        }
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
//        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter  = 100
//        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    public func startSignificantLocation(update:UpdateLocation) {
        self.sigUpdate                  = update;
//        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
//        }
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopBackgroundUpdating() {
        locationManager.stopUpdatingLocation()
        update                          = nil
    }

    public func stopTrackingSignificantLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        update                          = nil
    }
    
    public func updateLocation(newLocation:CLLocation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            // test the age of the location measurement to determine if the measurement is cached
            // in most cases you will not want to rely on cached measurements
            let eventDate               = newLocation.timestamp;
            let locationAge             = eventDate.timeIntervalSinceNow
            if locationAge > 5.0 {
                return
            }
            // test that the horizontal accuracy does not indicate an invalid measurement
            if newLocation.horizontalAccuracy < 0 {
                return
            }
            let currentLoc = self.currentLocation
            if newLocation.coordinate.latitude != currentLoc.latitude || newLocation.coordinate.longitude != currentLoc.longitude {
                self.currentLocation    = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                dispatch_async(dispatch_get_main_queue(),{
                    self.update?(location: newLocation, transportation:self.transportation)
                    self.sigUpdate?(location: newLocation, transportation:self.transportation)
                    NSNotificationCenter.defaultCenter().postNotificationName(CMUserMovementManager.CMLocationUpdated, object: self)
                });
            }
        })
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.updateLocation(newLocation)
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.updateLocation(location)
        }
    }

    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }

    public var currentLocation:CLLocationCoordinate2D {
        get {
            guard let c = locationRetrievable?.coordinate else {
                return CLLocationCoordinate2D()
            }
            return c
        }
        set {
            locationRetrievable?.coordinate = newValue
        }
    }
    
    public func useDriving() {
        self.transportation             = CMMotionTransportation.Automotive
    }
    
    public func useWalking() {
        self.transportation             = CMMotionTransportation.Walking
    }
    
    public func isWalking()->Bool  {
        return (self.transportation == CMMotionTransportation.Walking)
    }
    
    public func isDriving()->Bool {
        return (self.transportation == CMMotionTransportation.Automotive)
    }
    
//    func saveMotion(activity:CMMotionActivity) {
//        if activity.stationary == true {
//            self.transportation         = CMMotionTransportation.Stationary
//        } else if activity.walking == true {
//            self.transportation         = CMMotionTransportation.Walking
//        } else if activity.running == true {
//            self.transportation         = CMMotionTransportation.Running
//        } else if activity.automotive == true {
//            self.transportation         = CMMotionTransportation.Automotive
//        } else {
//            self.transportation         = CMMotionTransportation.Unknown
//        }
//        if #available(iOS 8.0, *) {
//            if activity.cycling == true {
//                self.transportation     = CMMotionTransportation.Cycling
//            }
//        }
//    }
    
    public func transportationToGoogleTravelMode()->String {
        switch (self.transportation) {
//        case .Stationary:
//            return "walking"
//        case .Walking:
//            return "walking"
//        case .Running:
//            return "walking"
        case .Automotive:
            return "driving"
        case .Walking:
            return "walking"
        default:
            return "driving"
//        case .Unknown:
//            return "walking"
//        case .Cycling:
//            return "bicycling"
        }
    }
    
    public func transportationToAppleTravelMode()->String {
        return self.transportation.rawValue
    }
    
    public var transportation:CMMotionTransportation {
        get {
            guard let t = locationRetrievable?.transportation else {
                return CMMotionTransportation.Automotive
            }
            return CMMotionTransportation(rawValue:t)!
        }
        set {
            locationRetrievable?.transportation = newValue.rawValue
        }
     }
    

}

extension CMUserMovementManager:CoordinateParsable {
    
    public func distanceFromLocation(location:CLLocation)->Double {
        let cLoc = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let m                           = cLoc.distanceFromLocation(location)
        return m * 0.000621371
    }
    
    public static func distance(location1:CLLocation, location2:CLLocation)->Double {
        let m                           = location1.distanceFromLocation(location2)
        return m * 0.000621371
    }
}
