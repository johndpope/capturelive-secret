//
//  EventUnapplyer.swift
//  Current
//
//  Created by Scott Jones on 3/28/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class EventUnapplyer: ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<Event>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [Event], context: ChangeProcessorContextType) {
        processContractToDelete(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return Event.needsToDeleteRemoteContractPredicate
    }
    
}

extension EventUnapplyer {
    
    func processContractToDelete(objects: [Event], context: ChangeProcessorContextType) {
        guard let event = objects.first else { return }
        guard let contract = event.contract else { fatalError("event does not have a contract to delete") }
        context.remote.deleteRemoteContract(contract, completion: context.performGroupedBlock { [unowned self] error in
            guard let e = error else {
                event.unMarkForNeedsToDeletRemoteContract()
                context.managedObjectContext.deleteObject(contract)
                context.delayedSaveOrRollback()
                self.elementsInProgress.markObjectsAsComplete([event])
                return
            }
            print(e.localizedDescription)
            self.elementsInProgress.markObjectsAsComplete([event])
        })
    }
    
}









