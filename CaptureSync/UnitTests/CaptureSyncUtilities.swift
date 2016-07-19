//
//  CurrentSyncUtilities.swift
//  Current
//
//  Created by Scott Jones on 3/18/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

class TestObject:ManagedObject, ManagedObjectType {
    static let entityName = "TestObject"
    static var defaultSortDescriptors: [NSSortDescriptor] {
        get { return [NSSortDescriptor(key: "name", ascending: true)] }
    }
    static let defaultPredicate = NSPredicate(value: true)
    @NSManaged var name : String?
}

class TestObjectB:ManagedObject, ManagedObjectType {
    static let entityName = "TestObjectB"
    static var defaultSortDescriptors: [NSSortDescriptor] {
        get { return [NSSortDescriptor(key: "name", ascending: true)] }
    }
    static let defaultPredicate = NSPredicate(value: true)
    @NSManaged var name : String?
}

var model :NSManagedObjectModel = {
    return NSManagedObjectModel() {
        let testObject = NSEntityDescription(cls:TestObject.self, name:TestObject.entityName)
        testObject.addProperty(NSAttributeDescription.stringType("name", defaultValue:"", optional:false))
        let testObjectB = NSEntityDescription(cls:TestObjectB.self, name:TestObjectB.entityName)
        testObjectB.addProperty(NSAttributeDescription.stringType("name", defaultValue:"", optional:false))
        return [testObject, testObjectB]
    }
}()

func createPersistentStoreCoordinatorWithInMemoryStore()->NSPersistentStoreCoordinator {
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    return psc
}


















