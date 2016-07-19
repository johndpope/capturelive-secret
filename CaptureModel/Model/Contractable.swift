//
//  ContractCreatable.swift
//  Current
//
//  Created by Scott Jones on 3/27/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

private let NeedsToCreateRemoteContractKey = "needsToCreateRemoteContract"
public protocol ContractCreatable:class {
    var contract:Contract? { get set }
    var needsToCreateRemoteContract:Bool { get set }
    func markForNeedsRemoteContract()
    func unMarkForNeedsRemoteContract(contract:Contract)
}

extension ContractCreatable where Self:Event {
    
    public func markForNeedsRemoteContract() {
        needsToCreateRemoteContract = true
    }

    public func unMarkForNeedsRemoteContract(contract:Contract) {
        needsToCreateRemoteContract = false
        self.contract = contract
    }
   
    static private var needsToCreateRemoteContractTruePredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", NeedsToCreateRemoteContractKey, NSNumber(bool: true))
    }
    
    static private var needsToCreateRemoteContractFalsePredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", NeedsToCreateRemoteContractKey, NSNumber(bool: false))
    }
    
    static public var needsToCreateContractPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [notPastHiringCutoffDatePredicate, contractIsNilPredicate, needsToCreateRemoteContractTruePredicate])
    }
    
    static public var canMarkForCreateRemoteContractPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [needsToCreateRemoteContractFalsePredicate, notPastHiringCutoffDatePredicate, contractIsNilPredicate])
    }
    
}


private let NeedsToDeleteRemoteContractKey = "needsToDeleteRemoteContract"
public protocol ContractDeletable:ContractCreatable {
    var needsToDeleteRemoteContract:Bool { get set }
    func markForNeedsToDeleteRemoteContract()
    func unMarkForNeedsToDeletRemoteContract()
}

extension ContractDeletable where Self:Event {
    
    public func markForNeedsToDeleteRemoteContract() {
        needsToDeleteRemoteContract = true
    }
    
    public func unMarkForNeedsToDeletRemoteContract() {
        needsToDeleteRemoteContract = false
    }
    
    static private var needsToDeleteRemoteContractTruePredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", NeedsToDeleteRemoteContractKey, NSNumber(bool: true))
    }
    
    static private var needsToDeleteRemoteContractFalsePredicate:NSPredicate {
        return NSPredicate(format: "%K == %@", NeedsToDeleteRemoteContractKey, NSNumber(bool: false))
    }
    
    static public var needsToDeleteRemoteContractPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [needsToDeleteRemoteContractTruePredicate, needsToCreateRemoteContractFalsePredicate])
    }

    static public var canMarkForDeleteRemoteContractPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [needsToDeleteRemoteContractFalsePredicate, needsToCreateRemoteContractFalsePredicate, contractIsNotNilPredicate, contractIsNotAcquiredPredicate])
    }

}

