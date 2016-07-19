//
//  AgeRangeLimitable.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation


private let AgeLimit:UInt16 = 18
public protocol AgeRangeLimitable {
    var ageRangeMin:UInt16 { get }
}

extension AgeRangeLimitable {
    public var isOverAgeRange:Bool {
        return ageRangeMin >= AgeLimit
    }
}
