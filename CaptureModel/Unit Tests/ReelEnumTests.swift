//
//  ReelEnumTests.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
@testable import CaptureModel

class ReelEnumTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReelUrls() {
        // given
        let username            = "RufusLeaky"
        
        // when 
        let personalSite = ReelSource.Personal.url(username)!.absoluteString
//        let vimeo = ReelSource.Vimeo.url(username)!.absoluteString
//        let vimeoChannel = ReelSource.VimeoChannel.url(username)!.absoluteString
        let flickr = ReelSource.Flickr.url(username)!.absoluteString
        let fhpx = ReelSource.FiveHundredPX.url(username)!.absoluteString
        let instagram = ReelSource.Instagram.url(username)!.absoluteString
//        let vsco = ReelSource.Vsco.url(username)!.absoluteString
        
        XCTAssertEqual("http://RufusLeaky", personalSite)
//        XCTAssertEqual("https://vimeo.com/RufusLeaky", vimeo)
//        XCTAssertEqual("https://vimeo.com/channels/RufusLeaky", vimeoChannel)
        XCTAssertEqual("http://flickr.com/photos/RufusLeaky", flickr)
        XCTAssertEqual("http://500px.com/RufusLeaky", fhpx)
        XCTAssertEqual("http://instagram.com/RufusLeaky", instagram)
//        XCTAssertEqual("https://vsco.co/RufusLeaky", vsco)
    }
 
    func testPersonSiteFormsCorrectDictionary() {
        // given
        let personalSite = Reel(value:"RufusLeaky.com", source:.Personal)
 
        // when
        let reel = personalSite.toDictionary()

        // then
        XCTAssertEqual("RufusLeaky.com", String(reel["value"]!))
        XCTAssertEqual("personal", String(reel["source"]!))
        XCTAssertEqual("url", String(reel["type"]!))
    }
    
//    func testVimeoFormsCorrectDictionary() {
//        // given
//        let vimeo = Reel(value:"RufusLeaky", source:.Vimeo)
//        
//        // when
//        let reel = vimeo.toDictionary()
//        
//        // then
//        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
//        XCTAssertEqual("vimeo", String(reel["source"]!))
//        XCTAssertEqual("username", String(reel["type"]!))
//    }
    
//    func testVimeoChannelFormsCorrectDictionary() {
//        // given
//        let vimeoChannel = Reel(value:"RufusLeaky", source:.VimeoChannel)
//        
//        // when
//        let reel = vimeoChannel.toDictionary()
//        
//        // then
//        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
//        XCTAssertEqual("vimeo", String(reel["source"]!))
//        XCTAssertEqual("channel", String(reel["type"]!))
//    }
    
    func testFlickrFormsCorrectDictionary() {
        // given
        let flickr = Reel(value:"RufusLeaky", source:.Flickr)
        
        // when
        let reel = flickr.toDictionary()
        
        // then
        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
        XCTAssertEqual("flickr", String(reel["source"]!))
        XCTAssertEqual("username", String(reel["type"]!))
    }

    func test500pxrFormsCorrectDictionary() {
        // given
        let fhpx = Reel(value:"RufusLeaky", source:.FiveHundredPX)
        
        // when
        let reel = fhpx.toDictionary()
        print(reel)
        // then
        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
        XCTAssertEqual("500px", String(reel["source"]!))
        XCTAssertEqual("username", String(reel["type"]!))
    }
    
    func testInstagramFormsCorrectDictionary() {
        // given
        let instagram = Reel(value:"RufusLeaky", source:.Instagram)
        
        // when
        let reel = instagram.toDictionary()
        
        // then
        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
        XCTAssertEqual("instagram", String(reel["source"]!))
        XCTAssertEqual("username", String(reel["type"]!))
    }
    
