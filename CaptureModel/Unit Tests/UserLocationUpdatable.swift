//
//  UserLocationUpdatable.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class UserLocationUpdatable: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }

//    func testuserNotReturnedWhenNeedsLocationUpdateIsFalse() {
//        // given
//        _             = createUser(fakeUser, moc:managedObjectContext)
//        
//        // when
//        let fr = NSFetchRequest(entityName: User.entityName)
//        fr.predicate = User.markedForNeedsLocationUpdatePredicate
//        
//        // then
//        let results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 0)
//    }

//    func testuserNotReturnedWhenNeedsLocationUpdateIsTrue() {
//        // given
//        let user             = createUser(fakeUser, moc:managedObjectContext)
//        managedObjectContext.performChanges {
//            user.markForNeedsLocationUpdate()
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
//        
//        // when
//        let fr = NSFetchRequest(entityName: User.entityName)
//        fr.predicate = User.markedForNeedsLocationUpdatePredicate
//        
//        // then
//        let results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first! as? User, user)
//    }
    
//    func testThatChangingLatitudeMarksUserForRemoteLocationUpdate() {
//        // given
//        let user             = createUser(fakeUser, moc:managedObjectContext)
//        managedObjectContext.performChanges {
//            user.latitude    = 1.0
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
// 
//        // when
//        let fr = NSFetchRequest(entityName: User.entityName)
//        fr.predicate = User.markedForNeedsLocationUpdatePredicate
//        
//        // then
//        let results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first! as? User, user)
//    }
//    
//    func testThatChangingLongitudeMarksUserForRemoteLocationUpdate() {
//        // given
//        let user             = createUser(fakeUser, moc:managedObjectContext)
//        managedObjectContext.performChanges {
//            user.longitude   = 1.0
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
//        
//        // when
//        let fr = NSFetchRequest(entityName: User.entityName)
//        fr.predicate = User.markedForNeedsLocationUpdatePredicate
//        
//        // then
//        let results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first! as? User, user)
//    }

//    func testThatUnmarkingForRemoteLocationUpdatesIsNotReturnedWithPredicate() {
//        // given
//        let user             = createUser(fakeUser, moc:managedObjectContext)
//        managedObjectContext.performChanges {
//            user.markForNeedsLocationUpdate()
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
//        
//        // when
//        let fr = NSFetchRequest(entityName: User.entityName)
//        fr.predicate = User.markedForNeedsLocationUpdatePredicate
//        
//        var results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 1)
//        XCTAssertEqual(results.first! as? User, user)
//        
//        managedObjectContext.performChanges {
//            user.unMarkForNeedsLocationUpdate()
//        }
//        waitForManagedObjectContextToBeDone(managedObjectContext)
//        // then
//        results = try! managedObjectContext.executeFetchRequest(fr)
//        XCTAssertEqual(results.count, 0)
//
//    }
}
