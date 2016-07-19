//
//  CMDevice.swift
//  Current
//
//  Created by hatebyte on 8/19/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit


public enum CMBattery {
    case GOOD(percent:Double)
    case LOW(percent:Double)
}

public enum CMDiskSpace {
    case GOOD(storage:Int64)
    case LOW(storage:Int64)
    case NONE(storage:Int64)
}

public struct CMDeviceSpecs {
    var storageValueString:String!
    var storageString:String!
    var batteryValueString:String!
    var batteryString:String!
    var storageColor:UIColor!
    var batteryColor:UIColor!
//    var storageImage:String!
//    var batteryImage:String!
}

public class CMDeviceViewModel {
    
    public static func data()->CMDeviceSpecs {
        let battery                     = self.battery()
        let storage                     = self.storage()
        var specs                       = CMDeviceSpecs()
        
        switch battery {
        case .GOOD(let percent):
            specs.batteryValueString    = "\(Int(percent)) %"
            specs.batteryColor          = UIColor.darkGrayColor()
//            specs.batteryImage          = UIImage.iconBatteryGoodString()
            break
        case .LOW(let percent):
            specs.batteryValueString    = "\(Int(percent)) %"
            specs.batteryColor          = UIColor.redColor()
//            specs.batteryImage          = UIImage.iconBatteryBadString()
            break
        }
        
        switch storage {
        case .GOOD( _):
            specs.storageValueString    = NSLocalizedString("GOOD", comment: "CMDevice : StorageValueString : good")
            specs.storageColor          = UIColor.darkGrayColor()
//            specs.storageImage          = UIImage.iconStorageGoodString()
            break
        case .LOW( _):
            specs.storageValueString    = NSLocalizedString("LOW", comment: "CMDevice : StorageValueString : low")
            specs.storageColor          = UIColor.redColor()
//            specs.storageImage          = UIImage.iconStorageBadString()
            break
        case .NONE( _):
            specs.storageString         = NSLocalizedString("NONE", comment: "CMDevice : StorageValueString : none")
            specs.storageColor          = UIColor.redColor()
//            specs.storageImage          = UIImage.iconStorageBadString()
            break
        }
        
        specs.storageString             = NSLocalizedString("storage", comment: "CMDevice : StorageString")
        specs.batteryString             = NSLocalizedString("battery", comment: "CMDevice : BatteryString")

        return specs
    }
    
    public static func dataDict()->[NSObject:AnyObject] {
        let data                        = self.data()
        let dict = [
             "storageValueString"       : data.storageValueString
            ,"storageString"            : data.storageString
            ,"batteryValueString"       : data.batteryValueString
            ,"batteryString"            : data.batteryString
            ,"storageColor"             : data.storageColor
            ,"batteryColor"             : data.batteryColor
//            ,"storageImage"             : data.storageImage
//            ,"batteryImage"             : data.batteryImage
        ]
        return dict as [NSObject:AnyObject]
    }
    
    public static func battery()->CMBattery {
        let percentB                    = CMDevice.battery()
        if percentB > 34 {
            return CMBattery.GOOD(percent:Double(percentB))
        } else {
            return CMBattery.LOW(percent:Double(percentB))
        }
    }
    
    public static func storage()->CMDiskSpace {
        let storageB                = CMDisk.freeDiskSpaceMB()
        if storageB > 500 {
            return CMDiskSpace.GOOD(storage:storageB)
        } else if storageB < 500 && storageB > 150 {
            return CMDiskSpace.LOW(storage:storageB)
        } else {
            return CMDiskSpace.NONE(storage:storageB)
        }
    }
    
}
