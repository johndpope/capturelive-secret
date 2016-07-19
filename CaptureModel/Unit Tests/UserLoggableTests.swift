//
//  UserLoggableTests.swift
//  Current
//
//  Created by Scott Jones on 3/17/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class UserLoggableTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testThereIsNoAttemptingLoggedInUser() {
        // given
        
        // when
        let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext)
        
        // then
        XCTAssertNil(attemptingloggedInUser)
    }
    
    func testCanSetAttemptingLoginUser() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        attemptingLoginUser(managedUser, moc: managedObjectContext)
        
        // then
        guard let attemptingloggedInUser = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        XCTAssertEqual(attemptingloggedInUser.urlHash, attemptingloggedInUser.urlHash)
    }
    
    func testCanSetAsLoggedInUser() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        loginUser(managedUser, moc:managedObjectContext)
        
        // then
        guard let loggedInUser  = User.loggedInUser(managedObjectContext) else {
            XCTFail(); return
        }
        XCTAssertEqual(managedUser.urlHash, loggedInUser.urlHash)
    }
    
    func testCanRemoveLoggedInUser() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        loginUser(managedUser, moc:managedObjectContext)
        User.removeLoggedInUser(managedObjectContext)
        
        // then
        let loggedInUser        = User.loggedInUser(managedObjectContext)
        XCTAssertNil(loggedInUser)
    }
    
    func testNoAttemptingUserWhileThereIsLoggedInUser() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        attemptingLoginUser(managedUser, moc:managedObjectContext)
        guard let attemptingloggedInUser  = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        
        // when
        loginUser(attemptingloggedInUser, moc:managedObjectContext)
        
        //
        let nowattemptingloggedInUser = User.attemptingLoginUser(managedObjectContext)
        XCTAssertNil(nowattemptingloggedInUser)
    }
    
    func testThereIsNoCachedUserWhenAttemptingLoginLogsOut() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        attemptingLoginUser(managedUser, moc:managedObjectContext)
        
        // when
        guard let attemptingloggedInUser  = User.attemptingLoginUser(managedObjectContext) else {
            XCTFail(); return
        }
        attemptingloggedInUser.logOut()
        
        // then
        let nowattemptingloggedInUser = User.attemptingLoginUser(managedObjectContext)
        XCTAssertNil(nowattemptingloggedInUser)
    }
    
    func testThereIsNoCachedUserWhenLoggedInLogsOut() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        loginUser(managedUser, moc:managedObjectContext)
        
        // when
        guard let loggedInUser  = User.loggedInUser(managedObjectContext) else {
            XCTFail(); return
        }
        loggedInUser.logOut()
        
        // then
        let newloggedInUser = User.loggedInUser(managedObjectContext)
        XCTAssertNil(newloggedInUser)
    }
    
}
