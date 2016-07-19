//
//  CurrentAlamoFireServiceTests.swift
//  Current
//
//  Created by Scott Jones on 3/19/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureModel
@testable import CaptureCore

class UserExtensionTests: XCTestCase {
    
    var managedObjectContext:NSManagedObjectContext!
    
    override func setUp() {
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
    
    func testNeedsToCreateProfilePredicate() {
        // given
        var fuser               = fakeUser
        fuser["first_name"]     = ""
        
        // when
        let managedUser         = createUser(fuser, moc:managedObjectContext)
        
        XCTAssertTrue(User.hasPartiallyCreatedProfilePredicate.evaluateWithObject(managedUser))
    }
    
    func testUserNeedsPaypalPredicate() {
        // given
        let fuser               = needsPaypalUser
        
        // when
        let managedUser         = createUser(fuser, moc:managedObjectContext)
        
        XCTAssertTrue(User.missingPaypalEmail.evaluateWithObject(managedUser))
    }
    
}
