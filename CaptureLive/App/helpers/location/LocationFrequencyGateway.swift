//
//  ContractLocationGateway.swift
//  Current
//
//  Created by hatebyte on 7/13/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

public class LocationFrequencyGateway: NSObject, ManagedObjectContextSettable {
    public class var shared:LocationFrequencyGateway {
        struct Singleton {
            static let instance = LocationFrequencyGateway()
        }
        return Singleton.instance
    }
    
    var locationGateway:LocationGateway = LocationGateway()
    var managedObjectContext: NSManagedObjectContext!
    
    public func trackLocation() {
        if let _ = Contract.fetchActiveContract(managedObjectContext)  {
            self.locationGateway.startTrackingPreciseLocation()
        } else {
            self.locationGateway.startTrackingSemiPreciseLocation()
        }
    }
    
    public func trackSignificantLocation() {
        self.locationGateway.startTrackingSignificantLocation()
    }
    
    public func stopTrackingBackgroundLocation() {
        self.locationGateway.stopBackgroundTracking()
    }
    
    public func stopTrackingSignificantLocation() {
        self.locationGateway.stopTrackingSignificantLocation()
    }
    
}
