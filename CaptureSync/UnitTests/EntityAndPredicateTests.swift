//
//  EntityAndPredicateTests.swift
//  Current
//
//  Created by Scott Jones on 3/18/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import Foundation
import CoreData
@testable import CaptureSync

class EntityAndPredicateTests:XCTestCase {

    var managedObjectContext:NSManagedObjectContext! = nil
    
    override func setUp() {
        super.setUp()
        managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.name = "EntityAndPredicateTests"
        managedObjectContext.persistentStoreCoordinator = createPersistentStoreCoordinatorWithInMemoryStore()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
 
    func testThatItMapsTheEntityName() {
        // given
        let entity = managedObjectContext.persistentStoreCoordinator!.managedObjectModel.entitiesByName[TestObject.entityName]!
        
        // when
        let sut = EntityAndPredicate(entityName: TestObject.entityName, predicate: NSPredicate(value: true), context:managedObjectContext)
        
        // then
        XCTAssert(sut.entity == entity)
    }
    
    func testThatItBuildsAFetchRequest() {
        // given
        managedObjectContext.performBlockAndWait {
            let moA:TestObject = self.managedObjectContext.insertObject()
            moA.name = "A"
            let moB:TestObject = self.managedObjectContext.insertObject()
            moB.name = "B"
            try! self.managedObjectContext.save()
        }
        let sut = EntityAndPredicate(entityName:TestObject.entityName, predicate:NSPredicate(format:"%K == %@", "name", "B"), context: managedObjectContext)
        
        // when
        let match = try! managedObjectContext.executeFetchRequest(sut.fetchRequest)
        
        // then
        XCTAssertEqual(match.count, 1)
        let mo:TestObject? = match.first as? TestObject
        XCTAssertEqual(mo?.name, "B")
    }
    
}

























