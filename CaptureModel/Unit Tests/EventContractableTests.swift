//
//  EventContractCreatableTests.swift
//  Current
//
//  Created by Scott Jones on 3/27/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class EventContractableTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext        = nil
        super.tearDown()
    }
    
    // CREATE CONTRACT
    func testMarkedForCreateContractPredicate() {
        // given
        var eJSON                   = eventJSON
        eJSON["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        let managedEvent            = createEvent(eJSON, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedEvent.needsToCreateRemoteContract = true
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Event.needsToCreateContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testMarkForCreateContractPredicateFalseIfPassedHiringCutoff() {
        // given
        var eJSON                   = eventJSON
        eJSON["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970
        let managedEvent            = createEvent(eJSON, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedEvent.needsToCreateRemoteContract = true
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.needsToCreateContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testMarkForCreateContractPredicateFalseIfHasContract() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedContract.event.needsToCreateRemoteContract = true
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.needsToCreateContractPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testCanMarkForCreateContractReturnsFalseIfHasContract() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.canMarkForCreateRemoteContractPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testCanMarkForCreateContractReturnsFalseItIsPassedHiringCutoff() {
        // given
        var eJSON                   = eventJSON
        eJSON["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970

        // when
        let managedEvent            = createEvent(eJSON, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.canMarkForCreateRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testCanMarkForCreateContractReturnsFalseItIsAlreadyMarkedForCreateRemoteContract() {
        // given
        var eJSON                   = eventJSON
        eJSON["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        let managedEvent            = createEvent(eJSON, moc:managedObjectContext)
 
        // when
        managedObjectContext.performChanges {
            managedEvent.needsToCreateRemoteContract = true
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // then
        XCTAssertFalse(Event.canMarkForCreateRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testCanMarkForCreateContract() {
        // given
        var eJSON                   = eventJSON
        eJSON["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        let managedEvent            = createEvent(eJSON, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedEvent.needsToCreateRemoteContract = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Event.canMarkForCreateRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    
    // DELETE CONTRACT
    func testNeedsToDeleteRemoteContractPredicateIsTrueWhenMarkedForDelete() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        managedObjectContext.performChanges {
            managedEvent.markForNeedsToDeleteRemoteContract()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Event.needsToDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testNeedsToDeleteRemoteContractPredicateIsFalseIfNoContractLocallyAndNotMarkedForContractCreation() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        managedObjectContext.performChanges { 
            managedEvent.markForNeedsRemoteContract()
            managedEvent.markForNeedsToDeleteRemoteContract()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.needsToDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }

    func testCanMarkForNeedsDeleteRemoteContractReturnsTrue() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        
        
        // then
        XCTAssertTrue(Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testCanMarkForNeedsDeleteRemoteContractReturnsFalseIfNoContract() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        managedObjectContext.performChanges { [unowned self] in
            self.managedObjectContext.deleteObject(managedEvent.contract!)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }

    func testCanMarkForNeedsDeleteRemoteContractReturnsFalseIfMarkedForNeedsToCreateRemoteContract() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        managedObjectContext.performChanges {
            managedEvent.markForNeedsRemoteContract()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testCanMarkForNeedsDeleteRemoteContractReturnsFalseIfMarkedForNeedsToDeleteRemoteContract() {
        // given
        let managedEvent = createAcceptedUnacquiredEventInFuture()
        
        // when
        managedObjectContext.performChanges {
            managedEvent.markForNeedsToDeleteRemoteContract()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
    func testCanMarkForNeedsDeleteRemoteContractReturnsFalseIfContractIsAcquired() {
        // given
        let managedEvent = createAcceptedAcquiredEventInFuture()
        
        // when
        
        // then
        XCTAssertFalse(Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(managedEvent))
    }
    
}


extension EventContractableTests {

    func createAcceptedUnacquiredEventInFuture()->Event {
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = false
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        return managedContract.event
    }
   
    func createAcceptedAcquiredEventInFuture()->Event {
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        return managedContract.event
    }

}



















