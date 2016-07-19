//
//  ReactorTests.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
@testable import CaptureCore


class ReactorTests: XCTestCase {
    
    var reactor:Reactor!
    var incrementor             = 0

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        reactor                 = nil
        super.tearDown()
    }
   
    func testReactsTo0() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        
        // then
        XCTAssertEqual(0, incrementor)
    }
    
    func testReactsTo1() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        reactor.goIfPlausible()
    
        // then
        XCTAssertEqual(1, incrementor)
    }
    
    func testReactsTo2As1() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        reactor.goIfPlausible()
        reactor.goIfPlausible()
 
        // then
        XCTAssertEqual(1, incrementor)
    }

   
    func testReactsTo3As1() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        reactor.goIfPlausible()
        reactor.goIfPlausible()
        reactor.goIfPlausible()
        
        // then
        XCTAssertEqual(1, incrementor)
    }

    func testReactsTo2as2IfReset() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        reactor.goIfPlausible()
        reactor.reset()
        reactor.goIfPlausible()
 
        // then
        XCTAssertEqual(2, incrementor)
    }

    func testReactsTo3as3IfReset() {
        // given
        reactor                 = Reactor(execution:{ self.incrementor += 1 })
        
        // when
        reactor.goIfPlausible()
        reactor.reset()
        reactor.goIfPlausible()
        reactor.reset()
        reactor.goIfPlausible()
 
        // then
        XCTAssertEqual(3, incrementor)
    }

}
