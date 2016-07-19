//
//  EventTests.swift
//  Current
//
//  Created by Scott Jones on 3/22/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class EventTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext        = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext        = nil
        super.tearDown()
    }
    
    func testEventJsonTransformsToRemoteEvent() {
        // given
        
        // when
        let remoteEvent             = RemoteEvent(event:eventJSON)
        
        // then
        XCTAssertEqual(remoteEvent.urlHash, "b8f20al")
        XCTAssertEqual(remoteEvent.createdAt, NSDate(timeIntervalSince1970: 1457708802))
        XCTAssertEqual(remoteEvent.updatedAt, NSDate(timeIntervalSince1970: 1458678297))
        XCTAssertEqual(remoteEvent.detailDescription, "Don't forget ice")
        XCTAssertEqual(remoteEvent.latitude, 40.721935965506)
        XCTAssertEqual(remoteEvent.longitude, -74.00171711324469)
        XCTAssertEqual(remoteEvent.locationName, "42 Greene St, New York, NY 10013, USA")
        XCTAssertEqual(remoteEvent.paymentAmount, 100.0)
        XCTAssertEqual(remoteEvent.publicUrl, "https://mobile.capture.com/events/b8f20al")
        XCTAssertEqual(remoteEvent.radius, 0.337514785876185)
        XCTAssertEqual(remoteEvent.title, "Buy some wiskey for Pavel")
        XCTAssertEqual(remoteEvent.hiringCutoffTime, NSDate(timeIntervalSince1970: 1459422300))
        XCTAssertEqual(remoteEvent.startTime, NSDate(timeIntervalSince1970: 1458736200))
        XCTAssertEqual(remoteEvent.bannerImageUrl, "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png")
        XCTAssertEqual(remoteEvent.creatorName, "TIMMYS DREAM")
        XCTAssertEqual(remoteEvent.creatorIconUrl, "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200")
    }

    func testRemoteEventToManagedObjectEvent() {
        // given
        
        // when
        let managedEvent            = createEvent(eventJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedEvent.urlHash, "b8f20al")
        XCTAssertEqual(managedEvent.createdAt, NSDate(timeIntervalSince1970: 1457708802))
        XCTAssertEqual(managedEvent.updatedAt, NSDate(timeIntervalSince1970: 1458678297))
        XCTAssertEqual(managedEvent.detailDescription, "Don't forget ice")
        XCTAssertEqual(managedEvent.latitude, 40.721935965506)
        XCTAssertEqual(managedEvent.longitude, -74.00171711324469)
        XCTAssertEqual(managedEvent.locationName, "42 Greene St, New York, NY 10013, USA")
        XCTAssertEqual(managedEvent.paymentAmount, 100.0)
        XCTAssertEqual(managedEvent.publicUrl, "https://mobile.capture.com/events/b8f20al")
        XCTAssertEqual(managedEvent.radius, 0.337514785876185)
        XCTAssertEqual(managedEvent.title, "Buy some wiskey for Pavel")
        XCTAssertEqual(managedEvent.hiringCutoffTime, NSDate(timeIntervalSince1970: 1459422300))
        XCTAssertEqual(managedEvent.startTime, NSDate(timeIntervalSince1970: 1458736200))
        XCTAssertEqual(managedEvent.managedObjectContext, managedObjectContext)
        XCTAssertEqual(managedEvent.bannerImageUrl, "https://s3.amazonaws.com/capture-static/default-team-banner-image-mobile.png")
        XCTAssertEqual(managedEvent.creatorName, "TIMMYS DREAM")
        XCTAssertEqual(managedEvent.creatorIconUrl, "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200")
    }

    func testNotExpiredAndAppliedOrUnappliedPredicateMatchesEventWithHiringCutoffInFuture() {
        // given
        var eventWithHCD            = eventJSON
        eventWithHCD["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        
        // when 
        let managedEvent            = createEvent(eventWithHCD, moc:managedObjectContext)

        // then
        XCTAssertTrue(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedEvent))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateDoesNotMatchEventWithDisplayTimeIn24HoursPast() {
        // given
        var eventWithHCD            = eventJSON
        eventWithHCD["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-24).timeIntervalSince1970
        
        // when
        let managedEvent            = createEvent(eventWithHCD, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedEvent))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateMatchesEventWithDisplayTimeInFutureAndContractNotAcquired() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        
        // when
        let _                       = createEvent(eventContract.event, moc:managedObjectContext)
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }
   
    func testNotExpiredAndAppliedOrUnappliedPredicateDoesNotMatchEventWithDisplayTimeInFutureAndContractAcquired() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateDoesNotMatchEventContractNotAcquiredAndResolutionUserCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = 0
        eventContract.contract["resolution"] = Contract.ResolutionStatus.UserCanceled.rawValue

        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateDoesNotMatchEventContractNotAcquiredAndResolutionPublisherCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = 0
        eventContract.contract["resolution"] = Contract.ResolutionStatus.PublisherCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateDoesNotMatchEventContractNotAcquiredAndResolutionComplete() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = 0
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Completed.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testNotExpiredAndAppliedOrUnappliedPredicateTrue_IfStartTimeIsNow() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().timeIntervalSince1970
        eventContract.contract["acquired"] = false
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
        
        // when
        createEvent(eventContract.event, moc:managedObjectContext)
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Event.notExpiredAndAppliedOrUnappliedPredicate.evaluateWithObject(managedContract.event))
    }

    func testContractOpenAndAcquiredPredicateMatchesEventWithHiringCutoffInFutureAndContractAcquiredAndOpen() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testContractOpenAndAcquiredPredicateMatchesEventWithHiringCutoffInPastAndContractAcquiredAndOpen() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Open.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInPastAndContractAcquiredAndUserCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.UserCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
   
    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInFutureAndContractAcquiredAndUserCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.UserCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }

    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInFutureAndContractAcquiredAndPublisherCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.PublisherCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
   
    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInPastAndContractAcquiredAndPublisherCanceled() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.PublisherCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }

    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInFutureAndContractAcquiredAndPublisherCompleted() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.PublisherCanceled.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testContractOpenAndAcquiredPredicateDoesNotMatchEventWithHiringCutoffInPastAndContractAcquiredAndPublisherCompleted() {
        // given
        var eventContract           = eventWithContract()
        eventContract.event["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(-1).timeIntervalSince1970
        eventContract.contract["acquired"] = true
        eventContract.contract["resolution"] = Contract.ResolutionStatus.Completed.rawValue
        
        // when
        let managedContract         = createContract(eventContract.contract, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Event.contractIsOpenAndAcquiredPredicate.evaluateWithObject(managedContract.event))
    }
    
    func testEvent_isPastCameraAccessTime_True_WhenPastOneHourBeforeStartDate() {
        // given
        var eventWithHCD            = eventJSON
        eventWithHCD["unix_start_time"] = NSDate().hoursFromNow(-0.9).timeIntervalSinceNow
        eventWithHCD["unix_hiring_cutoff_time"] = NSDate().hoursFromNow(2).timeIntervalSince1970
 
        // when
        let managedEvent            = createEvent(eventWithHCD, moc:managedObjectContext)
        
        // then 
        XCTAssertTrue(managedEvent.isPastCameraAccessTime)
    }
    
}


