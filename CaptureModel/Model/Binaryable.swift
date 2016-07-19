//
//  BinaryStringable.swift
//  Current
//
//  Created by Scott Jones on 3/29/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

public protocol BinaryStringArrayTransformable {}

private var transformerStringArrayRegistrationToken: dispatch_once_t = 0
private let StringArrayTransformerName = "StringArrayTransformerName"

typealias StringArray = [String]
extension BinaryStringArrayTransformable where Self:ManagedObject {
    
    static func registerBinaryStringableTransformers() {
        dispatch_once(&transformerStringArrayRegistrationToken) {
            ValueTransformer.registerTransformerWithName(StringArrayTransformerName, transform: { sArray in
                guard let sarr = sArray else { return nil }
                return NSKeyedArchiver.archivedDataWithRootObject(sarr)
                }, reverseTransform: { (data: NSData?) -> NSArray? in
                    guard let sarr = data else { return nil }
                    return NSKeyedUnarchiver.unarchiveObjectWithData(sarr) as? StringArray
            })
        }
    }
    
}

public protocol BinaryDicationaryTransformable {}

typealias ErrorDictionary = [String:AnyObject]
private var transformerRegistrationToken: dispatch_once_t = 0
private let DictionaryTransformerName = "DictionaryTransformerName"
extension BinaryDicationaryTransformable {

    static func registerDicationaryTransformers() {
        dispatch_once(&transformerRegistrationToken) {
            ValueTransformer.registerTransformerWithName(DictionaryTransformerName, transform: { errDict in
                guard let edict = errDict else { return nil }
                return NSKeyedArchiver.archivedDataWithRootObject(edict)
                }, reverseTransform: { (data: NSData?) -> NSDictionary? in
                    guard let edata = data else { return nil }
                    return NSKeyedUnarchiver.unarchiveObjectWithData(edata) as? ErrorDictionary
            })
        }
    }

}


public protocol BinaryDictionaryArrayTransformable {}

private var transformerDictionaryArrayRegistrationToken: dispatch_once_t = 0
private let DictionaryArrayTransformerName = "DictionaryArrayTransformerName"

typealias DictionaryArray = [[String:AnyObject]]
extension BinaryDictionaryArrayTransformable where Self:ManagedObject {
    
    static func registerDictionaryArrayTransformers() {
        dispatch_once(&transformerDictionaryArrayRegistrationToken) {
            ValueTransformer.registerTransformerWithName(DictionaryArrayTransformerName, transform: { sArray in
                guard let sarr = sArray else { return nil }
                return NSKeyedArchiver.archivedDataWithRootObject(sarr)
                }, reverseTransform: { (data: NSData?) -> NSArray? in
                    guard let sarr = data else { return nil }
                    return NSKeyedUnarchiver.unarchiveObjectWithData(sarr) as? DictionaryArray
            })
        }
    }
    
}
