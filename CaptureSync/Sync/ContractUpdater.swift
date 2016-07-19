//
//  ContractEnder.swift
//  Current
//
//  Created by Scott Jones on 4/7/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

final class ContractUpdater : ElementChangeProcessorType {
    
    var elementsInProgress = InProgressTracker<Contract>()
    
    func setupForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    func processChangedLocalElements(objects: [Contract], context: ChangeProcessorContextType) {
        processContractToUpdate(objects, context:context)
    }
    
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->()) {
        completion()
    }
    
    func fetchLatestRemoteRecordsForContext(context: ChangeProcessorContextType) {
        // no - op
    }
    
    var predicateForLocallyTrackedElements:NSPredicate {
        return Contract.markedForRemoteVerificationPredicate
    }
    
}

extension ContractUpdater {
    
    func processContractToUpdate(objects: [Contract], context: ChangeProcessorContextType) {
        guard let contract = objects.first else { return }
        context.remote.updateRemoteContract(contract, completion: context.performGroupedBlock { [unowned self] error in
            guard let e = error else {
                contract.unMarkForNeedsRemoteVerification()
                context.delayedSaveOrRollback()
                self.elementsInProgress.markObjectsAsComplete([contract])
                return
            }
            print(e.localizedDescription)
            self.elementsInProgress.markObjectsAsComplete([contract])
        })
    }
    
}