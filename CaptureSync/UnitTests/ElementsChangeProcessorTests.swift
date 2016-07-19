//
//  ElementsChangeProcessorTests.swift
//  Current
//
//  Created by Scott Jones on 3/24/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreDataHelpers
import CaptureModel
@testable import CaptureSync

private class TestChangeProcessor: ElementChangeProcessorType {
    
    typealias Element = TestObject
    let elementsInProgress = InProgressTracker<TestObject>()
    
    func setupForContext(context:ChangeProcessorContextType) {
        // no - op
    }
    
    private var changedElements:[TestObject] = []
    // process local
    func processChangedLocalElements(objects:[TestObject], context:ChangeProcessorContextType) {
        changedElements += objects
    }
    
    // process remote
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    // fetch remote
    func fetchLatestRemoteRecordsForContext(context:ChangeProcessorContextType){
        
    }
    
    // predicate local
    var predicateForLocallyTrackedElements:NSPredicate {
        return NSPredicate(format: "%K == %@", "name","A")
    }
    
}

private class TestContext:ChangeProcessorContextType {
    
    let managedObjectContext:NSManagedObjectContext
    
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    var remote:CaptureLiveRemoteType {
        fatalError() // nah
    }
    
    func performGroupedBlock(block: ()->() ) {
        block()
    }
    
    func performGroupedBlock<A>(block: (A)->() ) -> (A)->() {
        return { (a:A)->() in
            block(a)
        }
    }
    
    func performGroupedBlock<A,B>(block: (A,B)->() ) -> (A,B)->() {
        return { (a:A, b:B)->() in
            block(a,b)
        }
    }
    
    func performGroupedBlock<A,B,C>(block: (A,B,C)->() ) -> (A,B,C)->() {
        return { (a:A, b:B, c:C)->() in
            block(a,b,c)
        }
    }
    
    func delayedSaveOrRollback() {
        XCTFail()
    }
    
}

class ElementChangeProcessorTests: XCTestCase {
    
    private var managedObjectContext:NSManagedObjectContext! = nil
    private var context:TestContext! = nil
    
    override func setUp() {
        super.setUp()
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.name = "ElementChangeProcessorTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemoryStore()
        
        context = TestContext(managedObjectContext: managedObjectContext)
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        context                 = nil
        super.tearDown()
    }
    
    func testChangeProcessorForwardsMatchingObjects() {
        // given
        let mo1:TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2:TestObject = managedObjectContext.insertObject()
        mo2.name = "A"
        try! managedObjectContext.save()
        
        let sut = TestChangeProcessor()
        
        // when
        sut.processChangedLocalElements([mo1, mo2], context:context)
        
        // then
        XCTAssertEqual(sut.changedElements.count, 2)
        XCTAssertTrue(sut.changedElements.contains(mo1))
        XCTAssertTrue(sut.changedElements.contains(mo2))
    }
   
    func testThatDoesNotForwardNonMatchingObjects() {
        // given
        let mo1:TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2:TestObject = managedObjectContext.insertObject()
        mo2.name = "B"
        try! managedObjectContext.save()
        
        let sut = TestChangeProcessor()
        
        // when
        sut.processChangedLocalObjects([mo1, mo2], context:context)
        
        // then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo1))
        XCTAssertTrue(!sut.changedElements.contains(mo2))
    }
    
    func testItDoesNotForwardObjectsOfAnotherEntity() {
        // given
        let mo1:TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        let mo2:TestObjectB = managedObjectContext.insertObject()
        mo2.name = "A"
        try! managedObjectContext.save()

        let sut = TestChangeProcessor()

        // when
        sut.processChangedLocalObjects([mo1, mo2], context:context)

        // then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo1))
    }
    
}

// MARK: Objects that are in-progress testing
extension ElementChangeProcessorTests {

    func testThatItDoesNotForwardObjectsIfTheyAreAlreadyInProgress() {
        // given
        let mo1:TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        try! managedObjectContext.save()
    
        let sut = TestChangeProcessor()
        
        // when
        sut.processChangedLocalObjects([mo1], context:context)
        sut.changedElements = []
        sut.processChangedLocalObjects([mo1], context:context)

        XCTAssertEqual(sut.changedElements.count, 0)
    }
    
    func testThatItForwardsAnObjectAgainAfterItHasBeenMarkedForCompletionIfItStillMatches() {
        // given
        let mo1:TestObject = managedObjectContext.insertObject()
        mo1.name = "A"
        try! managedObjectContext.save()
        
        let sut = TestChangeProcessor()
        
        // when
        sut.processChangedLocalObjects([mo1], context:context)
        sut.changedElements = []
        sut.didCompleteElements([mo1], context:context)
 
        // then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo1))
    }
    
    func testThatItForwardsAnObjectAgainOnceItHasBeenMarkedAsComplete() {
        // given
        let mo:TestObject = managedObjectContext.insertObject()
        mo.name = "A"
        try! managedObjectContext.save()
        
        let sut = TestChangeProcessor()
        
        // when
        sut.processChangedLocalObjects([mo], context:context)
        // Make sure it not longer matches
        mo.name = "B"
        try! managedObjectContext.save()
        sut.didCompleteElements([mo], context:context)
        // re- add
        mo.name = "A"
        try! managedObjectContext.save()
        sut.changedElements = []
        sut.processChangedLocalObjects([mo], context:context)
       
        // then
        XCTAssertEqual(sut.changedElements.count, 1)
        XCTAssertTrue(sut.changedElements.contains(mo))
    }
    
}
















