//
//  PublisherReactor.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

public typealias ExecutionClosure = ()->()

public class Reactor:NSObject {

    private var didFire = dispatch_once_t()
    public var execution:ExecutionClosure

    public init(execution:ExecutionClosure) {
        self.execution = execution
    }
   
    public func goIfPlausible() {
        dispatch_once(&didFire) { [unowned self] in
            self.execution()
        }
    }
    
    public func reset() {
        didFire = 0
    }

}



















