//
//  UserDataProviderTests.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import XCTest
import CaptureModel
@testable import CaptureCore

public enum UserDataObject<Object> {
    case Profile([Object])
    case Experience(Object)
    case Work([Object])
    case PhotoExtras(Object)
}

private class UserDataProviderDelegate:NSObject, DataProviderDelegate {

    var theUpdates:[DataProviderUpdate<UserDataObject<AnyObject>>]? = nil
    func dataProviderDidUpdate(updates: [DataProviderUpdate<UserDataObject<AnyObject>>]?) {
        theUpdates = updates!
    }
    
}

class CreateProfileDataProviderTests: XCTestCase {

    private var userDataProvider:CreateProfileDataProvider<UserDataProviderDelegate>!
    private let delegate = UserDataProviderDelegate()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func getExperience()->[String:AnyObject] {
        let dict = [
            "categories" : ["sports","weather","celebrity"],
            "level"   : NSNumber(unsignedShort:1)
        ]
        return dict
    }

    func getWork()->[[String:AnyObject]] {
        let reelsDictArray:[[String:AnyObject]] = [
            [
                "source"   : "personal"
                ,"type"     : "url"
                ,"value"    : "http://RufusLeaky.com"
            ]
            ,[
                "source"    : "500px"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
            ,[
                "source"    : "flickr"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
            ,[
                "source"    : "instagram"
                ,"type"     : "username"
                ,"value"    : "RufusLeaky"
            ]
        ]
        return reelsDictArray
    }
    
    func getBioNEquipment()->[String:AnyObject] {
        let eq = ["battery_pack", "selfie_stick", "smartphone_lens", "lighting_tools", "mobile_tripod"]
        let bio = "This bio is for the birds"
        return [
            "bio" : bio
            ,"equipment" : eq
        ]
    }
    
    func testUserDataProviderCreatedWithOnlyFacebook() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = ["profile":UserDataObject.Profile(["facebook_avatar_path"])]
        
        // when 
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // then
        XCTAssertEqual(1, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let profileInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch profileInfo {
        case .Profile(let collection):
            XCTAssertEqual("facebook_avatar_path", collection.first! as? String)
        default: XCTFail()
        }
    }

    func testAddingExperienceCreatesExperienceInProviderAndCreatesAnInsertValueForDelegate() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = ["profile":UserDataObject.Profile(["facebook_avatar_path"])]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
 
        // when
        let experience = getExperience()
        userDataProvider.addExperience(UserDataObject.Experience(experience))
        
        // then
        XCTAssertEqual(2, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let experienceInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch experienceInfo {
        case .Experience(let exp):
            let exper = (exp as? [String:AnyObject])!.toExperience()!
            XCTAssertEqual(experience["level"] as? Int, Int(exper.level.rawValue))
            XCTAssertEqual(experience["categories"] as! [String], exper.categories.map { $0.rawValue })
        default: XCTFail()
        }
        
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Insert(let indexPath):
            XCTAssertEqual(1, indexPath.row)
        default: XCTFail()
        }
    }
    
    func testAddingExperienceInUserModelCreatesExperienceInDataProvider() {
        // given
        let experience = getExperience()
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(experience)
        ]

        // when
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
   
        // then
        XCTAssertEqual(2, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let experienceInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch experienceInfo {
        case .Experience(let exp):
            let exper = (exp as? [String:AnyObject])!.toExperience()!
            XCTAssertEqual(experience["level"] as? Int, Int(exper.level.rawValue))
            XCTAssertEqual(experience["categories"] as! [String], exper.categories.map { $0.rawValue })
        default: XCTFail()
        }
    }

    func testReaddingExperienceUpdatesExperienceInProviderAndCreatesAnUpdateValueForDelegate() {
        // given
        let experience = getExperience()
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(experience)
        ]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // when
        let experienceUpdate = [
            "categories" : ["sports"],
            "level"   : NSNumber(unsignedShort:2)
        ]
        userDataProvider.addExperience(UserDataObject.Experience(experienceUpdate))
        
        // then
        XCTAssertEqual(2, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let experienceInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch experienceInfo {
        case .Experience(let exp):
            let exper = (exp as? [String:AnyObject])!.toExperience()!
            XCTAssertEqual(experienceUpdate["level"] as? Int, Int(exper.level.rawValue))
            XCTAssertEqual(experienceUpdate["categories"] as! [String], exper.categories.map { $0.rawValue })
        default: XCTFail()
        }
        
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Update(let indexPath, let experienceUpdated):
            XCTAssertEqual(1, indexPath.row)
            switch experienceUpdated {
            case .Experience(let exp):
                let exper = (exp as? [String:AnyObject])!.toExperience()!
                XCTAssertEqual(experienceUpdate["level"] as? Int, Int(exper.level.rawValue))
                XCTAssertEqual(1, exper.categories.count)
            default: XCTFail()
            }
        default: XCTFail()
        }
    }


    func testAddingEquipmentCreatesEquimentInProviderAndCreatesAnInsertValueForDelegate() {
        // given
        let experience = getExperience()
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(experience)
        ]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // when
        let enteredWork = getWork()
        userDataProvider.addWork(UserDataObject.Work(enteredWork))
        
