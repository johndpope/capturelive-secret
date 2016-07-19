//
//  ScreenByPassableTests.swift
//  Current
//
//  Created by Scott Jones on 4/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureModel
import CaptureSync
@testable import CaptureCore

class ScreenByPassableTests: XCTestCase {

    var contextPassable:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        contextPassable        = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        contextPassable        = nil
        super.tearDown()
    }

    func testDefaultScreenByPassableIsFalse() {
        // given
        // when
        let isScreenByPassable = contextPassable.shouldByPass
        
        // then
        XCTAssertFalse(isScreenByPassable)
    }

    func testSetScreenByPassableToTrue() {
        // given
        // when
        contextPassable.performChanges {
            self.contextPassable.allowScreenByPass()
        }
        waitForManagedObjectContextToBeDone(contextPassable)
        
        // then
        let isScreenByPassable = contextPassable.shouldByPass
        XCTAssertTrue(isScreenByPassable)
    }
    
    func testSetScreenByPassableToFalse() {
        // given
        contextPassable.performChanges {
            self.contextPassable.allowScreenByPass()
        }
        waitForManagedObjectContextToBeDone(contextPassable)
        XCTAssertTrue(contextPassable.shouldByPass)

        // when
        contextPassable.performChanges {
            self.contextPassable.preventScreenByPass()
        }
        waitForManagedObjectContextToBeDone(contextPassable)
        
        // then
        let isScreenByPassable = contextPassable.shouldByPass
        XCTAssertFalse(isScreenByPassable)
    }
    
}
