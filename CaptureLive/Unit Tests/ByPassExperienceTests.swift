//
//  ByPassExperience.swift
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

class ByPassExperienceTests: XCTestCase {
    
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
    
    func userNeedsFinishCreateExperience(){
        attemptLoginUser(needsCreateExperience, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
   
    func testMethod_canByPassExperienceFalseWithNoExperience() {
        // given
        userNeedsFinishCreateExperience()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastExperienceCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastExperienceCreation_FAILS_markedForSync() {
        // given
        userNeedsFinishCreateExperience()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let expDict = [
                "level": 1
                ,"categories":[
                    "sporting_events"
                    ,"concerts"
                    ,"celebrities"
                    ,"red_carpet_events"
                    ,"breaking_news"
                    ,"weather"
                ]
            ]
            user.experience = expDict.toExperience()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastExperienceCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastExperienceCreation_PASS() {
        // given
        userNeedsFinishCreateExperience()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        // when
        addToAttemptingUser(managedObjectContext) { user in
            let expDict = [
                "level": 1
                ,"categories":[
                    "sporting_events"
                    ,"concerts"
                    ,"celebrities"
                    ,"red_carpet_events"
                    ,"breaking_news"
                    ,"weather"
                ]
            ]
            user.experience = expDict.toExperience()
        }
        addToAttemptingUser(managedObjectContext) { user in
            user.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        var returnValue = false
        hasEnoughToGetPastExperienceCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }
    
    func testMethod_canByPassExperienceTrueWithExperience_FAILS_shouldNotByPass() {
        // given
        userNeedsFinishCreateExperience()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        preventScreenByPass(managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let expDict = [
                "level": 1
                ,"categories":[
                    "sporting_events"
                    ,"concerts"
                    ,"celebrities"
                    ,"red_carpet_events"
                    ,"breaking_news"
                    ,"weather"
                ]
            ]
            user.experience = expDict.toExperience()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastExperienceCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
  
}
