//
//  DelayedDeletable.swift
//  Current
//
//  Created by Scott Jones on 3/10/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreDataHelpers
import CoreData

private let MarkedForDeletionDateKey = "markedForDeletionDate"

public protocol DelayedDeletable :class {
    var changedForDelayedDeletion:Bool { get }
    var markedForDeletionDate:NSDate? { get set }
    func markForLocalDeletion()
}

extension DelayedDeletable {
    public static var notMarkedForLocalDeletionPredicate:NSPredicate {
        return NSPredicate(format: "%K == NULL", MarkedForDeletionDateKey)
    }
}

extension DelayedDeletable where Self:ManagedObject {
    public var changedForDelayedDeletion:Bool {
        return changedValues()[MarkedForDeletionDateKey] as? NSDate != nil
    }
    
    public func markForLocalDeletion() {
        guard fault || markedForDeletionDate == nil else { return }
        markedForDeletionDate = NSDate()
    }
}













