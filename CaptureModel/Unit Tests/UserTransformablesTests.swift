//
//  UserReelTests.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import CaptureModel

class UserTransformablesTests: XCTestCase {
   
    var managedObjectContext: NSManagedObjectContext!
    var sqliteManagedContext :NSManagedObjectContext?
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        if let sqlm = sqliteManagedContext {
            waitForManagedObjectContextToBeDone(sqlm)
            sqlm.removeTestStore()
            sqlm.destroyTestSqliteContext()
            sqliteManagedContext    = nil
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func destroySqliteContext() {
        sqliteManagedContext!.destroyTestSqliteContext()
        sqliteManagedContext    = nil
    }

    func createUserWithWorkReelInSqlite(userJSON:[String:AnyObject])->User {
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let managedUser         = createUser(fakeUser, moc:sqliteManagedContext!)
        let website = [
            "source"    : "personal"
            ,"type"     : "url"
            ,"value"    : "www.ericshu_mania.com"
        ]
        let instagram = [
            "source"    : "instagram"
            ,"type"     : "username"
            ,"value"    : "2Chus"
        ]
        let reel = [website, instagram].toReelArray()
        sqliteManagedContext!.performChanges {
            managedUser.workReel = reel
        }
        waitForManagedObjectContextToBeDone(sqliteManagedContext!)
        return managedUser
    }

    func createUserWithExperienceInSqlite(userJSON:[String:AnyObject])->User {
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let managedUser         = createUser(fakeUser, moc:sqliteManagedContext!)
        sqliteManagedContext!.performChanges {
            let expDict = [
                 "level": 1
                ,"categories":[
                     "sports"
                    ,"celebrity"
                    ,"news"
                    ,"weather"
                ]
            ]
            managedUser.experience = expDict.toExperience()
        }
        waitForManagedObjectContextToBeDone(sqliteManagedContext!)
        return managedUser
    }
    func createUserWithEquipmentInSqlite(userJSON:[String:AnyObject])->User {
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let managedUser         = createUser(fakeUser, moc:sqliteManagedContext!)
        sqliteManagedContext!.performChanges {
            managedUser.equipment  = [
                    "smartphone_lens"
                    ,"mobile_tripod"
                    ,"selfie_stick"
                    ,"lighting_tools"
                    ,"battery_pack"
            ].toEquipmentArray()
        }
        waitForManagedObjectContextToBeDone(sqliteManagedContext!)
        return managedUser
    }

    func testWorkReelExistsSavedToDisk() {
        // given
        let _ = createUserWithWorkReelInSqlite(fakeUser)
        
        // when
        destroySqliteContext()
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let userRevivedMO       = createUser(fakeUser, moc:sqliteManagedContext!)
        
        // then
        let reelArray = userRevivedMO.workReel
        
        let websiteJSON = reelArray[0]
        XCTAssertEqual("www.ericshu_mania.com", websiteJSON.value)
        XCTAssertEqual(ReelSource.Personal, websiteJSON.source)
        XCTAssertEqual(ReelType.Url, websiteJSON.source.type)

        // instagram
        let instgramJSON = reelArray[1]
        XCTAssertEqual("2Chus", instgramJSON.value)
        XCTAssertEqual(ReelSource.Instagram, instgramJSON.source)
        XCTAssertEqual(ReelType.UserName, instgramJSON.source.type)
    }

    func testExperienceExistsSavedToDisk() {
        // given
        let _ = createUserWithExperienceInSqlite(fakeUser)
        
        // when
        destroySqliteContext()
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let userRevivedMO       = createUser(fakeUser, moc:sqliteManagedContext!)
        
        // then
        guard let exp = userRevivedMO.experience else { XCTFail(); return }
        let experience = exp.toDictionary()
        
        XCTAssertEqual(1, experience["level"]!.shortValue)
        let categories = experience["categories"] as! [String]
        XCTAssertTrue(categories.contains("sports"))
        XCTAssertTrue(categories.contains("celebrity"))
        XCTAssertTrue(categories.contains("news"))
        XCTAssertTrue(categories.contains("weather"))
        XCTAssertFalse(categories.contains("None"))
    }
 
    func testEquipmentExistsSavedToDisk() {
        // given
        let _ = createUserWithEquipmentInSqlite(fakeUser)
        
        // when
        destroySqliteContext()
        sqliteManagedContext    = NSManagedObjectContext.currentTestableSqliteContext()
        let userRevivedMO       = createUser(fakeUser, moc:sqliteManagedContext!)
        
        // then
        guard let experience = userRevivedMO.equipmentArray else { XCTFail(); return }
        
        XCTAssertEqual(5, experience.count)
        XCTAssertTrue(experience.contains("battery_pack"))
        XCTAssertTrue(experience.contains("selfie_stick"))
    }

}
