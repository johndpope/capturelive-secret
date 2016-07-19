//
//  RemoteUserTests.swift
//  Current
//
//  Created by Scott Jones on 3/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
@testable import CaptureModel

class UserTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }

    func testUserJsonTransformsToRemoteUser() {
        // given
        
        // when
        let remoteUser          = RemoteUser(user:fakeUser)
        
        // then
        XCTAssertEqual(remoteUser.urlHash, "b6a910c")
        XCTAssertEqual(remoteUser.createdAt, NSDate(timeIntervalSince1970: 1456845403))
        XCTAssertEqual(remoteUser.updatedAt, NSDate(timeIntervalSince1970: 1457961208))
        XCTAssertEqual(remoteUser.firstName, "Scoats")
        XCTAssertEqual(remoteUser.lastName, "Maloats")
        XCTAssertEqual(remoteUser.phoneNumber, "9085818600")
        XCTAssertEqual(remoteUser.email, "scott+v3@capture.com")
        XCTAssertEqual(remoteUser.instagramUsername, "hatebyte")
        XCTAssertEqual(remoteUser.paypalEmail, "hatebyte@gmail.com")
        XCTAssertEqual(remoteUser.avatar, "https://capture-media-mobile.s3.amazonaws.com/uploads/user/avatar/48/retina_1456845450.jpg")
        XCTAssertEqual(remoteUser.bio, "I like turtles")
        XCTAssertEqual(remoteUser.ageRangeMin, 21)
    }
   
    func testRemoteUserToManagedObjectUser() {
        // given
        
        // when
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedUser.urlHash, "b6a910c")
        XCTAssertEqual(managedUser.createdAt, NSDate(timeIntervalSince1970: 1456845403))
        XCTAssertEqual(managedUser.updatedAt, NSDate(timeIntervalSince1970: 1457961208))
        XCTAssertEqual(managedUser.firstName, "Scoats")
        XCTAssertEqual(managedUser.lastName, "Maloats")
        XCTAssertEqual(managedUser.phoneNumber, "9085818600")
        XCTAssertEqual(managedUser.email, "scott+v3@capture.com")
        XCTAssertEqual(managedUser.instagramUsername, "hatebyte")
        XCTAssertEqual(managedUser.paypalEmail, "hatebyte@gmail.com")
        XCTAssertEqual(managedUser.avatar, "https://capture-media-mobile.s3.amazonaws.com/uploads/user/avatar/48/retina_1456845450.jpg")
        XCTAssertEqual(managedUser.ageRangeMin, 21)
        XCTAssertEqual(managedUser.bio, "I like turtles")
        XCTAssertEqual(managedUser.managedObjectContext, managedObjectContext)
    }
    
    func testRemoteUserUpdatesManagedObjectUserIfUpdatedIsLater() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertEqual(managedUser.firstName, "Scoats")
 
        // when
        var newFakeUser         = fakeUser
        newFakeUser["first_name"] = "Larry"
        newFakeUser["unix_updated_at"] = 1457961308
        _                       = createUser(newFakeUser, moc:managedObjectContext)
 
        // then
        XCTAssertEqual(managedUser.firstName, "Larry")
    }
    
    func testRemoteUserDoesntUpdateManagedObjectUserIfUpdatedIsSame() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertEqual(managedUser.firstName, "Scoats")
        
        // when
        var newFakeUser         = fakeUser
        newFakeUser["first_name"] = "Larry"

        _                       = createUser(newFakeUser, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedUser.firstName, "Scoats")
    }

    func testRemoteUserDoesntUpdateManagedObjectUserIfUpdatedIsEarlier() {
        // given
        let managedUser         = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertEqual(managedUser.firstName, "Scoats")
        
        // when
        var newFakeUser         = fakeUser
        newFakeUser["first_name"] = "Larry"
        newFakeUser["unix_updated_at"] = 1457961108
 
        _                       = createUser(newFakeUser, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedUser.firstName, "Scoats")
    }
    
    func testFacebookTokenNotNilPredicate() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        XCTAssertTrue(User.facebookTokenNilPredicate.evaluateWithObject(managedUser))

        // when
        managedUser.facebookAuthToken = "MA BALLS"
        
        // then
        XCTAssertTrue(User.facebookTokenNotNilPredicate.evaluateWithObject(managedUser))
    }
   
    func testWorkReelIsEmptyPredicateIsTrueDefaultOrWhenEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        
        // when
