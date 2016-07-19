//
//  ManagedObject.swift
//  Trans
//
//  Created by Scott Jones on 2/13/16.
//  Copyright © 2016 *. All rights reserved.
//

import CoreData

public class ManagedObject : NSManagedObject {
}

public protocol ManagedObjectType : class {
    static var entityName:String { get }
    static var defaultSortDescriptors:[NSSortDescriptor] { get }
    static var defaultPredicate:NSPredicate { get }
    var managedObjectContext:NSManagedObjectContext? { get }
}

extension ManagedObjectType {

    public static var defaultSortDescriptor:[NSSortDescriptor] {
        return []
    }
    
    public static var sortedFetchRequest:NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
    
    public static func sortedFetchRequestWithPredicate(predicate:NSPredicate) -> NSFetchRequest {
        let request = sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }
    
    public static func predicateWithPredicate(predicate:NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
    
}


extension ManagedObjectType where Self : ManagedObject {
  
    public static func insertOrUpdate(moc:NSManagedObjectContext, matchingPredicate predicate:NSPredicate, configure:Self -> ())->Self {
        guard let obj = findOrFetchInContext(moc, matchingPredicate: predicate) else {
            let newObject:Self = moc.insertObject()
            configure(newObject)
            return newObject
        }
        configure(obj)
        return obj
    }
    
    public static func findOrCreateInContext(moc:NSManagedObjectContext, matchingPredicate predicate:NSPredicate, configure:Self -> ()) -> Self {
        guard let obj = findOrFetchInContext(moc, matchingPredicate: predicate) else {
            let newObject:Self = moc.insertObject()
            configure(newObject)
            return newObject
        }
        return obj
    }
    
    public static func findOrFetchInContext(moc:NSManagedObjectContext, matchingPredicate predicate:NSPredicate) -> Self? {
        guard let obj = materializedObjectInContext(moc, matchingPredicate:predicate) else {
            return fetchInContext(moc) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return obj
    }
    
    public static func fetchInContext(context:NSManagedObjectContext, @noescape configurationBlock:NSFetchRequest -> () = { _ in } ) -> [Self] {
        let request = NSFetchRequest(entityName: Self.entityName)
        configurationBlock(request)
        guard let result = try! context.executeFetchRequest(request) as? [Self] else {
            fatalError("Fetched objects have wrong type")
        }
        return result
    }
    
    public static func countInContext(context:NSManagedObjectContext, @noescape configurationBlock:NSFetchRequest -> () = { _ in }) -> Int {
        let request = NSFetchRequest(entityName:Self.entityName)
        configurationBlock(request)
        var error:NSError?
        let result = context.countForFetchRequest(request, error: &error)
        guard result != NSNotFound else { fatalError("Failed to execute fetch request: \(error)") }
        return result
    }
    
    public static func materializedObjectInContext(moc:NSManagedObjectContext, matchingPredicate predicate:NSPredicate) -> Self? {
        for obj in moc.registeredObjects where !obj.fault {
            guard let res = obj as? Self where predicate.evaluateWithObject(res) else { continue }
            return res
        }
        return nil
    }
    
}

extension ManagedObjectType where Self:ManagedObject {

    public static func fetchSingleObjectInContext(moc:NSManagedObjectContext, cacheKey:String, configure:NSFetchRequest->())->Self? {
        // find it in cache or create it and put in in cache
        guard let cached = moc.objectForSingleObjectCacheKey(cacheKey) as? Self else {
            let result = fetchSingleObjectInContext(moc, configure: configure)
            return result
        }
        return cached
    }
    
    private static func fetchSingleObjectInContext(moc:NSManagedObjectContext, configure:NSFetchRequest->())->Self? {
        let result = fetchInContext(moc) { request in
            configure(request)
            request.fetchLimit = 2
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
    
}






























