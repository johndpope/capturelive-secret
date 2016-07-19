//
//  ContractTests.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class ContractTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        if let sqlm = sqliteManagedContext {
            waitForManagedObjectContextToBeDone(sqlm)
            sqlm.removeTestStore()
            sqlm.destroyTestSqliteContext()
            sqliteManagedContext    = nil
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testContractJsonTransformsToRemoteContract() {
        // given
        // when
        let remoteContract         = RemoteContract(contract:acquiredContract)
        
        // then
        XCTAssertEqual(remoteContract.urlHash, "2c4486f")
        XCTAssertEqual(remoteContract.createdAt, NSDate(timeIntervalSince1970: 1458588073))
        XCTAssertEqual(remoteContract.updatedAt, NSDate(timeIntervalSince1970: 1458589872))
        XCTAssertEqual(remoteContract.acquired, true)
        XCTAssertEqual(remoteContract.started, true)
        XCTAssertEqual(remoteContract.arrivalRadius, 0.0475)
        XCTAssertEqual(remoteContract.eventUrlHash, "c1080fr")
        XCTAssertEqual(remoteContract.resolution, "open")
        XCTAssertEqual(remoteContract.streamApplication, "capture")
        XCTAssertEqual(remoteContract.streamHost, "54.167.38.119")
        XCTAssertEqual(remoteContract.streamName, "2c4486f")
        XCTAssertEqual(remoteContract.streamPort, 1935)
        XCTAssertEqual(remoteContract.streamProtocol, "rtsp")
    }

    func testRemoteContractToManagedObjectContract() {
        // given
        // when
        let managedContract         = createContract(acquiredContract, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedContract.urlHash, "2c4486f")
        XCTAssertEqual(managedContract.createdAt, NSDate(timeIntervalSince1970: 1458588073))
        XCTAssertEqual(managedContract.updatedAt, NSDate(timeIntervalSince1970: 1458589872))
        XCTAssertEqual(managedContract.acquired, true)
        XCTAssertEqual(managedContract.started, true)
        XCTAssertEqual(managedContract.arrivalRadius, 0.0475)
        XCTAssertEqual(managedContract.eventUrlHash, "c1080fr")
        XCTAssertEqual(managedContract.resolution, "open")
        XCTAssertEqual(managedContract.streamApplication, "capture")
        XCTAssertEqual(managedContract.streamHost, "54.167.38.119")
        XCTAssertEqual(managedContract.streamName, "2c4486f")
        XCTAssertEqual(managedContract.streamPort, 1935)
        XCTAssertEqual(managedContract.streamProtocol, "rtsp")
    }
    
    func testRemoteContractToManagedObjectContractFromCompletedJobSOn() {
        // given
        // when
        let managedContract         = createContract(completedContract, moc:managedObjectContext)
        
        // then
        XCTAssertEqual("c1080fr", managedContract.event.urlHash)
        XCTAssertEqual("0e4b98t", managedContract.publisher?.urlHash)
        XCTAssertEqual("aabbccd", managedContract.team?.urlHash)
        XCTAssertEqual(1, managedContract.attachments?.count)
        let att = managedContract.attachments?.first!
        XCTAssertEqual("b96b57c2-7d8d-4a1b-842c-c8c8384868b6", att?.uuid)
        XCTAssertEqual(2, att?.remoteFiles?.count)
        let rf = att?.remoteFilesAscending.first!
        XCTAssertEqual("im_a_uuid_0", rf?.uuid)
    }
   
    func testContractCreatesEventRelationshipWhenFullEventInJson() {
        // given
        // when
        let managedContract         = createContract(acceptedContractFullEvent, moc:managedObjectContext)
        
        // then
        XCTAssertNotNil(managedContract.event)
        XCTAssertEqual(managedContract.event.urlHash, "c1080fr")
    }
   
    func testContractCreatesEventRelationshipWhenEventHashInJSON() {
        // given
        let managedEvent            = createEvent(acceptedContractEvent, moc:managedObjectContext)
        
        // when
        let managedContract         = createContract(acceptedContractNoEvent, moc:managedObjectContext)
        
        // then
        XCTAssertNotNil(managedContract.event)
        XCTAssertEqual(managedContract.event.urlHash, managedEvent.urlHash)
    }
    
    func testContractCreatesPublisherRelationshipWhenPublisherInJson() {
        // given
        var contractWithEvent       = acceptedContractFullEvent
        contractWithEvent["publisher"] = contractPublisher
        
        // when
        let managedContract         = createContract(contractWithEvent, moc:managedObjectContext)
        
        // then
        XCTAssertNotNil(managedContract.publisher)
        XCTAssertEqual(managedContract.publisher!.urlHash, "0e4b98t")
    }
    
    func testContractCreatesTeamRelationshipWhenTeamInJson() {
        // given
        var contractWithEvent       = acceptedContractFullEvent
        contractWithEvent["team"]   = contractTeam
        
        // when
        let managedContract         = createContract(contractWithEvent, moc:managedObjectContext)
        
        // then
        XCTAssertNotNil(managedContract.team)
        XCTAssertEqual(managedContract.team!.urlHash, "aabbccd")
    }
    
    func testUnFullContractShouldBeFetched() {
        // given 
        var contractNoPubNoTeam       = acceptedContractFullEvent
        contractNoPubNoTeam["acquired"] = true
        
        // when
        let managedContract         = createContract(contractNoPubNoTeam, moc:managedObjectContext)

        // then
        XCTAssertTrue(Contract.markedForRemoteCompletionPredicate.evaluateWithObject(managedContract))
    }
    
    func testPredicateForActiveJobReturnsNilContractNotAcquired() {
        // given
        // when
        _                           = createContract(acceptedContractFullEvent, moc:managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNil(activeContract)
    }
 
    func testPredicateForActiveJobReturnsNilContractEventNotStarted() {
        // given
        // when
        _                           = createContract(acquiredContract, moc:managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNil(activeContract)
    }

    func testPredicateForActiveJobReturnsContractIfAcquiredAndStartedAndResolutionStatusOpen() {
        // given
        var acJson                  = acquiredContract
        var eventJson               = acquiredContract["event"] as! [String:AnyObject]
        eventJson["unix_start_time"] = NSDate().hoursFromNow(-2).timeIntervalSince1970
        acJson["event"]             = eventJson
        
        // when
        _                           = createContract(acJson, moc:managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNotNil(activeContract)
    }
    
    func testPredicateForActiveJobReturnsNilContractIfAcquiredAndStartedResolutionStatusCompleted() {
        var acJson                  = acquiredContract
        var eventJson               = acquiredContract["event"] as! [String:AnyObject]
        eventJson["unix_start_time"] = NSDate().hoursFromNow(-2).timeIntervalSince1970
        acJson["event"]             = eventJson
        
        // when
        let contract                = createContract(acJson, moc:managedObjectContext)
        managedObjectContext.performChanges {
            contract.resolutionStatus = .Completed
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNil(activeContract)
    }
    
    func testPredicateForActiveJobReturnsNilContractIfAcquiredAndStartedResolutionStatusPublisherCancelled() {
        var acJson                  = acquiredContract
        acJson["resolution"]        = "publisher_canceled"
        var eventJson               = acquiredContract["event"] as! [String:AnyObject]
        eventJson["unix_start_time"] = NSDate().hoursFromNow(-2).timeIntervalSince1970
        acJson["event"]             = eventJson
        
        // when
        _                           = createContract(acJson, moc:managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNil(activeContract)
    }

    func testPredicateForActiveJobReturnsNilContractIfAcquiredAndStartedResolutionStatusUserCancelled() {
        // given
        var acJson                  = acquiredContract
        var eventJson               = acquiredContract["event"] as! [String:AnyObject]
        eventJson["unix_start_time"] = NSDate().hoursFromNow(-2).timeIntervalSince1970
        acJson["event"]             = eventJson
        
        // when
        let contract                = createContract(acJson, moc:managedObjectContext)
        managedObjectContext.performChanges {
            contract.resolutionStatus = .UserCanceled
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let activeContract          = Contract.fetchActiveContract(managedObjectContext)
        XCTAssertNil(activeContract)
    }
    
    func testPredicateForPaidContracts() {
        // given
        var acJson                  = acquiredContract
        acJson["payment_status"]    = "paid"

        // when
        _                           = createContract(acJson, moc:managedObjectContext)

        // then
        let paidContracts          = Contract.fetchPaidContracts(managedObjectContext)
        XCTAssertEqual(1, paidContracts.count)
    }

    var sqliteManagedContext :NSManagedObjectContext?
    
    func testCanRetrieveSumOfAllCompletedContracts() {
        // given
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        var acJson                  = acquiredContract
        acJson["payment_status"]    = "paid"
        var evJson                  = acquiredContract["event"] as! [String:AnyObject]
        
        // when
        for i in 0..<30 {
            evJson["url_hash"]      = "c_id_\(i)"
            acJson["url_hash"]      = "e_id_\(i)"
            acJson["event"]         = evJson
            _                       = createContract(acJson, moc:sqliteManagedContext!)
        }
       
        // then
        let totalPayment            = Contract.fetchTotalPaymentsMade(sqliteManagedContext!)
        XCTAssertEqual(3000, totalPayment)
    }
    
}












