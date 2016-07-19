//
//  ContractHistoryDownloader.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

final class ContractHistoryDownloader : ChangeProcessorType {
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        context.remote.fetchCompletedRemoteContracts { remoteContracts in
            context.performGroupedBlock { [unowned self] in
                self.saveCompletedRemoteContracts(remoteContracts, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
                completion()
            }
        }
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        context.remote.fetchCompletedRemoteContracts { remoteContracts in
            context.performGroupedBlock { [unowned self] in
                self.saveCompletedRemoteContracts(remoteContracts, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
            }
        }
    }
    
    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        return nil
    }
    
}

extension ContractHistoryDownloader {

    private func saveCompletedRemoteContracts(remoteContracts:[RemoteContract], inContext moc:NSManagedObjectContext) {
        for remoteContract in remoteContracts {
            remoteContract.insertIntoContext(moc)
        }
    }
    
}

