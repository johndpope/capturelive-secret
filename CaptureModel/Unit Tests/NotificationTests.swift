//
//  NotificationTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class NotificationTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testCanMapRemoteNotificationFromJSON() {
        // given
        var notificationJSON = hiredNotifJSON
        notificationJSON["unix_created_at"] = 1458588073
        notificationJSON["unix_updated_at"] = 1458589872
        
        // when
        let remoteNote = RemoteNotification(notification:notificationJSON)
        
        // then 
        XCTAssertEqual("aassddsda", remoteNote.urlHash)
        XCTAssertEqual(NSDate(timeIntervalSince1970: 1458588073), remoteNote.createdAt)
        XCTAssertEqual(NSDate(timeIntervalSince1970: 1458589872), remoteNote.updatedAt)
        XCTAssertEqual("Contract", remoteNote.sourceType)
        XCTAssertEqual("aabbcc", remoteNote.sourceUrlHash)
        XCTAssertEqual("You've been hired", remoteNote.message)
        XCTAssertEqual(40, remoteNote.type)
        XCTAssertNil(remoteNote.readAt)
    }
    
    func testRemoteNoteMapsReadAt() {
        // given
        var notificationJSON = hiredNotifJSON
        let date                            = NSDate()
        notificationJSON["unix_read_at"]    = NSNumber(double:date.timeIntervalSince1970)
        
        // when
        let remoteNote = RemoteNotification(notification:notificationJSON)
        
        // then
        XCTAssertNotNil(remoteNote.readAt)
        XCTAssertEqual(date.timeIntervalSince1970, remoteNote.readAt!.timeIntervalSince1970)
    }
    
    func testRemoteNotificationMapsToManagedNotification() {
        // given
        var notificationJSON = hiredNotifJSON
        notificationJSON["unix_created_at"] = 1458588073
        notificationJSON["unix_updated_at"] = 1458589872

        // when 
        let managedNote = createNotification(notificationJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual("aassddsda", managedNote.urlHash)
        XCTAssertEqual(NSDate(timeIntervalSince1970: 1458588073), managedNote.createdAt)
        XCTAssertEqual(NSDate(timeIntervalSince1970: 1458589872), managedNote.updatedAt)
        XCTAssertEqual("You've been hired", managedNote.message)
        XCTAssertEqual(40, managedNote.type)
        XCTAssertNil(managedNote.readAt)
    }
    
    func testNotificationCanLinkToNotificationSource_Contract() {
        // given 
        let managedContract         = createContract(acceptedContractFullEvent, moc:managedObjectContext)
        
        var notificationJSON        = hiredNotifJSON
        notificationJSON["payload_source"] = "contract"
        notificationJSON["payload_object_url_hash"] = managedContract.urlHash
        
        // when
        let managedNote = createNotification(notificationJSON, moc:managedObjectContext)

        // then
        XCTAssertEqual(managedContract, managedNote.contractSource)
        XCTAssertEqual(managedContract.event, managedNote.eventSource)
    }
    
    func testNotificationCanLinkToNotificationSource_Event() {
        // given
        let managedContract         = createContract(acceptedContractFullEvent, moc:managedObjectContext)
        
        var notificationJSON        = hiredNotifJSON
        notificationJSON["payload_source"] = "event"
        notificationJSON["payload_object_url_hash"] = managedContract.event.urlHash
        
        // when
        let managedNote = createNotification(notificationJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedContract.event, managedNote.eventSource)
        XCTAssertEqual(0, managedContract.event.numberOfReadNotifications)
        XCTAssertEqual(1, managedContract.event.numberOfUnreadNotifications)
    }
    
    func testEventFindsNotificationIfItAlreadyInContext() {
        // given
        var notificationJSON        = hiredNotifJSON
        notificationJSON["payload_source"] = "event"
        notificationJSON["payload_object_url_hash"] = "123456"
        let _                       = createNotification(notificationJSON, moc:managedObjectContext)
        
        // when
        var eventWithHCD            = eventJSON
        eventWithHCD["url_hash"]    = "123456"
        let managedEvent            = createEvent(eventWithHCD, moc:managedObjectContext)
       
        // then
        XCTAssertEqual(0, managedEvent.numberOfReadNotifications)
        XCTAssertEqual(1, managedEvent.numberOfUnreadNotifications)
    }
    
    func testContractFindsNotificationIfItAlreadyInContext() {
        // given
        var notificationJSON        = hiredNotifJSON
        notificationJSON["payload_source"] = "contract"
        notificationJSON["payload_object_url_hash"] = "123456"
        let _                       = createNotification(notificationJSON, moc:managedObjectContext)
 
        // when
        var contract                = acceptedContractFullEvent
        contract["url_hash"]        = "123456"
        let managedContract         = createContract(contract, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(0, managedContract.numberOfReadNotifications)
        XCTAssertEqual(1, managedContract.numberOfUnreadNotifications)
        XCTAssertEqual(0, managedContract.event.numberOfReadNotifications)
        XCTAssertEqual(1, managedContract.event.numberOfUnreadNotifications)
    }
    
    func testAddingReadAtMarksForRemoteUpdate() {
        // given
        var notificationJSON        = hiredNotifJSON
        notificationJSON["payload_source"] = "contract"
        notificationJSON["payload_object_url_hash"] = "123456"
        let notification            = createNotification(notificationJSON, moc:managedObjectContext)
        XCTAssertFalse(Notification.markedForRemoteVerificationPredicate.evaluateWithObject(notification))
        
        // when
        managedObjectContext.performChanges {
            notification.readAt     = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Notification.markedForRemoteVerificationPredicate.evaluateWithObject(notification))
    }
    
    func testWith2NotificationsLastIsMostRecent() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        
        // when 
        var arrived = arrivedNotifJSON
        arrived["updated_at"] = NSDate().hoursFromNow(-1)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:"contract_0", moc:managedObjectContext)
        var hired = hiredNotifJSON
        hired["updated_at"] = NSDate()
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:"contract_1", moc:managedObjectContext)
 
        // then
        let note = contract.mutableNotifications.last
        XCTAssertEqual("arrived", note?.urlHash)
    }
   
    func testWith2NotificationsIfOneIsUnreadItIsLast() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        
        // when
        var arrived = arrivedNotifJSON
        arrived["updated_at"] = NSDate().hoursFromNow(-1)
        let arrivedNote = createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:"contract_0", moc:managedObjectContext)
        managedObjectContext.performChanges {
            arrivedNote.readAt = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        var hired = hiredNotifJSON
        hired["updated_at"] = NSDate()
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:"contract_0", moc:managedObjectContext)
        
        
        // then
        let note = contract.mutableNotifications.last
        XCTAssertEqual("hired", note?.urlHash)
    }
    
    func getMostRecentUnreadNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)

        // when
        var arrived = arrivedNotifJSON
        arrived["updated_at"] = NSDate().hoursFromNow(-1)
        let arrivedNote = createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:"contract_0", moc:managedObjectContext)
        managedObjectContext.performChanges {
            arrivedNote.readAt = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        var hired = hiredNotifJSON
        hired["updated_at"] = NSDate()
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:"contract_0", moc:managedObjectContext)

        // then
        let note = contract.mostRecentNotification
        XCTAssertEqual("hired", note?.urlHash)
        let note2 = contract.event.mostRecentNotification
        XCTAssertEqual("hired", note2?.urlHash)
    }
    
    func testCanFilterTestRemoteNotifications() {
        // given
        let remoteNotifications = [
             RemoteNotification(notification:testNotifJSON)
            ,RemoteNotification(notification:availNotifJSON)
            ,RemoteNotification(notification:hiredNotifJSON)
            ,RemoteNotification(notification:arrivedNotifJSON)
            ,RemoteNotification(notification:cancelHiredNotifJSON)
            ,RemoteNotification(notification:getToLocNotifJSON)
            ,RemoteNotification(notification:pendingNotifJSON)
            ,RemoteNotification(notification:underReviewNotifJSON)
            ,RemoteNotification(notification:deniedNotifJSON)
            ,RemoteNotification(notification:grantedNotifJSON)
            ,RemoteNotification(notification:testNotifJSON)
        ]
        
        // when 
        let noTestNotes = remoteNotifications.removeTestsNotifications()
        
        // then 
        XCTAssertEqual(remoteNotifications.count - 2, noTestNotes.count)
    }
    
    func testCanMarkOnlyAllNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        let hiredNote = createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        let reminderNote = createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        let arrivedNote = createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        let canceledNote = createContractNotification(cancelHiredNotifJSON, noteUrlHash:"canceled", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges{
            contract.markAllNotificationsAsRead()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
        
        // then
        XCTAssertNotNil(hiredNote.readAt)
        XCTAssertNotNil(reminderNote.readAt)
        XCTAssertNotNil(arrivedNote.readAt)
        XCTAssertNotNil(canceledNote.readAt)
        XCTAssertEqual(0, numUnreadNotifcations)
    }
    
    
    func testCanMarkOnlyHiredNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        let hiredNote = createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges{
            contract.markNotificationAsRead(.Hired)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
 
        // then
        XCTAssertNotNil(hiredNote.readAt)
        XCTAssertEqual(2, numUnreadNotifcations)
    }
    
    func testCanMarkOnlyReminderNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        let reminderNote = createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges{
            contract.markNotificationAsRead(.JobStartsIn1Hour)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
 
        // then
        XCTAssertNotNil(reminderNote.readAt)
        XCTAssertEqual(2, numUnreadNotifcations)
    }
    
    func testCanMarkOnlyArrivedNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        let arrivedNote = createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges{
            contract.markNotificationAsRead(.Arrived)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
 
        // then
        XCTAssertNotNil(arrivedNote.readAt)
        XCTAssertEqual(2, numUnreadNotifcations)
    }
    
    func testCanMarkOnlyCanceledNotification() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        let canceledNote = createContractNotification(cancelHiredNotifJSON, noteUrlHash:"canceled", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges{
            contract.markNotificationAsRead(.Canceled)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
 
        // then
        XCTAssertNotNil(canceledNote.readAt)
        XCTAssertEqual(3, numUnreadNotifcations)
    }
   
    func testHasReadNotification_hired() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        
        // when
        managedObjectContext.performChanges{
            contract.markNotificationAsRead(.Hired)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // then
        XCTAssertTrue(contract.hasReadNotification(.Hired))
    }
    
    func testFetchNotificationByContractSourceUrlHashAndPushTypeReturnsNotification() {
        // given
        let contract2 = createContractForNotifications("contract_1", eventHash:"event_1", moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract2.urlHash, moc:managedObjectContext )
        let contract1 = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract1.urlHash, moc:managedObjectContext )
        
        // when
        let hiredNotePredicate = Notification.predicateForNotificationWith(.Hired, contractSourceUrlHash:"contract_0")
        let hiredNote = Notification.findOrFetchInContext(managedObjectContext, matchingPredicate: hiredNotePredicate)!
        
        // then
        XCTAssertEqual(NotificationType.Hired, hiredNote.pushType)
        XCTAssertEqual(contract1.urlHash, hiredNote.contractSource!.urlHash)
    }
    
    func testFetchNotificationByContractSourceUrlHashAndPushTypeReturnsNotificationNilWhenAppropriate() {
        // given
        let contract1 = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract1.urlHash, moc:managedObjectContext )
        
        // when
        let hiredNotePredicate = Notification.predicateForNotificationWith(.Hired, contractSourceUrlHash:"contract_0")
        let hiredNote = Notification.findOrFetchInContext(managedObjectContext, matchingPredicate: hiredNotePredicate)
        
        // then
        XCTAssertNil(hiredNote)
    }

}















