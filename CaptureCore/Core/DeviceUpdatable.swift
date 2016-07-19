//
//  DeviceUpdatable.swift
//  Current
//
//  Created by Scott Jones on 3/25/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreLocation

public let DevicePushToken                      = "com.capture.ios.devicepushtoken.key"


public protocol LocationRetrievable {
    var coordinate:CLLocationCoordinate2D { get set }
    var transportation:String { get set }
    var locationSpecs:[String:AnyObject] { get }
}

extension LocationRetrievable {
    var locationSpecs:[String:AnyObject] {
        return [
            "latitude"          : coordinate.latitude
            ,"longitude"        : coordinate.longitude
            ,"transportation"   : transportation
        ]
    }
}

public protocol DeviceReportable {
    var model:String { get }
    var carrier:String { get }
    var uuid:String { get }
    var hdVideoWidth:Int32 { get }
    var hdVideoHeight:Int32 { get }
    var diskSpace:Int64 { get }
    var batteryPercentage:Double { get }
    var deviceSpecs:[String:AnyObject] { get }
    var liveDeviceSpecs:[String:AnyObject] { get }
}

extension DeviceReportable {
    
    public var liveDeviceSpecs:[String:AnyObject] {
        let batteryAndMemory = ["disk_space":NSNumber(longLong:diskSpace), "battery_percentage":NSNumber(double:batteryPercentage)]
        return deviceSpecs.union(batteryAndMemory)
    }
    
}

public protocol ApplicationReportable {
    var appVersionName:String { get }
    var appName:String { get }
    var appBuild:String { get }
    var pushToken:String? { get set }
    var appSpecs:[String:AnyObject] { get }
    var appSpecsWithToken:[String:AnyObject] { get }
}

public protocol APIPersistable : AccessTokenRetrivable, ApplicationReportable, DeviceReportable {
    
}




