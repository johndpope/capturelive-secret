//
//  CurrentTests.swift
//  CurrentTests
//
//  Created by Scott Jones on 3/7/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureCore
import CaptureModel
import CaptureSync
@testable import CaptureLive

final class FakeRemoteAndLocallyService: RemoteAndLocallyServiceable {
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    init(managedObjectContext: NSManagedObjectContext,remoteService: CaptureLiveRemoteType) {
        self.managedObjectContext   = managedObjectContext
        self.remoteService          = remoteService
    }
}

func validateApiToken(dbAndService:ConsoleRemote, moc:NSManagedObjectContext) {
    moc.performChanges {
        dbAndService.saveToken("Ma balls")
    }
    waitForManagedObjectContextToBeDone(moc)
}

func preventScreenByPass(moc:NSManagedObjectContext) {
    moc.performChanges {
        moc.preventScreenByPass()
    }
    waitForManagedObjectContextToBeDone(moc)
}

func allowScreenByPass(moc:NSManagedObjectContext) {
    moc.performChanges {
        moc.allowScreenByPass()
    }
    waitForManagedObjectContextToBeDone(moc)
}

func attemptLoginUser(json:[String:AnyObject], moc:NSManagedObjectContext) {
    let managedUser         = createUser(json, moc:moc)
    managedUser.setAsAttemptingLoginUser()
}

func addToAttemptingUser(moc:NSManagedObjectContext, block:(user:User)->()) {
    guard let attemptingloggedInUser = User.attemptingLoginUser(moc) else {
        XCTFail(); return
    }
    moc.performChanges {
        block(user:attemptingloggedInUser)
    }
    waitForManagedObjectContextToBeDone(moc)
}



class UserNavigationTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    var consoleRemote :ConsoleRemote!
    var remoteAndLocalService:FakeRemoteAndLocallyService!
    
    override func setUp() {
        super.setUp()
        managedObjectContext        = NSManagedObjectContext.currentInMemoryContext()
        consoleRemote               = ConsoleRemote(persistanceLayer:managedObjectContext)
        remoteAndLocalService       = FakeRemoteAndLocallyService(managedObjectContext: managedObjectContext, remoteService: consoleRemote)
    }
    
    override func tearDown() {
        managedObjectContext        = nil
        super.tearDown()
    }
    
    func userNeedsFinishCreateEquiment(){
        attemptLoginUser(needsCreateEquipment, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func userNeedsFinishCreateExperience(){
        attemptLoginUser(needsCreateExperience, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
   
    func userNeedsFinishTermsAndConditions(){
        attemptLoginUser(needsTermsAndConditions, moc:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }

    
}
