//
//  ByPassReelTests.swift
//  Current
//
//  Created by Scott Jones on 4/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureCore
import CaptureModel
import CaptureSync
@testable import CaptureLive

class ByPassReelTests: XCTestCase {
    
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
   
    func userNeedsFinishCreateReel(){
        attemptLoginUser(needsCreateReel, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func testMethod_canByPassReelFalseWithNoReel() {
        // given
        userNeedsFinishCreateReel()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastReelCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastReelCreation_FAILS_markedForRemoteUpdate() {
        // given
        userNeedsFinishCreateReel()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let website:[String:AnyObject] = [
                "source"    : "personal"
                ,"type"     : "url"
                ,"value"    : "www.ericshu_mania.com"
            ]
            let instagram:[String:AnyObject] = [
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "2Chus"
            ]
            let reel = [website, instagram]
            user.workReel = reel.toReelArray()
        }

        // when
        var returnValue = false
        hasEnoughToGetPastReelCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastReelCreation_PASS() {
        // given
        userNeedsFinishCreateReel()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        

        // when
        addToAttemptingUser(managedObjectContext) { user in
            let website:[String:AnyObject] = [
                "source"    : "personal"
                ,"type"     : "url"
                ,"value"    : "www.ericshu_mania.com"
            ]
            let instagram:[String:AnyObject] = [
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "2Chus"
            ]
            let reel = [website, instagram]
            user.workReel = reel.toReelArray()
        }
        addToAttemptingUser(managedObjectContext) { user in
            user.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        var returnValue = false
        hasEnoughToGetPastReelCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }
    
    func testMethod_canByPassReelFalseIfNoToken() {
        // given
        userNeedsFinishCreateReel()
       
        addToAttemptingUser(managedObjectContext) { user in
            let website:[String:AnyObject] = [
                "source"    : "personal"
                ,"type"     : "url"
                ,"value"    : "www.ericshu_mania.com"
            ]
            let instagram:[String:AnyObject] = [
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "2Chus"
            ]
            let reel = [website, instagram]
            user.workReel = reel.toReelArray()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastReelCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertFalse(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_canByPassReelTrueWithReel_FAILS_shouldNotByPass() {
        // given
        userNeedsFinishCreateReel()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        preventScreenByPass(managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let website:[String:AnyObject] = [
                "source"    : "personal"
                ,"type"     : "url"
                ,"value"    : "www.ericshu_mania.com"
            ]
            let instagram:[String:AnyObject] = [
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "2Chus"
            ]
            let reel = [website, instagram]
            user.workReel = reel.toReelArray()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastReelCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
}




















