//
//  ValueTransformer.swift
//  Trans
//
//  Created by Scott Jones on 2/13/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation


class ValueTransformer<A: AnyObject, B: AnyObject>: NSValueTransformer {
   
    typealias Transform             = A?->B?
    typealias ReversTransform       = B?->A?
    
    private let transform:Transform
    private let reverseTransform:ReversTransform
   
    init(transform:Transform, reverseTransform:ReversTransform) {
        self.transform              = transform
        self.reverseTransform       = reverseTransform
        super.init()
    }
    
    static func registerTransformerWithName(name:String, transform:Transform, reverseTransform:ReversTransform) {
        let vt = ValueTransformer(transform:transform, reverseTransform:reverseTransform )
        NSValueTransformer.setValueTransformer(vt, forName: name)
    }
    
    override static func transformedValueClass() -> AnyClass {
        return B.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return self.transform(value as? A)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return self.reverseTransform(value as? B)
    }
    
}




















