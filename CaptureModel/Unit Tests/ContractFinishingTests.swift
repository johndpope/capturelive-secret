//
//  ContractFinishingTests.swift
//  Current
//
//  Created by Scott Jones on 4/7/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class ContractFinishingTests: XCTestCase {
    
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
    
    func createAnAcquiredContract()->Contract {
        return createContract(acquiredContract, moc:managedObjectContext)
    }
    
    func unmarkContract(contract:Contract) {
//        managedObjectContext.performChanges {
//            contract.unMarkForNeedsNotificationForAcquirement()
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func testContractDefaultsToNotMarkedForRemoteVerification() {
        // given
        let contract = createAnAcquiredContract()
        
        // when 
        
        // then
        XCTAssertTrue(Contract.notMarkedForRemoteVerificationPredicate.evaluateWithObject(contract))
    }
    
    func testContractMarkedForRemoteVerificationWhenResolutionChangedToUserCanceled() {
        // given
        let contract:Contract = createAnAcquiredContract()
        
        // when
        managedObjectContext.performChanges {
            contract.resolutionStatus = .UserCanceled
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(contract))
    }
    
    func testChangingStartedMarksContractForRemoteValidation() {
        // given
        var c = acquiredContract
        c["started"] = false
        let contract:Contract = createContract(c, moc:managedObjectContext)
        managedObjectContext.performChanges {
            contract.unMarkForNeedsRemoteCompletion()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            contract.start()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(contract))
    }
    
    func testContractMarkedForRemoteVerificationWhenResolutionChangedToCompleted() {
        // given
        let contract = createAnAcquiredContract()
        
        // when
        managedObjectContext.performChanges {
            contract.resolutionStatus = .Completed
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(contract))
    }
    
    // showing contracts
    func testContractEndedPredicateIsTrueWhenPublisherCanceled() {
        // given
        let acqContract         = createAnAcquiredContract()
        unmarkContract(acqContract)
        
        // when
        var theAcquiredContract = acquiredContract
        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        theAcquiredContract["resolution"] = "publisher_canceled"
        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.isNotOpenPredicate.evaluateWithObject(acqContractAgain))
        XCTAssertFalse(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(acqContractAgain))

    }

    func testContractEndedPredicateIsTrueWhenUserCanceled() {
        // given
        let acqContract         = createAnAcquiredContract()
        unmarkContract(acqContract)
        
        // when
        var theAcquiredContract = acquiredContract
        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        theAcquiredContract["resolution"] = "user_canceled"
        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.isNotOpenPredicate.evaluateWithObject(acqContractAgain))
        XCTAssertFalse(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(acqContractAgain))
    }
    
    func testContractEndedPredicateIsTrueWhenCompleted() {
        // given
        let acqContract         = createAnAcquiredContract()
        unmarkContract(acqContract)
        
        // when
        var theAcquiredContract = acquiredContract
        theAcquiredContract["unix_updated_at"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        theAcquiredContract["resolution"] = "completed"
        let acqContractAgain    = createContract(theAcquiredContract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Contract.isNotOpenPredicate.evaluateWithObject(acqContractAgain))
        XCTAssertFalse(Contract.markedForRemoteVerificationPredicate.evaluateWithObject(acqContractAgain))
    }


    
    // isNotOpen

    // delete contract
    // open
    // event is past hiring cutoff date
    
}
