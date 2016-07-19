//
//  ContractCreator.swift
//  Current
//
//  Created by Scott Jones on 3/27/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class EventApplyer: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<Event>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [Event], context: ChangeProcessorContextType) {
        processAppliedEvent(objects, context:context)
    }
    
    func processChangedRemoteObjects(context: ChangeProcessorContextType, completion: () -> ()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return Event.needsToCreateContractPredicate
    }
    
}

extension EventApplyer {

    func processAppliedEvent(objects: [Event], context: ChangeProcessorContextType) {
        guard let event = objects.first else {
            return
        }
        context.remote.createRemoteContract(event, completion: context.performGroupedBlock { [unowned self] remoteContract, error in
            guard let rContract = remoteContract else {
                if let e = error {
                    print(e.localizedDescription)
                }
                self.elementsInProgress.markObjectsAsComplete([event])
                return
            }
            let contract = rContract.insertIntoContext(context.managedObjectContext)
            event.unMarkForNeedsRemoteContract(contract)
            context.delayedSaveOrRollback()
            self.elementsInProgress.markObjectsAsComplete([event])
        })
    }
    
}









