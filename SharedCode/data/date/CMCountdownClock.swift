//
//  CMCountdownClock.swift
//  Current
//
//  Created by Scott Jones on 8/21/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public typealias TimerUpdate = (Int)->()
public typealias ProgressUpdate = (Double)->()
public typealias TimerEnded = ()->()

public class CMCountdownClock: NSObject {

    var timer:NSTimer!
    var incrementClosure:TimerUpdate?
    var finalClosure:TimerEnded?
    var progressClosure:ProgressUpdate?
    var _index:Int                  = 0
    var interval:Double             = 1 / 30
    var _total:Int                  = 0
    
    public init(progressClosure:ProgressUpdate?, incrementClosure:TimerUpdate?, finalClosure:TimerEnded?) {
        super.init()
        self.incrementClosure       = incrementClosure
        self.progressClosure        = progressClosure
        self.finalClosure           = finalClosure
        self.from                   = 3
    }
    
    public func start() {
        self.timer                  = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(CMCountdownClock.update), userInfo: nil, repeats:true)
    }
    
    public var from:Int {
        get {
            return _index * 30
        }
        set {
            _index                  = ((newValue) * 30)
            _total                  = _index
        }
    }
    
    public func update() {
        _index -= 1
        if _index <= 0 {
            self.finalClosure?()
            kill()
        } else {
            if _index % 30 == 0 {
                self.incrementClosure?(_index / 30)
            }
            self.progressClosure?(Double(1) - Double(_index) / Double(_total))
        }
    }

    public func kill() {
        self.progressClosure = nil
        self.incrementClosure = nil
        self.finalClosure = nil
        self.timer.invalidate()
    }

}
