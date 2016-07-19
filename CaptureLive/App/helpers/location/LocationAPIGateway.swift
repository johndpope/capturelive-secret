//
//  ContractLocationAPIGateway.swift
//  Current
//
//  Created by hatebyte on 7/16/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

public class LocationAPIGateway: LocationGateway, RemoteServiceable {
    
    var remoteService:CaptureLiveRemoteType!
    
    public init(remote syncremote: CaptureLiveRemoteType) {
        self.remoteService              = syncremote
        super.init()
    }
 
    public override func callback(location:CLLocation, transportation:CMMotionTransportation, com:ValidUpdate) {
        if self.hasTraveledEnough(location) == true {
            self.remoteService.updateDeviceData(location.coordinate.latitude, longitude:location.coordinate.longitude) { error in
                if let _ = error {
                    com(false)
                } else {
                    com(true)
                }
            }
            
        } else {
            com(false)
        }
    }

}

