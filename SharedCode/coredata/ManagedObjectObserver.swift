//
//  ManagedObjectObserver.swift
//  Trans
//
//  Created by Scott Jones on 2/15/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData

public final class ManagedObjectObserver {
    
    public enum ChangeType {
        case Delete
        case Update
    }
    
    //MARK: Private
    private var token:NSObjectProtocol!
    private var objectHasBeenDeleted:Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(token)
    }
    
    public init?(object:ManagedObjectType, changeHandler:ChangeType->()) {
        //register
        guard let moc = object.managedObjectContext else { return nil }
        self.objectHasBeenDeleted = !object.dynamicType.defaultPredicate.evaluateWithObject(object)
        self.token = moc.addObjectsDidChangeNotification({ [unowned self] wrappedNote in
            guard let changeType = self.changeTypeOfObject(object, inNotification:wrappedNote) else { return }
            self.objectHasBeenDeleted = (changeType == .Delete)
            changeHandler(changeType)
        })
    }
    
    func changeTypeOfObject(object:ManagedObjectType, inNotification notification:ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = notification.deletedObjects.union(notification.invalidatedObjects)
        if notification.invalidatedAllObjects || deleted.containsObjectIdenticalTo(object) {
            return .Delete
        }
        let updated = notification.updatedObjects.union(notification.refreshedObjects)
        if updated.containsObjectIdenticalTo(object) {
            let predicate = object.dynamicType.defaultPredicate
            if predicate.evaluateWithObject(object) {
                return .Update
            } else {
                return .Delete
            }
        }
        return nil
    }
    
}





















