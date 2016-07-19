//
//  ChangeProcessor.swift
//  Trans
//
//  Created by Scott Jones on 2/21/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CaptureModel

protocol ChangeProcessorType {
   
    // called at begin to give processor a change to configure itself
    func setupForContext(context:ChangeProcessorContextType)
    
    // for local inserted or updated
    func processChangedLocalObjects(objects:[NSManagedObject], context:ChangeProcessorContextType)
    
    // for changes in remote records
    func processChangedRemoteObjects(context:ChangeProcessorContextType, completion:()->())
    
    // on launch, fetch objects scheduled for remote saving
    // pass them to `processChangedLocalObjects()`
    func entityAndPredicateForLocallyTrackedObjectsInContext(context:ChangeProcessorContextType) -> EntityAndPredicate?
    
    // does the initial fetch from the remote
    func fetchLatestRemoteRecordsForContext(context:ChangeProcessorContextType)
    
    
}

protocol ChangeProcessorContextType: class {
    
    var managedObjectContext:NSManagedObjectContext { get }

    var remote:CaptureLiveRemoteType { get }
    
    // wraps a block so it can run on the correct queue
    func performGroupedBlock(block: ()->() )

    // wraps a block so it can run on the correct queue
    func performGroupedBlock<A>(block: (A)->() ) -> (A)->()
    
    // wraps a block so it can run on the correct queue
    func performGroupedBlock<A,B>(block: (A,B)->() ) -> (A,B)->()
   
    // wraps a block so it can run on the correct queue
    func performGroupedBlock<A,B,C>(block: (A,B,C)->() ) -> (A,B,C)->()
    
    // Save eventually, May batch multiple calls into a single call to `saveOrRollback`
    func delayedSaveOrRollback()
}



protocol ElementChangeProcessorType: ChangeProcessorType {

    associatedtype Element: ManagedObject, ManagedObjectType
    
    // tracks elements in progress
    var elementsInProgress:InProgressTracker<Element> { get }
    
    // any objects that match predicate
    func processChangedLocalElements(objects:[Element], context:ChangeProcessorContextType)
    
    // the elements this processor is interested in
    // Used by `entityAndPredicateForLocallyTrackedObjectsInContext(_:)`
    var predicateForLocallyTrackedElements:NSPredicate { get }
    
}

extension ElementChangeProcessorType {

    func processChangedLocalObjects(objects:[NSManagedObject], context: ChangeProcessorContextType) {
        // filters elements according to the `entityAndPredicateForLocallyTrackedObjectsInContext`
        // then forwards the results to the `processChangedLocalElements(_:context:completion:)`
        let matching = objects.objectsMatching(entityAndPredicateForLocallyTrackedObjectsInContext(context)!)
        if let elements = matching as? [Element] {
            let newElements = elementsInProgress.objectsToProcessFromObjects(elements)
            processChangedLocalElements(newElements, context: context)
        }
    }
   
    func didCompleteElements(objects:[Element], context:ChangeProcessorContextType) {
        elementsInProgress.markObjectsAsComplete(objects)
        // Now check again if anything still matches
        let p = predicateForLocallyTrackedElements
        let matching = objects.filter(p.evaluateWithObject)
        let newElements = elementsInProgress.objectsToProcessFromObjects(matching)
        if newElements.count > 0 {
            processChangedLocalElements(newElements, context: context)
        }
    }
    
    func entityAndPredicateForLocallyTrackedObjectsInContext(context: ChangeProcessorContextType) -> EntityAndPredicate? {
        let predicate = predicateForLocallyTrackedElements
        return EntityAndPredicate(entityName: Element.entityName, predicate: predicate, context: context)
    }
    
}


























