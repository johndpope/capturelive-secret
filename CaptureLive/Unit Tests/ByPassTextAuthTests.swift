//
//  ByPassTextAuthTests.swift
//  Current
//
//  Created by Scott Jones on 4/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureCore
import CaptureModel
import CaptureSync
@testable import CaptureLive

class ByPassTextAuthTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    var consoleRemote :ConsoleRemote!
    var remoteAndLocalService:FakeRemoteAndLocallyService!
    
    override func setUp() {
        super.setUp()
        managedObjectContext        = NSManagedObjectContext.currentInMemoryContext()
        consoleRemote               = ConsoleRemote(persistanceLayer:managedObjectContext)
        remoteAndLocalService       = FakeRemoteAndLocallyService(managedObjectContext: managedObjectContext, remoteService: consoleRemote)
        allowScreenByPass(managedObjectContext)
    }
    
    override func tearDown() {
        managedObjectContext        = nil
        super.tearDown()
    }

    func userNeedsFinishedFacebookAndProfile() {
        attemptLoginUser(needsFacebookProfile, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func testMethod_hasEnoughToByPassPhoneLogin_FAIL_User() {
        // given
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        // when
        var returnValue = false
        hasEnoughToByPassPhoneLogin(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }

    func testMethod_hasEnoughToByPassPhoneLogin_PASS() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        // when
        addToAttemptingUser(managedObjectContext) { user in
            user.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        var returnValue = false
        hasEnoughToByPassPhoneLogin(remoteAndLocalService) {
            returnValue = true
        }
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }

}
