//
//  Date+Sync.swift
//  Trans
//
//  Created by Scott Jones on 3/6/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element : NSDate {
    
    public func earliest()->NSDate {
        return NSDate(timeIntervalSince1970: map { $0.timeIntervalSince1970 }
            .flatMap { $0 }
            .reduce(NSTimeInterval(FLT_MAX)) { $0 < $1 ? $0 : $1 })
    }
    
    public func latest()->NSDate {
        return NSDate(timeIntervalSince1970:map { $0.timeIntervalSince1970 }
            .flatMap { $0 }
            .reduce(0) { $0 > $1 ? $0 : $1 })
    }
    
}