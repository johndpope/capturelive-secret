//
//  ExperienceEnumTests.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
@testable import CaptureModel

class ExperienceEnumTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
//    case SportingEvents     = "sporting_events"
//    case Concerts           = "concerts"
//    case Celebrities        = "celebrities"
//    case RedCarpetEvents    = "red_carpet_events"
//    case BreakingNews       = "breaking_news"
//    case Weather            = "weather"
    func testCreateExperienceCanFromDictionary() {
        // given
        let experience = Experience(categories:[.Sports, .Weather, .Celebrity], level:.TwoToFive)
        
        // when
        let experienceDict = experience.toDictionary()
        
        // then
        guard let history = experienceDict["categories"] as? [String] else { XCTFail(); return }
        XCTAssertEqual(3, history.count)
        XCTAssertEqual("sports", history.first)
        XCTAssertEqual("celebrity", history.last)
        
        guard let years = experienceDict["level"] as? NSNumber else { XCTFail(); return }
        XCTAssertEqual(1, years)
    }
    
    func testCreateDictionaryCanFromExperience() {
        // given
        let dict = [
            "categories" : ["sports","weather","celebrity"],
            "level"   : NSNumber(unsignedShort:1)
        ]
        
        // when
        let experience = dict.toExperience()
        
        // then
        XCTAssertEqual(Category.Sports, experience!.categories.first)
        XCTAssertEqual(Level.TwoToFive, experience!.level)
    }
    
    func testDictionaryToExperienceAndOmmitsHistoryThatsNotEnum() {
        // given
        let dict = [
            "categories" : ["Larry is fake", "And_a_liar"],
            "level"   : NSNumber(unsignedShort:6)
        ]
        
        // when
        let experience = dict.toExperience()
        
        // then
        XCTAssertNil(experience)

    }


    
}