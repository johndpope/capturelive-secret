//
//  NSManagedObjectContext+Extensions.swift
//  Trans
//
//  Created by Scott Jones on 2/13/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    private var store:NSPersistentStore {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC is missing") }
        guard let store = psc.persistentStores.first else { fatalError("No Store") }
        return store
    }
    
    public var metaData:[String:AnyObject] {
        get {
            guard let psc = persistentStoreCoordinator else { fatalError("PSC is missing") }
            return psc.metadataForPersistentStore(store)
        }
        set {
            guard let psc = persistentStoreCoordinator else { fatalError("PSC is missing") }
            psc.setMetadata(newValue, forPersistentStore: store)
        }
    }
    
    public func setMetaData(object:AnyObject?, key:String) {
        var md = metaData
        md[key] = object
        metaData = md
    }

    public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(A.entityName, inManagedObjectContext: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }
    
    public func entityForName(name:String)-> NSEntityDescription {
        guard let psc = persistentStoreCoordinator else { fatalError("Persistent store missing") }
        guard let entity = psc.managedObjectModel.entitiesByName[name] else { fatalError("Entity with \(name) is not found") }
        return entity
    }
    
    public func createBackgroundContext()->NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
    
    public func saveOrRollback()->Bool {
        do {
            try save()
            return true
        } catch let e {
            print(e)
            rollback()
            return false
        }
    }
    
    public func performChanges(block:()->()) {
        performBlock {
            block()
            self.saveOrRollback()
        }
    }
    
    public func performChangesAndWait(block:()->()) {
        performBlockAndWait {
            block()
            self.saveOrRollback()
        }
    }
    
}

private let SingleObjectCacheKey    = "SingleObjectCache"
private typealias SingleObjectCache = [String:NSManagedObject]

extension NSManagedObjectContext {

    public func setObject(object:NSManagedObject?, forSingleObjectCacheKey key:String) {
        var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
        cache[key] = object
        userInfo[SingleObjectCacheKey] = cache
    }
    
    public func objectForSingleObjectCacheKey(key:String) -> NSManagedObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String:NSManagedObject] else {
            return nil
        }
        return cache[key]
    }

}

















