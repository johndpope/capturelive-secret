//
//  RemoteUserTests.swift
//  Current
//
//  Created by Scott Jones on 4/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel


class RemoteValidationUserTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testNeedsRemoteValidationTriggeredOnBioChanged() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedUser.bio = "A Garbage bio"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(User.markedForRemoteVerificationPredicate.evaluateWithObject(managedUser))
    }
    

}
