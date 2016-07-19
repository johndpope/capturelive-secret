//
//  LocationUpdatableTests.swift
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

class LocationRetrievableTests: XCTestCase {
    
    var locationUpdatable:LocationRetrievable!
    
    override func setUp() {
        super.setUp()
        self.locationUpdatable = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        self.locationUpdatable = nil
        super.tearDown()
    }
  
    func testLocationUpdatableCoordinateIsZeroZero() {
        // given
        // when
        
        // then
        XCTAssertNotNil(locationUpdatable.coordinate)
        XCTAssertEqual(locationUpdatable.coordinate.latitude, 0.0)
        XCTAssertEqual(locationUpdatable.coordinate.longitude, 0.0)
    }

    func testLocationUpdatableCanStoreLocation() {
        // given
        let coordinate = CLLocationCoordinate2D(latitude: 100.0, longitude: 200.0)

        // when
        locationUpdatable.coordinate = coordinate
        
        // then
        XCTAssertNotNil(locationUpdatable.coordinate)
        XCTAssertEqual(locationUpdatable.coordinate.longitude, coordinate.longitude)
    }
   
    func testLocationUpdateableReturnsFormattedDeviceSpecs() {
        // given
        let coordinate = CLLocationCoordinate2D(latitude: 100.0, longitude: 200.0)
        locationUpdatable.coordinate = coordinate
        locationUpdatable.transportation = "car"
 
        // when
        let locationSpecs = locationUpdatable.locationSpecs
        
        // then
        XCTAssertEqual(locationSpecs["latitude"] as? Double, coordinate.latitude)
        XCTAssertEqual(locationSpecs["longitude"] as? Double, coordinate.longitude)
        XCTAssertEqual(locationSpecs["transportation"] as? String, "car")
    }
    
}
