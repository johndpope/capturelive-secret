//
//  ContractCompleter.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/28/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

final class ContractCompleter: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<Contract>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [Contract], context: ChangeProcessorContextType) {
        processIncompleteContracts(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return Contract.markedForRemoteCompletionPredicate
    }
    
}

extension ContractCompleter {
    
    func processIncompleteContracts(contracts: [Contract], context: ChangeProcessorContextType) {
        guard let contract = contracts.first else {
            return
        }
        context.remote.fetchRemoteContract(contract, completion: context.performGroupedBlock { [unowned self] remoteContract, error in
            guard let rContract = remoteContract else {
                self.elementsInProgress.markObjectsAsComplete([contract])
                return
            }
            
            let contract = rContract.insertIntoContext(context.managedObjectContext)
            context.performGroupedBlock({
                rContract.forceMap(contract, moc:context.managedObjectContext)
                context.managedObjectContext.saveOrRollback()
            })
            context.performGroupedBlock({ [unowned self] in
                contract.unMarkForNeedsRemoteCompletion()
                context.delayedSaveOrRollback()
                self.elementsInProgress.markObjectsAsComplete([contract])
            })
        })
    }
    
}