//    func testVscoFormsCorrectDictionary() {
//        // given
//        let vsco = Reel(value:"RufusLeaky", source:.Vsco)
//        
//        // when
//        let reel = vsco.toDictionary()
//        
//        // then
//        XCTAssertEqual("RufusLeaky", String(reel["value"]!))
//        XCTAssertEqual("vsco", String(reel["source"]!))
//        XCTAssertEqual("username", String(reel["type"]!))
//    }
    
    func testArrayOfReelTypesCanFormAnDictionary() {
        // given
        let personalSite = Reel(value:"RufusLeaky.com", source:.Personal)
//        let vimeo = Reel(value:"RufusLeaky", source:.Vimeo)
//        let vimeoChannel = Reel(value:"RufusLeaky", source:.VimeoChannel)
        let flickr = Reel(value:"RufusLeaky", source:.Flickr)
        let fhpx = Reel(value:"RufusLeaky", source:.FiveHundredPX)
        let instagram = Reel(value:"RufusLeaky", source:.Instagram)
//        let vsco = Reel(value:"RufusLeaky", source:.Vsco)
        
        let reels = [
             personalSite
//            ,vimeo
//            ,vimeoChannel
            ,flickr
            ,fhpx
            ,instagram
//            ,vsco
        ]
        
        // when 
        let reelArray = reels.toJSONArray()
        
        //
        XCTAssertEqual(4, reelArray.count)
        // website
        let websiteJSON = reelArray[0]
        XCTAssertEqual("RufusLeaky.com", String(websiteJSON["value"]!))
        XCTAssertEqual("personal", String(websiteJSON["source"]!))
        XCTAssertEqual("url", String(websiteJSON["type"]!))

//        // vimeo
//        let vimeoJSON = reelArray[1]
//        XCTAssertEqual("RufusLeaky", String(vimeoJSON["value"]!))
//        XCTAssertEqual("vimeo", String(vimeoJSON["source"]!))
//        XCTAssertEqual("username", String(vimeoJSON["type"]!))
//
//        // vimeochannel
//        let vimeoChannelJSON = reelArray[2]
//        XCTAssertEqual("RufusLeaky", String(vimeoChannelJSON["value"]!))
//        XCTAssertEqual("vimeo", String(vimeoChannelJSON["source"]!))
//        XCTAssertEqual("channel", String(vimeoChannelJSON["type"]!))
        
        // flickr
        let flickrJSON = reelArray[1]
        XCTAssertEqual("RufusLeaky", String(flickrJSON["value"]!))
        XCTAssertEqual("flickr", String(flickrJSON["source"]!))
        XCTAssertEqual("username", String(flickrJSON["type"]!))
        
        // fhpx
        let fhpxJSON = reelArray[2]
        XCTAssertEqual("RufusLeaky", String(fhpxJSON["value"]!))
        XCTAssertEqual("500px", String(fhpxJSON["source"]!))
        XCTAssertEqual("username", String(fhpxJSON["type"]!))
       
        // instagram
        let instgramJSON = reelArray[3]
        XCTAssertEqual("RufusLeaky", String(instgramJSON["value"]!))
        XCTAssertEqual("instagram", String(instgramJSON["source"]!))
        XCTAssertEqual("username", String(instgramJSON["type"]!))
        
//        // vsco
//        let vscoJSON = reelArray[6]
//        XCTAssertEqual("RufusLeaky", String(vscoJSON["value"]!))
//        XCTAssertEqual("vsco", String(vscoJSON["source"]!))
//        XCTAssertEqual("username", String(vscoJSON["type"]!))
    }

    func testDictionaryToReel() {
        // given
        let reelsDictArray:[[String:AnyObject]] = [
            [
                 "source"   : "personal"
                ,"type"     : "url"
                ,"value"    : "http://RufusLeaky.com"
            ]
//            ,[
//                "source"    : "vimeo"
//                ,"type"     : "username"
//                ,"value"    : "RufusLeaky"
//            ]
//            ,[
//                "source"    : "vimeo_channel"
//                ,"type"     : "channel"
//                ,"value"    : "RufusLeaky"
//            ]
            ,[
                "source"    : "flickr"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
            ,[
                "source"    : "500px"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
            ,[
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
//            ,[
//                "source"    : "vsco"
//                ,"type"     : "username"
//                ,"value"    : "RufusLeaky"
//            ]
            ,[
                "source"    : "bad_key_to_attempt_array_count_of_8"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
        ]
        
        // when
        let reels = reelsDictArray.toReelArray()
        
        // then
        let webSite = reels.filter{ $0.source == .Personal }.first!
//        let vimeo = reels.filter{ $0.source == .Vimeo }.first!
//        let vimeoChannel = reels.filter{ $0.source == .VimeoChannel }.first!
        let flickr = reels.filter{ $0.source == .Flickr }.first!
        let fhpx = reels.filter{ $0.source == .FiveHundredPX }.first!
        let instagram = reels.filter{ $0.source == .Instagram }.first!
//        let vsco = reels.filter{ $0.source == .Vsco }.first!
        XCTAssertEqual(4, reels.count)
        
        XCTAssertEqual("http://RufusLeaky.com", webSite.value)
        XCTAssertEqual(ReelType.Url, webSite.source.type)
        
//        XCTAssertEqual("RufusLeaky", vimeo.value)
//        XCTAssertEqual(ReelType.UserName, vimeo.source.type)
//
//        XCTAssertEqual("RufusLeaky", vimeoChannel.value)
//        XCTAssertEqual(ReelType.Channel, vimeoChannel.source.type)
        
        XCTAssertEqual("RufusLeaky", flickr.value)
        XCTAssertEqual(ReelType.UserName, flickr.source.type)
        
        XCTAssertEqual("RufusLeaky", fhpx.value)
        XCTAssertEqual(ReelType.UserName, fhpx.source.type)
        
        XCTAssertEqual("RufusLeaky", instagram.value)
        XCTAssertEqual(ReelType.UserName, instagram.source.type)
        
//        XCTAssertEqual("RufusLeaky", vsco.value)
//        XCTAssertEqual(ReelType.UserName, vsco.source.type)
    }
    
}




















