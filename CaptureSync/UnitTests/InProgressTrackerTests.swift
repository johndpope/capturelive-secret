//
//  InProgressTracker.swift
//  Current
//
//  Created by Scott Jones on 3/24/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreDataHelpers
@testable import CaptureSync

class InProgressTrackerTests: XCTestCase {
    
    var managedObjectContext:NSManagedObjectContext! = nil
    var moA:TestObject! = nil
    var moB:TestObject! = nil
    var moC:TestObject! = nil
    var moD:TestObject! = nil
    
    override func setUp() {
        super.setUp()
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.name = "InProgressTrackerTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemoryStore()
        
        moA = managedObjectContext.insertObject() as TestObject
        moA.name = "A"
        moB = managedObjectContext.insertObject() as TestObject
        moB.name = "B"
        moC = managedObjectContext.insertObject() as TestObject
        moC.name = "C"
        moD = managedObjectContext.insertObject() as TestObject
        moD.name = "D"
        
        try! managedObjectContext.save()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        moA = nil
        moB = nil
        moC = nil
        moD = nil
        super.tearDown()
    }
    
    func testThatAddingObjectFirstTimeReturnsAllObjects() {
        // given
        let sut = InProgressTracker<TestObject>()
        
        // when
        let result = sut.objectsToProcessFromObjects([moA, moB])
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(moA))
        XCTAssertTrue(result.contains(moB))
    }
    
    func testThatAddingObjectsTwiceDoesNotReturnAnythingTheSecondTime() {
        // given
        let sut = InProgressTracker<TestObject>()
        
        // when
        let _ = sut.objectsToProcessFromObjects([moA, moB])
        let result = sut.objectsToProcessFromObjects([moA, moB])
        
        // then
        XCTAssertEqual(result.count, 0)
    }
    
    func testThatAddingAMixOfExistingAndNewObjectsReturnsTheNewOnes() {
        // given
        let sut = InProgressTracker<TestObject>()
        
        // when
        let _ = sut.objectsToProcessFromObjects([moA, moB])
        let result = sut.objectsToProcessFromObjects([moA, moB, moC, moD])
   
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(moC))
        XCTAssertTrue(result.contains(moD))
    }
    
    func testThatAddingObjectsAfterTheyHaveBeenMarkedAsCompleteAddsThemAgain() {
        // give
        let sut = InProgressTracker<TestObject>()
        
        // when
        let _ = sut.objectsToProcessFromObjects([moA, moB, moC])
        sut.markObjectsAsComplete([moA, moC])
        let result = sut.objectsToProcessFromObjects([moA, moB, moC, moD])
        
        // then
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains(moA))
        XCTAssertTrue(result.contains(moC))
        XCTAssertTrue(result.contains(moD))
        XCTAssertFalse(result.contains(moB))
    }
    
}















