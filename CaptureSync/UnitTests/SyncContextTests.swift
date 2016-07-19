//
//  SyncContextTests.swift
//  Current
//
//  Created by Scott Jones on 3/24/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import XCTest
import CoreData
import CoreDataHelpers
@testable import CaptureSync

public func AssertEqual<T:Equatable>(@autoclosure expression1:()->T?, @autoclosure _ expression2:()->T?, _ message:String = "", file: String = #file, line: UInt = #line, @noescape continuation: ()->() = {} ) {
    let a = expression1()
    let b = expression2()
    if a != b {
        XCTFail("\(a) != \(b) \(message)")
    } else {
        continuation()
    }
}

private class TestSyncContext : ContextOwnerType {
    let mainManagedObjectContext:NSManagedObjectContext
    let syncManagedObjectContext:NSManagedObjectContext
    let syncGroup = dispatch_group_create()!
    var didSetup = true
    var observerTokens:[NSObjectProtocol] = []
    
    func addObserverToken(token:NSObjectProtocol) {
        observerTokens.append(token)
    }
    
    init(mainManagedObjectContext:NSManagedObjectContext, syncManagedObjectContext:NSManagedObjectContext) {
        self.mainManagedObjectContext = mainManagedObjectContext
        self.syncManagedObjectContext = syncManagedObjectContext
        setupContexts()
    }
    
    var changedObjects:[NSManagedObject] = []
    func processChangedLocalObjects(managedObjects:[NSManagedObject]) {
        changedObjects += managedObjects
    }
}

class SyncContextTests: XCTestCase {
    
    private var sut:TestSyncContext? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        tearDownContext()
        super.tearDown()
    }
    
    func createContext() {
        let psc = createPersistentStoreCoordinatorWithInMemoryStore()
        
        // create both context, but keep them of the main thread running tests
        let main = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        main.name = "main"
        main.persistentStoreCoordinator = psc
        let sync = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        sync.name = "sync"
        sync.persistentStoreCoordinator = psc
        
        sut = TestSyncContext(mainManagedObjectContext: main, syncManagedObjectContext: sync)
    }
    
    func tearDownContext() {
        if let context = sut {
            sut = nil
            // removes observers
            context.observerTokens = []
            // wait the the work to be done, blocking it from the next test
            context.syncGroup.spinUntilEmpty()
            
            let group = dispatch_group_create()
            dispatch_group_enter(group)
            context.mainManagedObjectContext.performBlock {
                dispatch_group_leave(group)
            }
            dispatch_group_enter(group)
            context.syncManagedObjectContext.performBlock {
                dispatch_group_leave(group)
            }
            group.spinUntilEmpty()
        }
    }
    
    func waitForSutManagedObjectContextToBeDone() {
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        sut!.mainManagedObjectContext.performBlock {
            dispatch_group_leave(group)
        }
        dispatch_group_enter(group)
        sut!.syncManagedObjectContext.performBlock {
            dispatch_group_leave(group)
        }
        group.spinUntilEmpty()
        sut!.syncGroup.spinUntilEmpty()
    }
    
    func insertObject()->(onMain:TestObject, onSync:TestObject) {
        let group = sut!.syncGroup
        let main = sut!.mainManagedObjectContext
        let sync = sut!.syncManagedObjectContext
        var objectOnMain:TestObject?
        var objectOnSync:TestObject?
        
        main.performBlockWithGroup(group) {
            objectOnMain = main.insertObject() as TestObject
            try! main.save()
            sync.performBlockWithGroup(group) {
                objectOnSync = .Some(sync.objectWithID(objectOnMain!.objectID) as! TestObject)
            }
        }
        waitForSutManagedObjectContextToBeDone()
        return (onMain:objectOnMain!, onSync:objectOnSync!)
    }
    
    func testThatInsertingOnTheMainContextSendsLocalChanges() {
        // given
        createContext()
       
        // when
        let (onMain:_, onSync:mo) = insertObject()
        
        // then
        AssertEqual(sut!.changedObjects.count, 1) {
            XCTAssert(sut!.changedObjects.first! == mo)
        }
    }
    
    func testUpdateingOnTheMainContextSendsLocalChanges() {
        // given
        createContext()
        let (onMain:objectOnMain, onSync:mo) = insertObject()
        waitForSutManagedObjectContextToBeDone()
        sut!.changedObjects = []
        
        // when
        let main = sut!.mainManagedObjectContext
        main.performBlockWithGroup(sut!.syncGroup) {
            objectOnMain.name = "New Name"
            try! main.save()
        }
        waitForSutManagedObjectContextToBeDone()
        
        // then
        AssertEqual(sut!.changedObjects.count, 1) {
            XCTAssert(sut!.changedObjects.first! === mo)
        }
    }
    
}







