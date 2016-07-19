//
//  UserUpdaterTests.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreDataHelpers
@testable import CaptureSync

private class TestContext:ChangeProcessorContextType {
    
    let managedObjectContext:NSManagedObjectContext
    
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    var remote:CaptureLiveRemoteType {
        fatalError() // nah
    }
    
    func performGroupedBlock(block: ()->() ) {
        block()
    }
   
    func performGroupedBlock<A>(block: (A)->() ) -> (A)->() {
        return { (a:A)->() in
            block(a)
        }
    }
    
    func performGroupedBlock<A,B>(block: (A,B)->() ) -> (A,B)->() {
        return { (a:A, b:B)->() in
            block(a,b)
        }
    }
    
    func performGroupedBlock<A,B,C>(block: (A,B,C)->() ) -> (A,B,C)->() {
        return { (a:A, b:B, c:C)->() in
            block(a,b,c)
        }
    }
    
    func delayedSaveOrRollback() {
        XCTFail()
    }
    
}

class UserUpdaterTests: XCTestCase {
    
    var consoleRemote :ConsoleRemote!
    var userUpdater = RemoteUserUpdater()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