//        print(managedUser.workReelArray)
        
        // then
        XCTAssertTrue(User.workReelEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertFalse(User.workReelNotEmptyPredicate.evaluateWithObject(managedUser))
    }
   
    func testUserHasNoReelsIfJsonReelIsEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        var userNoReels = fakeUser
        userNoReels["reels"] = []
        let managedUserNoReel             = createUser(userNoReels, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(User.workReelEmptyPredicate.evaluateWithObject(managedUserNoReel))
        XCTAssertTrue(User.notMarkedForRemoteVerificationPredicate.evaluateWithObject(managedUserNoReel))
    }
    
    func testWorkReelIsNotNilPredicate() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            let reel                    = [Reel(value:"Fart", source:.Instagram)]
            managedUser.workReel        = reel
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)

        
        // then
        XCTAssertTrue(User.workReelNotEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertTrue(User.markedForRemoteVerificationPredicate.evaluateWithObject(managedUser))
    }
   
    func testEquipmentIsEmptyPredicateIsTrueDefaultOrWhenEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        //print(managedUser.workReelArray)
        
        // then
        XCTAssertTrue(User.equipmentEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertFalse(User.equipmentNotEmptyPredicate.evaluateWithObject(managedUser))
    }
   
    func testUserHasNoEquipmentIfJsonEquipmentIsEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        var userNoEquipment = fakeUser
        userNoEquipment["equipment"] = []
        let managedUserNoEquipment             = createUser(userNoEquipment, moc:managedObjectContext)
        
        // then
        XCTAssertTrue(User.equipmentEmptyPredicate.evaluateWithObject(managedUserNoEquipment))
        XCTAssertTrue(User.notMarkedForRemoteVerificationPredicate.evaluateWithObject(managedUserNoEquipment))
    }
    
    func testEquipmentIsNotNilPredicate() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            let equipment               = [Equipment.LightingTools, Equipment.MobileTripod]
            managedUser.equipment       = equipment
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(User.equipmentNotEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertTrue(User.markedForRemoteVerificationPredicate.evaluateWithObject(managedUser))
    }
   
    
    func testExperienceIsEmptyPredicateIsTrueDefaultOrWhenEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        //print(managedUser.experiencedDictionary)
        
        // then
        XCTAssertTrue(User.experienceEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertFalse(User.experienceNotEmptyPredicate.evaluateWithObject(managedUser))
    }
   
    func testUserHasNoExperienceIfJsonExperienceIsEmpty() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        var userNoExperience = fakeUser
        userNoExperience["experience"] = [
            "categories" : [],
            //            "level" : NSNull
        ]
        let managedUserNoExperience             = createUser(userNoExperience, moc:managedObjectContext)

        // then
        XCTAssertTrue(User.experienceEmptyPredicate.evaluateWithObject(managedUserNoExperience))
        XCTAssertTrue(User.notMarkedForRemoteVerificationPredicate.evaluateWithObject(managedUserNoExperience))
    }

    func testExperienceIsNotNilPredicate() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            let expDict = [
                "level": 1
                ,"categories":[
                    "sporting_events"
                    ,"concerts"
                    ,"celebrities"
                    ,"red_carpet_events"
                    ,"breaking_news"
                    ,"weather"
                ]
            ]
            managedUser.experience = expDict.toExperience()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(User.experienceNotEmptyPredicate.evaluateWithObject(managedUser))
        XCTAssertTrue(User.markedForRemoteVerificationPredicate.evaluateWithObject(managedUser))
    }

    func testHasNotAcceptedTermsAnConditionsPredicate() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        
        
        // then
        XCTAssertTrue(User.hasNotAcceptedTermsAndConditionsPredicate.evaluateWithObject(managedUser))
    }
    
    func testHasAcceptedTermsAnConditionsPredicateIsTrue() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            managedUser.acceptTermsAndConditions()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(User.hasAcceptedTermsAndConditionsPredicate.evaluateWithObject(managedUser))
    }
    
    func testSavingRemoteAvatarMarksForRemoteAndAddsItToJSON() {
        // given
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.needsRemoteVerification = false
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // when
        managedObjectContext.performChanges {
            managedUser.remoteAvatarUrl = "a url son"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
    
        // then
        XCTAssertTrue(User.markedForRemoteVerificationPredicate.evaluateWithObject(managedUser))
        let json = managedUser.toJSON()
        XCTAssertEqual("a url son", String(json["remote_avatar_url"]!))
    }
    
    func testMappingJsonAddsAvatarAndSetRemoteAvatarUrlToNil() {
        // given
        var jsonWithAvatar = fakeUser
        jsonWithAvatar["avatar"] = "a avatar url son"
        let remoteUser          = RemoteUser(user:jsonWithAvatar)
        
        // manager user with remoteAvatarURL
        let managedUser             = createUser(fakeUser, moc:managedObjectContext)
        managedObjectContext.performChanges {
            managedUser.remoteAvatarUrl = "a url son"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)

        // when
        managedObjectContext.performChanges {
            remoteUser.mapTo(managedUser)
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
       
        // then
        XCTAssertEqual("a avatar url son", managedUser.avatar)
        XCTAssertNil(managedUser.remoteAvatarUrl)
    }
    
}
