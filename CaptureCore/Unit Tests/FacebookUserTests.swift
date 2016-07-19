//
//  FacebookUserTests.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
@testable import CaptureCore

class FacebookUserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMappingFacebookUserFromJSON() {
        // given
        let facebookuserJSON    = facebookUser
        
        // when 
        let fbUser = FacebookUser(json:facebookuserJSON)
        
        // then
        XCTAssertEqual("Scott", fbUser.firstName)
        XCTAssertEqual("Jones", fbUser.lastName)
        XCTAssertEqual("scott@capture.com", fbUser.email)
        XCTAssertEqual(21, fbUser.ageRangeMin)
        XCTAssertEqual("https://graph.facebook.com/100007054787196/picture?height=600&width=600", fbUser.avatarPath)
        XCTAssertTrue(fbUser.isOverAgeRange)
        XCTAssertEqual("https://www.facebook.com/app_scoped_user_id/100007054787196/", fbUser.profileUrl)
    }
   
    func testFaceuserTokenCanBeNull() {
        // given
        let facebookuserJSON    = facebookUser
        
        // when
        let fbUser = FacebookUser(json:facebookuserJSON)
        
        // then
        XCTAssertNil(fbUser.token)
    }
    
    
    func testFaceuserTokenCanBePopulated() {
        // given
        let facebookuserJSON    = facebookUser
        var fbUser = FacebookUser(json:facebookuserJSON)
        XCTAssertNil(fbUser.token)
 
        // when
        fbUser.token = "MA BALLS AGAIN"
        
        // then
        XCTAssertNotNil(fbUser.token)
        XCTAssertEqual("MA BALLS AGAIN", fbUser.token)
    }

}
