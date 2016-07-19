//
//  RemoteValidatableTests.swift
//  Current
//
//  Created by Scott Jones on 3/17/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class RemoteValidatableTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentTestableSqliteContext()
    }
    
    override func tearDown() {
        managedObjectContext.removeTestStore()
        destroyContext()
        super.tearDown()
    }
    
    func destroyContext() {
        managedObjectContext.destroyTestSqliteContext()
        managedObjectContext    = nil
    }
    
    func testSaveErrorDictionaryOnManagedObjectAndPersistItOnRelaunch() {
        // given 
        let userMO              = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            userMO.validationError  = ["last_name":"This last name is invalid"]
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        destroyContext()
        managedObjectContext    = NSManagedObjectContext.currentTestableSqliteContext()

        // then 
        let userRevivedMO       = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertNotNil(userRevivedMO.validationError)
        guard let errorString = userRevivedMO.validationError?["last_name"] as? String else {
            XCTFail(); return
        }
        XCTAssertEqual(errorString, "This last name is invalid")
    }

    func createAndUnmarkUser()->User {
        let user = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            user.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        return user
    }
   
    func fetchMarkedForUpdateUser()->[AnyObject] {
        let request             = NSFetchRequest(entityName: User.entityName)
        request.fetchLimit      = 1
        request.predicate       = User.markedForRemoteUpdateAndHasNoValidationErrorPredicate
        return try! managedObjectContext.executeFetchRequest(request)
    }
    
    
    // test valid bool after changes to 
    // firstname, lastname, email, instagram
    func testChangingFirstNameMarksObjectAsNotMarkedForRemotelyUpdate() {
        // given
        let userMO              = createAndUnmarkUser()
 
        // when
        managedObjectContext.performChanges {
            userMO.firstName    = "Steven"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 1)
        let mo:User? = match.first as? User
        XCTAssertEqual(userMO, mo)
    }
   
    func testChangingLastNameMarksObjectAsNotMarkedForRemotelyUpdate() {
        // given
        let userMO              = createAndUnmarkUser()
 
        // when
        managedObjectContext.performChanges {
            userMO.lastName     = "Jones"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 1)
        let mo:User? = match.first as? User
        XCTAssertEqual(userMO, mo)
    }

    func testChangingInstagramNameMarksObjectAsNotMarkedForRemotelyUpdate() {
        // given
        let userMO              = createAndUnmarkUser()
        
        // when
        managedObjectContext.performChanges {
            userMO.instagramUsername = "farts"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 1)
        let mo:User? = match.first as? User
        XCTAssertEqual(userMO, mo)
    }
    
    func testChangingAvatarMarksObjectAsNotMarkedForRemotelyUpdate() {
        // given
        let userMO              = createAndUnmarkUser()
        
        // when
        managedObjectContext.performChanges {
            userMO.remoteAvatarUrl = "farts"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 1)
        let mo:User? = match.first as? User
        XCTAssertEqual(userMO, mo)
    }

    func testChangingEmailMarksObjectAsNotMarkedForRemotelyUpdate() {
        // given
        let userMO              = createAndUnmarkUser()
        
        // when
        managedObjectContext.performChanges {
            userMO.email = "farts"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 1)
        let mo:User? = match.first as? User
        XCTAssertEqual(userMO, mo)
    }
    
    func testChangingMarkedValueFailsIfUserHasValidationError() {
        // given
        let userMO              = createAndUnmarkUser()
        
        // when
        managedObjectContext.performChanges {
            userMO.needsRemoteVerification  = true
            userMO.validationError          = ["oh no":"Theres and error"]
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // then
        let match               = fetchMarkedForUpdateUser()
        
        XCTAssertEqual(match.count, 0)
    }
    
}












