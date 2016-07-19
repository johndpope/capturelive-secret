//
//  PermissionsTests.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureCore

class PermissionsTests: XCTestCase {
    
    var managedObjectContext:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
    func testLocationsPermissionsBoolIsDefaultNil() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        let hasBeenAskedForLocationInformation = managedObjectContext.hasBeenAskedForLocationInformation
        
        // then
        XCTAssertFalse(hasBeenAskedForLocationInformation)
    }
    
    
    func testCanUpdateLocationsPermissionsBool() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.saveHasBeenAskedForLocationInformation()
        
        // then
        XCTAssertTrue(managedObjectContext.hasBeenAskedForLocationInformation)
    }
   
    func testPushPermissionsBoolIsDefaultNil() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        let hasBeenAskedForPushNotifications = managedObjectContext.hasBeenAskedForPushNotifications
        
        // then
        XCTAssertFalse(hasBeenAskedForPushNotifications)
    }
    
    
    func testCanUpdatePushPermissionsBool() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.saveHasBeenAskForPushNotifications()
        
        // then
        XCTAssertTrue(managedObjectContext.hasBeenAskedForPushNotifications)
    }

    func testLastUsedNumberIsDefaultNil() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        
        // then
        XCTAssertNil(managedObjectContext.lastUsedNumber)
    }
    
    
    func testCanUpdateLastUsedNumber() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.setLastUsedNumber("9085818600")
        
        // then
        XCTAssertEqual("9085818600", managedObjectContext.lastUsedNumber)
    }
    
    
    func testDeviceTokenIsDefaultNil() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        
        // then
        XCTAssertNil(managedObjectContext.pushToken)
    }
    
    
    func testCanUpdateDeviceToken() {
        // given
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.pushToken = "9085818600908581860090858186009085818600"
        
        // then
        XCTAssertEqual("9085818600908581860090858186009085818600", managedObjectContext.pushToken)
    }
}
