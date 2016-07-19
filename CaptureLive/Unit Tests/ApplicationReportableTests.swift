//
//  ApplicationReportableTests.swift
//  Current
//
//  Created by Scott Jones on 3/25/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureCore
import CaptureModel
import CaptureSync
@testable import CaptureLive

class ApplicationReportableTests: XCTestCase {
    
    var applicationReportable:ApplicationReportable!
    var context:NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        self.applicationReportable = NSManagedObjectContext.currentInMemoryContext()
        context                     = applicationReportable as! NSManagedObjectContext
    }
    
    override func tearDown() {
        self.applicationReportable = nil
        super.tearDown()
    }

    func testSpecsReturnsPopulatedDictionary() {
        // given
        
        // when
        let specs                  = applicationReportable.appSpecs
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
        
        // then
        let fromCache = context.metaData["com.current.applicationreportable.metakey"] as! [String:AnyObject]
        XCTAssertNotNil(fromCache)
        XCTAssertNotNil(specs["app_version_name"])
        XCTAssertEqual(specs["app_version_name"] as? String, fromCache["app_version_name"] as? String)
        XCTAssertNotNil(specs["app_build"])
        XCTAssertEqual(specs["app_build"] as? String, fromCache["app_build"] as? String)
        XCTAssertNotNil(specs["app_name"])
        XCTAssertEqual(specs["app_name"] as? String, fromCache["app_name"] as? String)
        XCTAssertNotNil(specs["platform"])
        XCTAssertEqual(specs["platform"] as? String, fromCache["platform"] as? String)
        
        XCTAssertNil(specs["push_token"])
    }
    
    func testAppSpecsWithTokenIntialllyHasNilToken() {
        // given
        
        // when
        let specs                  = applicationReportable.appSpecsWithToken
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
        
        // then
        XCTAssertNil(specs["push_token"])
    }
    
    func testAppSpecsWithTokenReturnsTokenWhenSet() {
        // given
        applicationReportable.pushToken = "the push token"
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
 
        // when
        let specs                  = applicationReportable.appSpecsWithToken
        context.saveOrRollback()
        waitForManagedObjectContextToBeDone(context)
        
        // then
        XCTAssertNotNil(specs["push_token"])
        XCTAssertEqual(specs["push_token"] as? String, "the push token")
    }
    
 

}
