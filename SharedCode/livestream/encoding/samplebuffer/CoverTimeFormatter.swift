//
//  CoverTimeFormatter.swift
//  Current
//
//  Created by Scott Jones on 9/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class Box<T>  {
    public let unbox: T
    public init(_ value: T) {
        self.unbox = value
    }
}

class CoverTimeFormatter: NSObject {

    var time:Double                 = 0
    var adjusment:Double            = 0
    var zeroplace                   = true
    
    init(adjustment:Int = 0) {
        super.init()
        self.adjusment              = Double(adjustment)
    }
    
    func coverageTime()->Box<CoverageTime> {
        if (self.time < self.adjusment) {
            let c                   = ("00","00","00","00")
            return Box(c)
        }
        let t                       = secondsInt()
        let c                       = (hours(t), minutes(t), seconds(t), milliseconds())
        return Box(c)
    }
    
    func configure(number:Int)->String {
        if number < 10 {
            return "0\(number)"
        }
        return "\(number)"
    }
    
    func reset() {
        self.time                   = 0
    }
    
    func milliseconds()->String {
        return String(NSString(format:"%.2f", fmod(self.time, 1)).substringFromIndex(2))
    }

    func seconds(time:Int)->String {
        return "\(configure(time % 60))"
    }
    
    func minutes(time:Int)->String {
        return "\(configure(minutesInt(time)))"
    }
    
    func hours(time:Int)->String {
        return "\(configure(hoursInt(time)))"
    }

    func hoursInt(time:Int)->Int {
        return time / (60 * 60)
    }
    
    func minutesInt(time:Int)->Int {
        return (time / 60) % 60
    }

    func secondsInt()->Int {
        return Int(floor(self.time - self.adjusment))
    }

}
