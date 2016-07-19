//
//  NSManagedObjectContext+DeviceUpdatable.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

extension NSManagedObjectContext : LocationRetrievable {
    
    public var coordinate:CLLocationCoordinate2D {
        get {
            let lat                     = metaData[CMUserMovementManager.CMLatitude] as? Double ?? 0.0
            let lon                     = metaData[CMUserMovementManager.CMLongitude] as? Double ?? 0.0
            return CLLocationCoordinate2D(latitude:lat, longitude:lon)
        }
        set {
            setMetaData(newValue.latitude, key: CMUserMovementManager.CMLatitude)
            setMetaData(newValue.longitude, key: CMUserMovementManager.CMLongitude)
        }
    }
    
    public var transportation:String {
        get {
            if let t = metaData[CMUserMovementManager.CMTransportation] as? String  {
                return t
            } else {
                return CMMotionTransportation.Automotive.rawValue
            }
        }
        set {
            setMetaData(newValue, key: CMUserMovementManager.CMTransportation)
        }
    }
    
    public var locationSpecs:[String:AnyObject] {
        return [
            "latitude"          : coordinate.latitude
            ,"longitude"        : coordinate.longitude
            ,"transportation"   : transportation
        ]
    }
    
}

private let ApplicationReportableMetaKey        = "com.current.applicationreportable.metakey"
private let DeviceReportableMetaKey             = "com.current.devicereportable.metakey"
extension NSManagedObjectContext : APIPersistable {
    
    public var model:String {
        return CMDevice.model()
    }
    
    public var carrier:String {
        return CMDevice.carrier()
    }
    
    public var uuid:String {
        return CMDevice.deviceUuid()
    }
    
    public var hdVideoWidth:Int32 {
        return CMDevice.hdVideoWidth()
    }
    
    public var hdVideoHeight:Int32 {
        return CMDevice.hdVideoHeight()
    }
    
    public var diskSpace:Int64 {
        return CMDisk.freeDiskSpaceMB()
    }
    
    public var batteryPercentage:Double {
        return CMDevice.battery()
    }
    
    public var deviceSpecs:[String:AnyObject] {
        get {
            guard let dSpecs = metaData[DeviceReportableMetaKey] as? [String:AnyObject] else {
                let specs = [
                    "model"             : model
                    ,"carrier"          : carrier
                    ,"uuid"             : uuid
                    ,"hd_video_width"   : NSNumber(int:hdVideoWidth)
                    ,"hd_video_height"  : NSNumber(int:hdVideoHeight)
                ]
                setMetaData(specs, key: DeviceReportableMetaKey)
                return specs
            }
            return dSpecs
        }
    }
    
    public var appVersionName:String {
        return NSBundle.mainBundle().appVersion
    }
    public var appName:String {
        return NSBundle.mainBundle().appIdentifier
    }
    
    public var appBuild:String {
        return NSBundle.mainBundle().appBuild
    }
    
    public func decryptDevicePushToken(data:NSData) {
        let tokenChars                              = UnsafePointer<CChar>(data.bytes)
        var deviceToken                             = ""
        
        for i in 0..<data.length {
            deviceToken += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print(deviceToken)
        pushToken                                   = deviceToken
    }
    
    public var pushToken:String? {
        get {
            return metaData[DevicePushToken] as? String
        }
        set {
            setMetaData(newValue, key:DevicePushToken)
        }
    }
    
    public var appSpecs:[String:AnyObject] {
        get {
            guard let dSpecs = metaData[ApplicationReportableMetaKey] as? [String:AnyObject] else {
                let specs = [
                    "app_version_name"  : appVersionName
                    ,"app_build"        : appBuild
                    ,"app_name"         : appName
                    ,"platform"         : "ios"
                ]
                setMetaData(specs, key: ApplicationReportableMetaKey)
                return specs
            }
            return dSpecs
        }
    }
    
    public var appSpecsWithToken:[String:AnyObject] {
        get {
            var specs                   = appSpecs
            guard let token = metaData[DevicePushToken] as? String else {
                return appSpecs
            }
            specs["push_token"]         = token
            return specs
        }
    }
    
}


