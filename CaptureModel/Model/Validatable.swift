//
//  Validatable.swift
//  Current
//
//  Created by Scott Jones on 3/17/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


public protocol Validatable:BinaryDicationaryTransformable {
    var validationError:[String:AnyObject]? { get set } 
}

extension Validatable where Self:ManagedObject {

}

extension Validatable where Self:protocol<ManagedObjectType, RemoteUpdatable> {
    
    public static var hasValidationErrorPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: hasNoValidationErrorPredicate)
    }
    
    public static var hasNoValidationErrorPredicate:NSPredicate {
        return NSPredicate(format:"%K == NULL", ValidationError)
    }
   
    public static var remotelyValidPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates:[notMarkedForRemoteVerificationPredicate, hasNoValidationErrorPredicate])
    }
   
}