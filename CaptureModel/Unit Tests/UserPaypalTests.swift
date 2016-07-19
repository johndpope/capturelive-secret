//
//  UserPaypalTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class UserPaypalTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testRemoteUserWillUpdatePaypalEmail() {
        // given
        var paypalJSON          = fakeUser
        paypalJSON["paypal_email"] = "hatebyte@gmail.com"
        paypalJSON["total_payments_made"] = 300
        
        // when
        let managedUser         = createUser(paypalJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedUser.paypalEmail, "hatebyte@gmail.com")
        XCTAssertEqual(managedUser.totalPaymentsMade, 300)
    }
    
    func testSavingAccessCodeMarksUserForRemoteValidation() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertTrue(User.notMarkedForNeedsPaypalVerificationPredicate.evaluateWithObject(managedUser))
 
        // when
        managedObjectContext.performChanges {
            managedUser.paypalAccessCode = "kick some ass bra"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(User.markedForNeedsPaypalVerificationPredicate.evaluateWithObject(managedUser))
        XCTAssertFalse(managedUser.needsPaypalEmail)
    }
    
    func testUnmarkingUserDeletesAccessCodeAndMarksNeedPaypalEmail() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.paypalAccessCode = "kick some ass bra"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // when 
        managedObjectContext.performChanges {
            managedUser.unMarkForNeedsPaypalVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // then
        XCTAssertNil(managedUser.paypalAccessCode)
        XCTAssertTrue(User.notMarkedForNeedsPaypalVerificationPredicate.evaluateWithObject(managedUser))
        XCTAssertTrue(User.markedForNeedsPaypalEmailPredicate.evaluateWithObject(managedUser))
    }
    
    func testMarkAsPaypalEmailVerifiedDoesNotReturenUser() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.paypalAccessCode = "kick some ass bra"
            managedUser.unMarkForNeedsPaypalVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedUser.markAsPaypalEmailVerified()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
       
        //
        XCTAssertTrue(User.notMarkedForNeedsPaypalEmailPredicate.evaluateWithObject(managedUser))
    }
    
    func testWhenUserJsonHasPaypalEmailUserIsPaypalVerified() {
        // given
        var paypalJSON          = fakeUser
        paypalJSON["paypal_email"] = "hatebyte@gmail.com"
        
        // when
        let managedUser         = createUser(paypalJSON, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(managedUser.needsPaypalEmail)
    }
    
}
