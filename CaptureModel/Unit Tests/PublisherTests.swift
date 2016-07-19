//
//  PublisherTests.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class PublisherTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func testPublisherJsonTransformsToRemotePublisher() {
        // given
        
        // when
        let remotePublisher     = RemotePublisher(publisher:contractPublisher)
       
        // then
        XCTAssertEqual(remotePublisher.urlHash, "0e4b98t")
        XCTAssertEqual(remotePublisher.createdAt, NSDate(timeIntervalSince1970: 1458587563))
        XCTAssertEqual(remotePublisher.updatedAt, NSDate(timeIntervalSince1970: 1458587563))
        XCTAssertEqual(remotePublisher.teamUrlHash, "aabbccd")
        XCTAssertEqual(remotePublisher.phoneNumber, "+15404552569")
        XCTAssertEqual(remotePublisher.lastName, "Publishoo")
        XCTAssertEqual(remotePublisher.firstName, "Jonny;")
        XCTAssertEqual(remotePublisher.avatarUrl, "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg")
    }
   
    func testRemotePublisherToManagedObjectPublisher() {
        // given
        
        // when
        let managedPublisher         = createPublisher(contractPublisher, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedPublisher.urlHash, "0e4b98t")
        XCTAssertEqual(managedPublisher.createdAt, NSDate(timeIntervalSince1970: 1458587563))
        XCTAssertEqual(managedPublisher.updatedAt, NSDate(timeIntervalSince1970: 1458587563))
        XCTAssertEqual(managedPublisher.teamUrlHash, "aabbccd")
        XCTAssertEqual(managedPublisher.phoneNumber, "+15404552569")
        XCTAssertEqual(managedPublisher.lastName, "Publishoo")
        XCTAssertEqual(managedPublisher.firstName, "Jonny;")
        XCTAssertEqual(managedPublisher.avatarUrl, "https://capture-media-mobile.s3.amazonaws.com/uploads/publisher/avatar/2/retina_1458587563.jpeg")
    }
    
}
