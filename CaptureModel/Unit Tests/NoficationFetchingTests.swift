//
//  NotificationFetchingTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class NotificationFetchingTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }

    func testFetchingEventsWithAnyUnreadNotification() {
        // given
        createContractForNotifications("contract_to_not_readNote", eventHash:"event_to_not_readNote", moc:managedObjectContext)
        createContractForNotifications("contract_to_readNote", eventHash:"event_to_readNote", moc:managedObjectContext)
        
        let not_1 = createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_read", contractHash:"contract_to_readNote", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_not_read", contractHash:"contract_to_not_readNote", moc:managedObjectContext)
        managedObjectContext.performChanges {
            not_1.readAt = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let events = Event.fetchAllWithAnyUnreadNotifications(managedObjectContext)
        
        // then
        XCTAssertEqual(1, events.count)
        let event = events.first!
        XCTAssertEqual("event_to_not_readNote", event.urlHash)
    }
    
    func testFetchingEventsWithAnyUnreadNotification_OneReadOneUnRead() {
        // given
        createContractForNotifications("contract_to_not_readNote", eventHash:"event_to_not_readNote", moc:managedObjectContext)
        createContractForNotifications("contract_to_readNote", eventHash:"event_to_readNote", moc:managedObjectContext)
        
        let not_1 = createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_read_0", contractHash:"contract_to_not_readNote", moc:managedObjectContext)
        let _ = createContractNotification(arrivedNotifJSON, noteUrlHash:"note_id_to_read_1", contractHash:"contract_to_not_readNote", moc:managedObjectContext)
        
        let note_2 = createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_not_read", contractHash:"contract_to_readNote", moc:managedObjectContext)
        managedObjectContext.performChanges {
            not_1.readAt            = NSDate()
            note_2.readAt           = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let events = Event.fetchAllWithAnyUnreadNotifications(managedObjectContext)
        
        // then
        XCTAssertEqual(1, events.count)
        let event = events.first!
        XCTAssertEqual("event_to_not_readNote", event.urlHash)
    }
    
    func testFetchingEventWithOnlyReadNotification() {
        // given
        createContractForNotifications("contract_to_not_readNote", eventHash:"event_to_not_readNote", moc:managedObjectContext)
        createContractForNotifications("contract_to_readNote", eventHash:"event_to_readNote", moc:managedObjectContext)
        
        let not_1 = createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_read", contractHash:"contract_to_readNote", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_id_to_not_read", contractHash:"contract_to_not_readNote", moc:managedObjectContext)
        managedObjectContext.performChanges {
            not_1.readAt = NSDate()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        let events = Event.fetchAllsWithOnlyReadNotifications(managedObjectContext)
        
        // then
        XCTAssertEqual(1, events.count)
        let event = events.first!
        XCTAssertEqual("event_to_readNote", event.urlHash)
    }
    
    func testEventsReturnedInSortOrderOfNewestNotification() {
        // given
        createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractForNotifications("contract_1", eventHash:"event_1", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_1", contractHash:"contract_1", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_0", contractHash:"contract_0", moc:managedObjectContext)
        
        // when
        let events = Event.fetchAllWithAnyUnreadNotifications(managedObjectContext)
        
        // then
        let event = events.first!
        XCTAssertEqual("event_1", event.urlHash)
    }
    
    func testOnlyReturnsEventsWithNotifications() {
        // given
        createContractForNotifications("contract_without_notifications", eventHash:"event_without_notifications", moc:managedObjectContext)
        createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractForNotifications("contract_1", eventHash:"event_1", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_1", contractHash:"contract_1", moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"note_1", contractHash:"contract_1", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"note_0", contractHash:"contract_0", moc:managedObjectContext)
        
        // when
        let events = Event.fetchAllWithAnyUnreadNotifications(managedObjectContext)
        
        // then
        XCTAssertEqual(2, events.count)
    }
    
    func testFetchingTotalNumberOfUnreadNotifications() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(cancelHiredNotifJSON, noteUrlHash:"canceled", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
        
        // then
        XCTAssertEqual(4, numUnreadNotifcations)
    }

    func testNotificationIsNotCountedIfHasNoEventSourceOrContractSource() {
        // given
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:"fake contract", moc:managedObjectContext )
    
        // when
        let numUnreadNotifcations = Notification.fetchTotalNumberOfUnread(managedObjectContext)
 
        // then
        XCTAssertEqual(0, numUnreadNotifcations)
    }
    
    func testSortingNotificationsWithHiredPriority_HiredWasFirst() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        let hiredNote = contract.mostRecentUnreadNotification(favoringFirst: .Hired)!
        
        // then
        XCTAssertEqual(NotificationType.Hired, hiredNote.pushType)
    }
    
    func testSortingNotificationsWithHiredPriority_HiredWasSecond() {
        // given
        let contract = createContractForNotifications("contract_0", eventHash:"event_0", moc:managedObjectContext)
        createContractNotification(getToLocNotifJSON, noteUrlHash:"reminder", contractHash:contract.urlHash, moc:managedObjectContext)
        createContractNotification(hiredNotifJSON, noteUrlHash:"hired", contractHash:contract.urlHash, moc:managedObjectContext )
        createContractNotification(arrivedNotifJSON, noteUrlHash:"arrived", contractHash:contract.urlHash, moc:managedObjectContext)
        
        // when
        let hiredNote = contract.mostRecentUnreadNotification(favoringFirst: .Hired)!
        
        // then
        XCTAssertEqual(NotificationType.Hired, hiredNote.pushType)
    }

    
}



