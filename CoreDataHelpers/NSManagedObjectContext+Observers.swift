//
//  NSManagedObjectContext+Observer.swift
//  Trans
//
//  Created by Scott Jones on 2/15/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData

public struct ContextDidSaveNotification {
    
    public init(note:NSNotification) {
        guard note.name == NSManagedObjectContextDidSaveNotification else { fatalError() }
        self.notification = note
    }
    
    public var insertedObjects:AnyGenerator<ManagedObject> {
        return generatorForKey(NSInsertedObjectsKey)
    }
   
    public var updatedObjects:AnyGenerator<ManagedObject> {
        return generatorForKey(NSUpdatedObjectsKey)
    }
    
    public var deletedObjects:AnyGenerator<ManagedObject> {
        return generatorForKey(NSDeletedObjectsKey)
    }
    
    public var managedObjectContext:NSManagedObjectContext {
        guard let c = self.notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    
    //MARK : Private
    private let notification:NSNotification
   
    private func generatorForKey(key:String)->AnyGenerator<ManagedObject> {
        guard let set = self.notification.userInfo?[key] as? NSSet else {
            return AnyGenerator { nil }
        }
        let innerGenerator = set.generate()
        return AnyGenerator { return innerGenerator.next() as? ManagedObject }
    }
}

public struct ContextWillSaveNotification {
    public init(note:NSNotification) {
        assert(note.name == NSManagedObjectContextWillSaveNotification)
        notification = note
    }
    
    public var managedObjectContext:NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    private let notification:NSNotification
}

public struct ObjectsDidChangeNotification {

    init(note:NSNotification) {
        assert(note.name == NSManagedObjectContextObjectsDidChangeNotification)
        self.notification = note
    }
    
    public var insertedObjects:Set<ManagedObject> {
        return self.objectsForKey(NSInsertedObjectsKey)
    }

    public var updatedObjects:Set<ManagedObject> {
        return self.objectsForKey(NSUpdatedObjectsKey)
    }
    
    public var deletedObjects:Set<ManagedObject> {
        return self.objectsForKey(NSDeletedObjectsKey)
    }
    
    public var refreshedObjects:Set<ManagedObject> {
        return self.objectsForKey(NSRefreshedObjectsKey)
    }
   
    public var invalidatedObjects:Set<ManagedObject> {
        return self.objectsForKey(NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects:Bool {
        return self.notification.userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
    
    public var managedObjectContext:NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    //MARK: Private
    private let notification:NSNotification
    private func objectsForKey(key:String)->Set<ManagedObject> {
        return (notification.userInfo?[key]) as? Set<ManagedObject> ?? Set()
    }
    
}

extension NSManagedObjectContext {
    
    public func addContextDidSaveNotificationObserver(handler:ContextDidSaveNotification -> ()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextDidSaveNotification, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note:note)
            return handler(wrappedNote)
        }
    }
    
    public func addContextWillNotification(handler:ContextWillSaveNotification->()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextWillSaveNotification, object: self, queue: nil) { note in
            let wrappedNote = ContextWillSaveNotification(note:note)
            handler(wrappedNote)
        }
    }
    
    public func addObjectsDidChangeNotification(handler:ObjectsDidChangeNotification->()) -> NSObjectProtocol {
        let nc = NSNotificationCenter.defaultCenter()
        return nc.addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note:note)
            handler(wrappedNote)
        }
    }
    
    public func performMergeChangedFromContextDidSaveNotification(note:ContextDidSaveNotification) {
        self.performBlock {
            self.mergeChangesFromContextDidSaveNotification(note.notification)
        }
    }
    
}








