//
//  OnboardingByPassableTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import XCTest
import CoreData
import CaptureModel
import CaptureSync
@testable import CaptureCore

class OnboardingByPassableTests: XCTestCase {
    
    var contextPassable:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        contextPassable        = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        contextPassable        = nil
        super.tearDown()
    }
    
    func testDefaultOnboardingByPassableIsFalse() {
        // given
        // when
        let canByPassOnboarding = contextPassable.canByPassOnboarding
        
        // then
        XCTAssertFalse(canByPassOnboarding)
    }
    
    func testSetOnboardingByPassableToTrue() {
        // given
        // when
        contextPassable.performChanges {
            self.contextPassable.allowOnboardingByPass()
        }
        waitForManagedObjectContextToBeDone(contextPassable)
        
        // then
        let canByPassOnboarding = contextPassable.canByPassOnboarding
        XCTAssertTrue(canByPassOnboarding)
    }
    
}
