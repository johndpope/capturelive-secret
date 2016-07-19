//
//  DeviceReportableTests.swift
//  Current
//
//  Created by Scott Jones on 3/25/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureModel
import CaptureSync
@testable import CaptureCore

class DeviceReportableTests: XCTestCase {

    var deviceReportable:DeviceReportable!
    var context:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        deviceReportable        = NSManagedObjectContext.currentInMemoryContext()
        context                 = deviceReportable as! NSManagedObjectContext
    }
    
    override func tearDown() {
        deviceReportable        = nil
        super.tearDown()
    }

    func testGettingDeviceSpecsCachesDictionary() {
        // given
        
        // when
        let ds                  = deviceReportable.deviceSpecs
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
 
        // then
        let fromCache = context.metaData["com.current.devicereportable.metakey"] as! [String:AnyObject]
        XCTAssertNotNil(fromCache)
        XCTAssertEqual(ds["carrier"] as? String, fromCache["carrier"] as? String)
    }
    
    func testGettingLiveDeviceSpecsIncludesBatteryAndMemory() {
        // given
        
        // when
        let liveSpecs           = deviceReportable.liveDeviceSpecs
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
        
        // then
        XCTAssertNotNil(liveSpecs)
        XCTAssertTrue(liveSpecs["disk_space"] as! Int > 0)
        XCTAssertTrue(liveSpecs["battery_percentage"] as! Double > 0)
    }

}
