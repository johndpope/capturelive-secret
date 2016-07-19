//
//  CMStillCameraUserDefaults.swift
//  Capture-Live
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

enum CMStillCameraConfigKey : String {
    case DevicePosition                             = "com.capturelive.stillcamera.deviceposition"
    case FlashMode                                  = "com.capturelive.stillcamera.flashmode"
}

struct CMStillCameraConfig {
    var devicePosition:AVCaptureDevicePosition
    var flashMode:AVCaptureFlashMode
    init(devicePosition:AVCaptureDevicePosition, flashMode : AVCaptureFlashMode) {
        self.devicePosition                         = devicePosition
        self.flashMode                              = flashMode
    }
}

extension NSUserDefaults {
    
    func saveStillCameraSettings(cameraSettings:CMStillCameraConfig) {
        self.setInteger(cameraSettings.devicePosition.rawValue, forKey:CMStillCameraConfigKey.DevicePosition.rawValue)
        self.setInteger(cameraSettings.flashMode.rawValue, forKey:CMStillCameraConfigKey.FlashMode.rawValue)
        self.synchronize()
    }
    
    func stillCameraSettings()->CMStillCameraConfig {
        let flashMode:AVCaptureFlashMode!           = AVCaptureFlashMode(rawValue:self.integerForKey(CMStillCameraConfigKey.FlashMode.rawValue))
        var devicePosition:AVCaptureDevicePosition! = AVCaptureDevicePosition(rawValue:self.integerForKey(CMStillCameraConfigKey.DevicePosition.rawValue))
        if devicePosition == AVCaptureDevicePosition.Unspecified {
            devicePosition                          = AVCaptureDevicePosition.Front
        }
        return CMStillCameraConfig(devicePosition: devicePosition, flashMode: flashMode)
    }
    
}
