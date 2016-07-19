//
//  LocationUpdatable.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

public protocol RemotePaypalVerifyable:class {
    var needsPaypalVerification:Bool { get set }
    var paypalAccessCode:String? { get set }
    var needsPaypalEmail:Bool { get set }
    var paypalEmail:String? { get set }
}

private let NeedsPaypalVerificationKey = "needsPaypalVerification"
private let NeedsPaypalEmailKey = "needsPaypalEmail"
extension RemotePaypalVerifyable {

    public func markForNeedsPaypalVerification() {
        needsPaypalVerification = true
    }
    
    public func unMarkForNeedsPaypalVerification() {
        needsPaypalVerification = false
        paypalAccessCode        = nil
        needsPaypalEmail        = true
    }

    public func markAsPaypalEmailVerified() {
        needsPaypalEmail        = false
    }
   
    public static var markedForNeedsPaypalVerificationPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", NeedsPaypalVerificationKey)
    }
    
    public static var notMarkedForNeedsPaypalVerificationPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForNeedsPaypalVerificationPredicate)
    }
    
    public static var markedForNeedsPaypalEmailPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", NeedsPaypalEmailKey)
    }
    
    public static var notMarkedForNeedsPaypalEmailPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForNeedsPaypalEmailPredicate)
    }

}