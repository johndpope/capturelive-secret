//
//  ContractHiredTests.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class ContractHiredTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        waitForManagedObjectContextToBeDone(managedObjectContext)
        managedObjectContext    = nil
        super.tearDown()
    }
    
//    func createAnAcquiredContract(moc:NSManagedObjectContext)->Contract {
//        let _                   = createContract(unacquiredContract, moc:managedObjectContext)
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().timeIntervalSince1970
//        return createContract(theAcquiredContract, moc:managedObjectContext)
//    }
    
    func unmarkContract(contract:Contract) {
//        managedObjectContext.performChanges {
//            contract.unMarkForNeedsNotificationForAcquirement()
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
    }

//    func testUnacquiredJSONMarkedForNeedsToSeeHiredPredicateIsDefaultedToFalse() {
//        // given
//        let unacqContract       = createContract(unacquiredContract, moc:managedObjectContext)
//        
//        // when
//        
//        // then
//        XCTAssertFalse(unacqContract.acquired)
//        XCTAssertTrue(Contract.unMarkedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(unacqContract))
//        XCTAssertTrue(Contract.canBeMarkedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(unacqContract))
//    }

//    func testAcquiredJSONMarksAContractForNeedsReminder() {
//        // given
//        let unacqContract       = createContract(unacquiredContract, moc:managedObjectContext)
//        
//        // when
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().timeIntervalSince1970
//        let acqContract         = createContract(theAcquiredContract, moc:managedObjectContext)
//        
//        // then 
//        XCTAssertEqual(unacqContract, acqContract)
//        XCTAssertTrue(acqContract.acquired)
//        XCTAssertTrue(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContract))
//        XCTAssertFalse(Contract.canBeMarkedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContract))
//    }

//    func testAcquiredJSONMarkedForNeedsToSeeHiredPredicateCanBeAcknowledge() {
//        // given
//        let acqContract         = createAnAcquiredContract()
//        XCTAssertTrue(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContract))
//        
//        // when
//        unmarkContract(acqContract)
//        
//        // then
//        XCTAssertTrue(acqContract.acquired)
//        XCTAssertTrue(Contract.markedForAcknowledgedAcquiredNotificationPredicate.evaluateWithObject(acqContract))
//        XCTAssertFalse(Contract.canBeMarkedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContract))
//    }
    
//    func testAcquiredJSONMarkedForNeedsToSeeHiredPredicateCantBeSetAfterAcknowledgement() {
//        // given
//        let acqContract         = createAnAcquiredContract()
//        unmarkContract(acqContract)
//        
//        // when
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
//        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
//        
//        // then
//        XCTAssertFalse(Contract.canBeMarkedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContractAgain))
//        XCTAssertFalse(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContractAgain))
//    }
//    
//    func testAcquiredJSONMarkedForNeedsToSeeHiredPredicateCantBeSetIfCompleted() {
//        // given
//        let acqContract         = createAnAcquiredContract()
//        unmarkContract(acqContract)
//        
//        // when
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
//        theAcquiredContract["resolution"] = "completed"
//        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
//        
//        // then
//        XCTAssertFalse(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContractAgain))
//    }
//    
//    func testAcquiredJSONMarkedForNeedsToSeeHiredPredicateCantBeSetIfUserCanceled() {
//        // given
//        let acqContract         = createAnAcquiredContract()
//        unmarkContract(acqContract)
//        
//        // when
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
//        theAcquiredContract["resolution"] = "user_canceled"
//        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
//        
//        // then
//        XCTAssertFalse(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContractAgain))
//    }
//    
//    func testAcquiredJSONMarkedForNeedsToSeeHiredPredicateCantBeSetIfPublisherCanceled() {
//        // given
//        let acqContract         = createAnAcquiredContract()
//        unmarkContract(acqContract)
//        
//        // when
//        var theAcquiredContract = acquiredContract
//        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
//        theAcquiredContract["resolution"] = "publisher_canceled"
//        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
//        
//        // then
//        XCTAssertFalse(Contract.markedForNeedsNotificationForAcquirementPredicate.evaluateWithObject(acqContractAgain))
//    }

}
