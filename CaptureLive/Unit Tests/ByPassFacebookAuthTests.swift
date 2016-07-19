//
//  ByPassFacebookAuthTests.swift
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

class ByPassFacebookAuthTests: XCTestCase {
    
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
    
    func testMethod_hasEnoughToSkipFacebookAuth_FAILS_NotEnoughFacebookData() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        
        
        // when
        var returnValue = false
        hasEnoughToGetPastFaceBook(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToSkipFacebookAuth_FAILS_ValidationError() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        addToAttemptingUser(managedObjectContext) { user in
            user.validationError = ["error" : "OMFG ERRROR"]
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastFaceBook(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func test_hasEnoughToSkipFacebookAuth_FAIL_markedForRemoteValidation() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        addToAttemptingUser(managedObjectContext) { user in
            user.facebookAuthToken = "MA BALLS AGAIN"
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastFaceBook(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func test_hasEnoughToSkipFacebookAuth_PASS() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        
        // when
        addToAttemptingUser(managedObjectContext) { user in
            user.facebookAuthToken = "MA BALLS AGAIN"
        }
        addToAttemptingUser(managedObjectContext) { user in
            user.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        var returnValue = false
        hasEnoughToGetPastFaceBook(remoteAndLocalService) {
            returnValue = true
        }
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }
 
    func test_hasEnoughToSkipFacebookAuth_FAILS_shouldNotByPass() {
        // given
        userNeedsFinishedFacebookAndProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        preventScreenByPass(managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            user.facebookAuthToken = "MA BALLS AGAIN"
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastFaceBook(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
}
