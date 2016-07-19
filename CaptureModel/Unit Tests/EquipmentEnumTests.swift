//
//  EquipmentEnumTests.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
@testable import CaptureModel

class EquipmentEnumTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateStringArrayCanFromEquipmentArray() {
        // given
        let equipment:[Equipment] = [.SmartPhoneLens ,.MobileTripod, .SelfieStick, .LightingTools, .BatteryPack]
        
        // when 
        let equipmentArray = equipment.toLiteralArray()
        
        // then
        XCTAssertEqual(5, equipmentArray.count)
        XCTAssertTrue(equipmentArray.contains("smartphone_lens"))
        XCTAssertTrue(equipmentArray.contains("mobile_tripod"))
        XCTAssertTrue(equipmentArray.contains("selfie_stick"))
        XCTAssertTrue(equipmentArray.contains("lighting_tools"))
        XCTAssertTrue(equipmentArray.contains("battery_pack"))
//        XCTAssertTrue(equipmentArray.contains("boom_mic"))
    }
    
    
    func testCreateEquipmentArrayCanFromStringArray() {
        // given
        let equipment = ["smartphone_lens", "mobile_tripod", "selfie_stick", "lighting_tools", "battery_pack"]
        
        // when
        let equipmentArray = equipment.toEquipmentArray()
        
        // then
        XCTAssertEqual(5, equipmentArray.count)
        XCTAssertTrue(equipmentArray.contains(.SmartPhoneLens))
//        XCTAssertTrue(equipmentArray.contains(.SteadiCamera))
        XCTAssertTrue(equipmentArray.contains(.MobileTripod))
        XCTAssertTrue(equipmentArray.contains(.SelfieStick))
        XCTAssertTrue(equipmentArray.contains(.LightingTools))
        XCTAssertTrue(equipmentArray.contains(.BatteryPack))
//        XCTAssertTrue(equipmentArray.contains(.BoomMic))
    }
    
    func testCreateEquipmentArrayCanFromStringArrayAndOmmitsValueNotInEnum() {
        // given
        let equipment = ["smartphone_lens", "mobile_tripod", "selfie_stick", "lighting_tools", "battery_pack", "Barf"]

        // when
        let equipmentArray = equipment.toEquipmentArray()
        
        // then
        XCTAssertEqual(5, equipmentArray.count)
        XCTAssertTrue(equipmentArray.contains(.SmartPhoneLens))
        //        XCTAssertTrue(equipmentArray.contains(.SteadiCamera))
        XCTAssertTrue(equipmentArray.contains(.MobileTripod))
        XCTAssertTrue(equipmentArray.contains(.SelfieStick))
        XCTAssertTrue(equipmentArray.contains(.LightingTools))
        XCTAssertTrue(equipmentArray.contains(.BatteryPack))
        //        XCTAssertTrue(equipmentArray.contains(.BoomMic))
    }
 
    func testCreateEquipmentAndBioFromDictionary() {
        // given
        let eqNBDict = [
            "bio"           : "This bio is for the birds"
            ,"equipment" : ["smartphone_lens", "mobile_tripod", "selfie_stick", "lighting_tools", "battery_pack"]
        ]
        
        // when
        let eqNB = eqNBDict.toBioAndEquiment()!
        
        // then
        XCTAssertEqual("This bio is for the birds", eqNB.bio)
        XCTAssertEqual(5, eqNB.equipment.count)
    }
    
    func testCreateDictionaryFromBioAndEquiment() {
        // given
        let eqNB = BioAndEquiment(
            bio:"This bio is for the birds"
            , equipment: [.SmartPhoneLens ,.MobileTripod, .SelfieStick, .LightingTools, .BatteryPack])
        
        // when 
        let eqNBDict = eqNB.toDictionary()
    
        // then
        XCTAssertEqual("This bio is for the birds", eqNBDict["bio"] as? String)
        let eq = eqNBDict["equipment"] as! [String]
        XCTAssertEqual(5, eq.count)
        XCTAssertEqual("smartphone_lens", eq.first)
        XCTAssertEqual("battery_pack", eq.last)
    }
    
    
    
    
    
    
}
