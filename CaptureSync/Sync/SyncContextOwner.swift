//
//  SyncContextOwner.swift
//  Trans
//
//  Created by Scott Jones on 2/21/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


// This protocol merges changes between the main context and the sync context and backwards
// It calls its `processChangedLocalObjects()` methods when the objects have changed
protocol ContextOwnerType:class, ObserverTokenStore {
    var mainManagedObjectContext:NSManagedObjectContext { get }
    var syncManagedObjectContext:NSManagedObjectContext { get }
    var syncGroup:dispatch_group_t { get }
    var didSetup: Bool { get }
    
    // called when ever objects have changed
    func processChangedLocalObjects(managedObjects:[NSManagedObject])
}


extension ContextOwnerType {

    func setupContexts() {
        setupContextNotificationObserving()
    }
    
    private func setupContextNotificationObserving() {
        addObserverToken(
            mainManagedObjectContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.mainContextDidSave(note)
            }
        )
        addObserverToken(
            syncManagedObjectContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.syncContextDidSave(note)
            }
        )
        addObserverToken(
            syncManagedObjectContext.addObjectsDidChangeNotification { [weak self] note in
                self?.objectsInSyncContextDidChange(note)
            }
        )
    }
   
    private func mainContextDidSave(note:ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performMergeChangedFromContextDidSaveNotification(note)
        notifyAboutChangedObjectsFromSaveNotification(note)
    }

    private func syncContextDidSave(note:ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        mainManagedObjectContext.performMergeChangedFromContextDidSaveNotification(note)
        notifyAboutChangedObjectsFromSaveNotification(note)
    }
    
    private func objectsInSyncContextDidChange(note:ObjectsDidChangeNotification) {
        precondition(didSetup, "Did not call setup()")
    }
    
    private func notifyAboutChangedObjectsFromSaveNotification(note:ContextDidSaveNotification) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performBlockWithGroup(syncGroup) {
            let updates = note.updatedObjects.remapToContext(self.syncManagedObjectContext)
            let inserts = note.insertedObjects.remapToContext(self.syncManagedObjectContext)
            self.processChangedLocalObjects(updates + inserts)
        }
    }
    
}












