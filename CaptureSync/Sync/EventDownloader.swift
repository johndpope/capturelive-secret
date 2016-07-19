//
//  EventDownloader.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreData
import CaptureModel

final class EventDownloader : ChangeProcessorType {
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalObjects(objects: [NSManagedObject], context: ChangeProcessorContextType) {
        // no - op
    }
   
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        context.remote.fetchLatestRemoteEvents { remoteEvents, remoteContracts in
            context.performGroupedBlock {
                self.insertRemoteEvents(remoteEvents, remoteContracts:remoteContracts, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
                completion()
            }
        }
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        context.remote.fetchLatestRemoteEvents { remoteEvents, remoteContracts in
            context.performGroupedBlock {
                self.insertRemoteEvents(remoteEvents, remoteContracts:remoteContracts, inContext:context.managedObjectContext)
                context.delayedSaveOrRollback()
            }
        }
    }

    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        return nil
    }

}

extension EventDownloader {

    private func insertRemoteEvents(remoteEvents:[RemoteEvent], remoteContracts:[RemoteContract], inContext moc:NSManagedObjectContext) {
        for event in remoteEvents {
            event.insertIntoContext(moc)
        }

        for contract in remoteContracts {
            contract.insertIntoContext(moc)
        }
    }
    
}

