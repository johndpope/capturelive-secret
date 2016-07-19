//
//  SyncCoordinator.swift
//  Trans
//
//  Created by Scott Jones on 2/21/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel
import CoreDataHelpers

public protocol CloudKitNotificationDrain {
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject])
}
public let CoordinaterDidFetchNewRemoteDataNotification = "CoordinaterDidFetchNewRemoteDataNotification"
public final class SyncCoordinator {

    internal typealias ApplicationDidBecomeActive = ()->()
    
    private var setupToken = dispatch_once_t()
    private var observerTokens:[NSObjectProtocol] = []
    internal let changeProcessors:[ChangeProcessorType]
    var needsTearDown = Int32(1)
    
 
    let mainManagedObjectContext:NSManagedObjectContext
    public private(set) var syncManagedObjectContext:NSManagedObjectContext
    let syncGroup:dispatch_group_t = dispatch_group_create()
    var didSetup:Bool { return setupToken != 0 }
    var needsTeardown = Int32(1)
    let remote:CaptureLiveRemoteType

    public init(mainManagedObjectContext mainMOC:NSManagedObjectContext, remote syncremote:CaptureLiveRemoteType) {
        remote                      = syncremote
        assert(mainMOC.concurrencyType == .MainQueueConcurrencyType)
        mainManagedObjectContext    = mainMOC
        syncManagedObjectContext    = mainMOC.createBackgroundContext()
        syncManagedObjectContext.name = "SyncCoordinator"
        syncManagedObjectContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
        //DayMergePolicy(.Remote)
       
        changeProcessors            = [
             RemoteUserUpdater()
            ,RemoteUserPaypalUpdater()
            ,EventApplyer()
            ,EventUnapplyer()
//            ,ContractCompleter()
            ,ContractUpdater()
            ,AttachmentUpdater()
            ,AttachmentThumbnailUploader()
            ,RemoteFileUpdater()
            ,NotificationUpdater()
            
            ,RemoteUserDownloader()
            ,EventDownloader()
            ,ContractHistoryDownloader()
            ,NotificationDownloader()
        ]
        setup()
    }
    
    // The `tearDown` method must be called in order to stop the sync coordinator
    public func tearDown() {
        guard OSAtomicCompareAndSwapInt(1, 0, &needsTearDown) else { return }
        performGroupedBlock {
            self.removeAllObserverTokens()
        }
    }
    
    deinit {
        // We must not call tearDown at this point, because we cannot call async code from with in deinit
        // We want to be able to call async code inside tearDown() to make sure things run on the right thread
        guard needsTearDown == 0 else { fatalError("deinit called without tearDown() being called") }
    }
    
    private func setup() {
        dispatch_once(&setupToken) {
            self.performGroupedBlock {
                //since the are modifying the observerTokens, they need to run on the same queue
                self.setupContexts()
                self.setupChangeProcessors()
                self.setupApplicationActiveNotifications()
                self.setupForEventsFetchRequestNotication()
            }
        }
    }
}

extension SyncCoordinator : CloudKitNotificationDrain {
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        performGroupedBlock {
            self.fetchLatestRemoteData()
        }
    }
}


//MARK: ContextOwnerType
extension SyncCoordinator : ContextOwnerType {
    
    func addObserverToken(token: NSObjectProtocol) {
        precondition(didSetup, "Did not call setup()")
        observerTokens.append(token)
    }
    
    func removeAllObserverTokens() {
        precondition(didSetup, "Did not call setup()")
        observerTokens.removeAll()
    }
    
    func processChangedLocalObjects(objects: [NSManagedObject]) {
        precondition(didSetup, "Did not call setup()")
        for cp in changeProcessors {
            cp.processChangedLocalObjects(objects, context:self)
        }
    }
    
}


//MARK: ChangeProcessorContextOwnerType
extension SyncCoordinator : ChangeProcessorContextType {
    
    var managedObjectContext:NSManagedObjectContext {
        precondition(didSetup, "Did not call setup()")
        return self.syncManagedObjectContext
    }
    
