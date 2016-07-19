//
//  ByPassEquipmentTests.swift
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

class ByPassEquipmentTests: XCTestCase {
    
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

    func userNeedsFinishCreateEquiment(){
        attemptLoginUser(needsCreateEquipment, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
   
    func testMethod_canByPassEquipmentFalseWithNoEquipment() {
        // given
        userNeedsFinishCreateEquiment()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastEquipmentCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastEquipmentCreation_FAIL_markedForSync() {
        // given
        userNeedsFinishCreateEquiment()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let eq = [
                "smartphone_lens"
                ,"steadicam"
                ,"smartphone_tripod"
                ,"selfie_stick"
                ,"pocket_spotlight"
                ,"portable_battery_charger"
                ,"boom_mic"
                ]
            user.equipment = eq.toEquipmentArray()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastEquipmentCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToGetPastEquipmentCreation_PASS() {
        // given
        userNeedsFinishCreateEquiment()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        // when
        addToAttemptingUser(managedObjectContext) { user in
            let eq = [
                "smartphone_lens"
                ,"steadicam"
                ,"smartphone_tripod"
                ,"selfie_stick"
                ,"pocket_spotlight"
                ,"portable_battery_charger"
                ,"boom_mic"
                ]
            user.equipment = eq.toEquipmentArray()
        }
        addToAttemptingUser(managedObjectContext) { user in
            user.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        var returnValue = false
        hasEnoughToGetPastEquipmentCreation(remoteAndLocalService) {
            returnValue = true
        }
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }

    
    func testMethod_canByPassEquipmentTrueWithEquipment_FAILS_shouldNotByPass() {
        // given
        userNeedsFinishCreateEquiment()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        preventScreenByPass(managedObjectContext)
        
        addToAttemptingUser(managedObjectContext) { user in
            let eq = [
                "smartphone_lens"
                ,"steadicam"
                ,"smartphone_tripod"
                ,"selfie_stick"
                ,"pocket_spotlight"
                ,"portable_battery_charger"
                ,"boom_mic"
                ]
            user.equipment = eq.toEquipmentArray()
        }
        
        // when
        var returnValue = false
        hasEnoughToGetPastEquipmentCreation(remoteAndLocalService) {
            returnValue = true
        }
        
        // then
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    

}
