//
//  ByPassCreateProfileTests.swift
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

class ByPassCreateProfileTests: XCTestCase {
    
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
    
    func userNeedsFinishCreateProfile(){
        attemptLoginUser(needsCreateProfile, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func userNeedsFinishCreateReel(){
        attemptLoginUser(needsCreateReel, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func testMethod_enoughToPassPhoneLongin() {
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
    
    
    func testMethod_hasEnoughToSkipProfileCreation_false_noTermsAndConditions_NoPermissions() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
//        managedObjectContext.performChanges {
//            managedObjectContext
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToSkipProfileCreation_false_hasTermsAndConditions_NoPermissions() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        managedObjectContext.performChanges {
            attemptingloggedInUser.acceptTermsAndConditions()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToSkipProfileCreation_false_hasTermsAndConditions_NoLocationPermissions() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)

        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        managedObjectContext.performChanges { [unowned self] in
            attemptingloggedInUser.acceptTermsAndConditions()
            self.managedObjectContext.saveHasBeenAskForPushNotifications()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
   
    func testMethod_hasEnoughToSkipProfileCreation_false_hasTermsAndConditions_NoPushPermissions() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        managedObjectContext.performChanges { [unowned self] in
            attemptingloggedInUser.acceptTermsAndConditions()
            self.managedObjectContext.saveHasBeenAskedForLocationInformation()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)

        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }
    
    func testMethod_hasEnoughToSkipProfileCreation_true_hasTermsAndConditions_HasBothPermissions_ButHasError() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        managedObjectContext.performChanges { [unowned self] in
            attemptingloggedInUser.acceptTermsAndConditions()
            self.managedObjectContext.saveHasBeenAskedForLocationInformation()
            self.managedObjectContext.saveHasBeenAskForPushNotifications()
            attemptingloggedInUser.validationError = ["barf":"scenario"]
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // when
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertFalse(returnValue)
    }

    func testMethod_hasEnoughToSkipProfileCreation_true_hasTermsAndConditions_HasBothPermissions_HasNoError() {
        // given
        userNeedsFinishCreateProfile()
        validateApiToken(consoleRemote, moc: managedObjectContext)
        
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        managedObjectContext.performChanges { [unowned self] in
            attemptingloggedInUser.acceptTermsAndConditions()
            self.managedObjectContext.saveHasBeenAskedForLocationInformation()
            self.managedObjectContext.saveHasBeenAskForPushNotifications()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let returnValue = hasAcceptedTermsAndBeenAskedForPermissions(remoteAndLocalService)
        
        // then
        XCTAssertNotNil(attemptingloggedInUser)
        XCTAssertTrue(consoleRemote.hasAccessToken)
        XCTAssertTrue(returnValue)
    }

}
