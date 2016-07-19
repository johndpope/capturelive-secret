//
//  BackendModel.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

public protocol Comparable:ManagedObjectType {
    var createdAt: NSDate { get set }
    var updatedAt: NSDate { get set }
}

public protocol RemoteComparable:Comparable {
    var urlHash: String { get set }
    static func predicateForUnique(urlHash:String) -> NSPredicate
}

public enum RemoteComparableKeys : String {
    case CreatedAt  = "createdAt"
    case UpdatedAt  = "updatedAt"
    case UrlHash    = "urlHash"
}

extension RemoteComparable {
    
    public static func predicateForUnique(urlHash:String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", RemoteComparableKeys.UrlHash.rawValue, urlHash)
    }
    
}

extension RemoteComparable where Self:ManagedObject {
    
    public static func insertOrUpdate(moc:NSManagedObjectContext, urlHash:String, configure:Self -> ()) -> Self {
        let uniquePredicate                 = predicateForUnique(urlHash)
        let obj = insertOrUpdate(moc, matchingPredicate:uniquePredicate) { obj in
            configure(obj)
        }
        return obj
    }
    
}




public protocol LocalComparable:Comparable {
    var uuid: String { get set }
    static func predicateForUnique(uuid:String) -> NSPredicate
}

public enum LocalComparableKeys : String {
    case CreatedAt  = "createdAt"
    case UpdatedAt  = "updatedAt"
    case Uuid       = "uuid"
}

extension LocalComparable {
    
    public static func predicateForUnique(uuid:String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", LocalComparableKeys.Uuid.rawValue, uuid)
    }
    
}

extension LocalComparable where Self:ManagedObject {
    
    public static func insertOrUpdate(moc:NSManagedObjectContext, uuid:String, configure:Self -> ()) -> Self {
        let uniquePredicate                 = predicateForUnique(uuid)
        let obj = insertOrUpdate(moc, matchingPredicate:uniquePredicate) { obj in
            configure(obj)
        }
        return obj
    }
    
}