    func performGroupedBlock(block: ()->() ) {
        precondition(didSetup, "Did not call setup()")
        syncManagedObjectContext.performBlockWithGroup(syncGroup, block: block)
    }
   
    func performGroupedBlock<A>(block: (A)->() ) -> (A)->() {
        precondition(didSetup, "Did not call setup()")
        return { (a:A)->() in
            self.performGroupedBlock({ () -> () in
                block(a)
            })
        }
    }

    func performGroupedBlock<A,B>(block: (A,B)->() ) -> (A,B)->() {
        precondition(didSetup, "Did not call setup()")
        return { (a:A, b:B)->() in
            self.performGroupedBlock({ () -> () in
                block(a,b)
            })
        }
    }
    
    func performGroupedBlock<A,B,C>(block: (A,B,C)->() ) -> (A,B,C)->() {
        precondition(didSetup, "Did not call setup()")
        return { (a:A, b:B,c:C)->() in
            self.performGroupedBlock({ () -> () in
                block(a,b,c)
            })
        }
    }
    
    func delayedSaveOrRollback() {
        managedObjectContext.delayedSaveOrRollbackWithGroup(syncGroup)
    }
    
}

extension SyncCoordinator {

    private func setupChangeProcessors() {
        precondition(didSetup, "Did not call setup()")
        for cp in self.changeProcessors {
            cp.setupForContext(self)
        }
    }
    
}


extension SyncCoordinator : ApplicationActiveStateObserving {

    // this is where the exit and entering of the app syncs local and remote data
    func applicationDidBecomeActive() {
        precondition(didSetup, "Did not call setup()")
        fetchLocallyTrackedObjects()
        fetchRemoteDataForApplicationDidBecomeActive()
    }
   
    func applicationDidEnterBackground() {
        precondition(didSetup, "Did not call setup()")
        if #available(iOS 8.3, *) {
            syncManagedObjectContext.refreshAllObjects()
        }
    }
    
    private func fetchLocallyTrackedObjects() {
        precondition(didSetup, "Did not call setup()")
        self.performGroupedBlock {
            var objects:Set<NSManagedObject> = []
            for cp in self.changeProcessors {
                guard let entityAndPredicate = cp.entityAndPredicateForLocallyTrackedObjectsInContext(self) else { continue }
                let request = entityAndPredicate.fetchRequest
                request.returnsObjectsAsFaults = false
                guard let results = try! self.syncManagedObjectContext.executeFetchRequest(request) as? [NSManagedObject] else {
                    fatalError()
                }
                objects.unionInPlace(results)
            }
            self.processChangedLocalObjects(Array(objects))
        }
    }
    
}

extension SyncCoordinator : ApplicationRequestModelDataObserving {
    
    func applicationDidRequestMoreEventData() {
        self.fetchRemoteDataFromAppRequest()
    }

}

// MARK: Remote
extension SyncCoordinator {
    
    private func fetchRemoteDataForApplicationDidBecomeActive() {
        self.fetchLatestRemoteData()
    }
    
    private func fetchRemoteDataFromAppRequest() {
        self.fetchLatestRemoteData()
    }

    private func fetchLatestRemoteData() {
        self.processChangedRemoteObjects {
            self.performGroupedBlock {
                self.managedObjectContext.delayedSaveOrRollbackWithGroup(self.syncGroup) { _ in
                    NSNotificationCenter.defaultCenter().postNotificationName(CoordinaterDidFetchNewRemoteDataNotification, object: self)
                    print("FETCHED ALL REMOTE OBJECTS EVEN")
                }
            }
            
        }
    }
    
    private func processChangedRemoteObjects(completion:() -> ()) {
        self.changeProcessors.asyncForEachWithCompletion(completion) { changeProcessor, innerCompletion in
            performGroupedBlock {
                changeProcessor.processChangedRemoteObjects(self, completion:innerCompletion)
            }
        }
    }
    
}


















