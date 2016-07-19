//
//  CachedNotificationTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/14/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//


import XCTest
import CoreData
import CaptureModel
@testable import CaptureCore

class CachedNotificationTests: XCTestCase {

    var managedObjectContext:NSManagedObjectContext!
    let userInfo:[NSObject:AnyObject] = [
         "aps": [
             "alert" : "You have arrived at the location for %{event_name}"
            ,"badge" : 6
        ]
        ,"type"      : 41
        ,"url_hash"  : "66ce23c"
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
    
    func testCanCacheAUserInfoJson() {
        // given
        managedObjectContext                    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.cacheNotification(userInfo)
        
        // then
        XCTAssertNotNil(managedObjectContext.cachedNotificationUserInfo())
    }
   
    func testAfterCachedUserInfoIsReadItIsNil() {
        // given
        managedObjectContext                    = NSManagedObjectContext.currentInMemoryContext()
        
        // when
        managedObjectContext.cacheNotification(userInfo)
        let _ = managedObjectContext.cachedNotificationUserInfo()
        
        // then
        let currentUserInfo = managedObjectContext.cachedNotificationUserInfo()
        XCTAssertNil(currentUserInfo)
    }
    
}

