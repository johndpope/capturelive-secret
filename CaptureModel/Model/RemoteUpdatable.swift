//
//  RemoteUploadable.swift
//  Current
//
//  Created by Scott Jones on 3/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//


import Foundation
import CoreData
import CoreDataHelpers

public protocol JSONHashable {
    func toJSON()->[String:AnyObject]
}

public protocol RemoteRecordType {
//    func valueForKey(key:String, dictionary:[String:AnyObject])->AnyObject?
}

public protocol RemoteRecordMappable {
    func mapTo<T:ManagedObjectType>(managedObject:T)
}

//extension RemoteRecordType {
//    public func valueForKey(key:String, dictionary:[String:AnyObject])->AnyObject? {
//        guard let val = dictionary[key] else {
//            print("\(self.dynamicType)'s JSON has no '\(key)' value!")
//            return nil
//        }
//        return val
//    }
//}

public protocol RemoteUpdatable:class {
    var needsRemoteVerification:Bool { get set }
    func changedInNeedForRemoteVerification()->Bool
}

internal let NeedsRemoteVerification    = "needsRemoteVerification"
internal let ValidationError            = "validationError"

extension RemoteUpdatable {
   
    public func markForNeedsRemoteVerification() {
        needsRemoteVerification         = true
    }
   
    public func unMarkForNeedsRemoteVerification() {
        needsRemoteVerification         = false
    }
    
    public static var markedForRemoteVerificationPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", NeedsRemoteVerification)
    }
    
    public static var notMarkedForRemoteVerificationPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForRemoteVerificationPredicate)
    }
    
}

public protocol RemoteUpdateBlockable:RemoteUpdatable {
    var shouldBlockWhenJSONMapping:Bool { get set }
}
internal let ShouldBlockWhenJSONMapping = "shouldBlockWhenJSONMapping"
extension RemoteUpdateBlockable {

    public static var blockedFromJSONMappingPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", ShouldBlockWhenJSONMapping)
    }
    
    public static var notBlockedFromJSONMappingPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: blockedFromJSONMappingPredicate)
    }
    
}


// Use to populate contracts that have not be fully populated
public protocol RemoteCompletable:class {
    var needsRemoteCompletion:Bool { get set }
    func inNeedForRemoteCompletion()->Bool
}
internal let NeedsRemoteCompletion      = "needsRemoteCompletion"

extension RemoteCompletable {
    
    public func markForNeedsRemoteCompletion() {
        needsRemoteCompletion           = true
    }
    
    public func unMarkForNeedsRemoteCompletion() {
        needsRemoteCompletion           = false
    }
    
    public static var markedForRemoteCompletionPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", NeedsRemoteCompletion)
    }
    
    public static var notMarkedForRemoteCompletionPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForRemoteCompletionPredicate)
    }
    
}


internal let NeedsS3Verification        = "needsS3Verification"
public protocol S3Uploadable:ManagedObjectType {
    var needsS3Verification:Bool { get set }
    var keysForS3Upload:[String] { get }
    func changedInNeedS3Verification()->Bool
}

extension S3Uploadable where Self:KeyCodable, Self:ManagedObject {
   
    public func changedInNeedS3Verification()->Bool {
        return keysForS3Upload.reduce(false) { a, b in
            return a ? a : changedValues()[b] != nil
        }
    }
    
    public func markForNeedsS3Verification() {
        needsS3Verification             = true
    }
    
    public func unMarkForNeedsS3Verification() {
        needsS3Verification             = false
    }
    
    public static var markedForS3VerificationPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", NeedsS3Verification)
    }
    
    public static var notMarkedForS3VerificationPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate:markedForS3VerificationPredicate)
    }
}

