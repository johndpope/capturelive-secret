//
//  TeamTests.swift
//  Current
//
//  Created by Scott Jones on 3/24/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class TeamTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        waitForManagedObjectContextToBeDone(managedObjectContext)
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testTeamJsonTransformsToRemoteTeam() {
        // given
        
        // when
        let remoteTeam          = RemoteTeam(team:contractTeam)
        
        // then
        XCTAssertEqual(remoteTeam.urlHash, "aabbccd")
        XCTAssertEqual(remoteTeam.createdAt, NSDate(timeIntervalSince1970: 1458587546))
        XCTAssertEqual(remoteTeam.updatedAt, NSDate(timeIntervalSince1970: 1458587587))
        XCTAssertEqual(remoteTeam.name, "Damage, Inc.")
        XCTAssertEqual(remoteTeam.iconUrl, "https://s3.amazonaws.com/capture-static/default-team-icon-mobile.png")
    }
    
    func testRemoteTeamToManagedObjectTeam() {
        // given
        
        // when
        let managedTeam         = createTeam(contractTeam, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedTeam.urlHash, "aabbccd")
        XCTAssertEqual(managedTeam.createdAt, NSDate(timeIntervalSince1970: 1458587546))
        XCTAssertEqual(managedTeam.updatedAt, NSDate(timeIntervalSince1970: 1458587587))
        XCTAssertEqual(managedTeam.name, "Damage, Inc.")
        XCTAssertEqual(managedTeam.iconUrl, "https://s3.amazonaws.com/capture-static/default-team-icon-mobile.png")
    }
    
}