        // then
        XCTAssertEqual(3, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow:2, inSection: 0)
        let workInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch workInfo {
        case .Work(let w):
            let work = (w as? [[String:AnyObject]])!.toReelArray()
            XCTAssertEqual(4, work.count)
            
        default: XCTFail()
        }
        
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Insert(let indexPath):
            XCTAssertEqual(2, indexPath.row)
        default: XCTFail()
        }
    }
    
    func testReaddingWorkUpdatesWorkInProviderAndCreatesAnUpdateValueForDelegate() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(getExperience()),
            "work":UserDataObject.Work(getWork())
        ]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // when
        let enteredWork:[[String:AnyObject]] = [
            [
                "source"   : "personal"
                ,"type"     : "url"
                ,"value"    : "http://RufusLeaky.com"
            ]
        ]
        userDataProvider.addWork(UserDataObject.Work(enteredWork))
 
    
        // then
        XCTAssertEqual(3, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow:2, inSection: 0)
        let workInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch workInfo {
        case .Work(let w):
            let work = (w as? [[String:AnyObject]])!.toReelArray()
            XCTAssertEqual(1, work.count)
            
        default: XCTFail()
        }
        
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Update(let indexPath, let workDataObject):
            XCTAssertEqual(2, indexPath.row)
            switch workDataObject {
            case .Work(let wObject):
                let work = (wObject as? [[String:AnyObject]])!.toReelArray()
                XCTAssertEqual(1, work.count)
            default: XCTFail()
            }
        default: XCTFail()
        }
    }

    func testAddingWorkInUserModelCreatesWorkInDataProvider() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(getExperience()),
            "work":UserDataObject.Work(getWork())
        ]
        
        // when
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // then
        XCTAssertEqual(3, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow:2, inSection: 0)
        let workInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch workInfo {
        case .Work(let w):
            let work = (w as? [[String:AnyObject]])!.toReelArray()
            XCTAssertEqual(4, work.count)
            
        default: XCTFail()
        }
    }
    
    func testAddingBioNEquipmentInUserModelCreatesBioNEquipmentAnInsertValueForDelegate() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(getExperience()),
            "work":UserDataObject.Work(getWork())
        ]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // when
        let enteredBioNEq = getBioNEquipment()
        userDataProvider.addPhotoExtras(UserDataObject.PhotoExtras(enteredBioNEq))

        // then
        XCTAssertEqual(4, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let experienceInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch experienceInfo {
        case .PhotoExtras(let bioNEq):
            let bioNEquip = (bioNEq as? [String:AnyObject])!.toBioAndEquiment()!
            XCTAssertEqual(enteredBioNEq["bio"] as? String, bioNEquip.bio)
            XCTAssertEqual(enteredBioNEq["equipment"] as! [String], bioNEquip.equipment.map { $0.rawValue })
        default: XCTFail()
        }
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Insert(let indexPath):
            XCTAssertEqual(3, indexPath.row)
        default: XCTFail()
        }
    }
    
    func testReaddingBioNEquipmentUpdatesBioNEquipmentInProviderAndCreatesAnUpdateValueForDelegate() {
        // given
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(getExperience()),
            "work":UserDataObject.Work(getWork()),
            "photo_extras":UserDataObject.PhotoExtras(getWork())
        ]
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
        
        // when
        let enteredBioNEq = [
            "bio" : "This bio is for the eagles"
            ,"equipment" : ["smartphone_lens", "selfie_stick"]
        ]
        userDataProvider.addPhotoExtras(UserDataObject.PhotoExtras(enteredBioNEq))
    
        // then
        XCTAssertEqual(4, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let experienceInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch experienceInfo {
        case .PhotoExtras(let bioNEq):
            let bioNEquip = (bioNEq as? [String:AnyObject])!.toBioAndEquiment()!
            XCTAssertEqual(enteredBioNEq["bio"] as? String, bioNEquip.bio)
            XCTAssertEqual(enteredBioNEq["equipment"] as! [String], bioNEquip.equipment.map { $0.rawValue })
        default: XCTFail()
        }
       
        XCTAssertEqual(1, delegate.theUpdates?.count)
        let update = delegate.theUpdates!.first!
        switch update {
        case .Update(let indexPath, let bioNEqObject):
            XCTAssertEqual(3, indexPath.row)
            switch bioNEqObject {
            case .PhotoExtras(let bNeObject):
                let bNe = (bNeObject as? [String:AnyObject])!.toBioAndEquiment()!
                XCTAssertEqual(2, bNe.equipment.count)
                XCTAssertEqual("This bio is for the eagles", bNe.bio)
            default: XCTFail()
            }
        default: XCTFail()
        }
    }
    
    func testAddingBioNEquipmentInUserModelCreatesBioEquipmentInDataProvider() {
        // given
        let enteredBio = getBioNEquipment()
        let userDictionary:[String:UserDataObject<AnyObject>] = [
            "profile":UserDataObject.Profile(["facebook_avatar_path"]),
            "experience":UserDataObject.Experience(getExperience()),
            "work":UserDataObject.Work(getWork()),
            "photo_extras":UserDataObject.PhotoExtras(enteredBio)
        ]
        
        // when
        userDataProvider = CreateProfileDataProvider(userDictionary:userDictionary, delegate: delegate)
    
        // then
        XCTAssertEqual(4, userDataProvider.numberOfItemsInSection(0))
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let bioNEqInfo = userDataProvider.objectAtIndexPath(indexPath)
        switch bioNEqInfo {
        case .PhotoExtras(let bioNEq):
            let bioNEquip = (bioNEq as? [String:AnyObject])!.toBioAndEquiment()!
            XCTAssertEqual(enteredBio["bio"] as? String, bioNEquip.bio)
            XCTAssertEqual(enteredBio["equipment"] as! [String], bioNEquip.equipment.map { $0.rawValue })
        default: XCTFail()
        }
    }
    
}
