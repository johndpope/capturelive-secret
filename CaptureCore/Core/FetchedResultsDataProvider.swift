//
//  FetchResultsDataProvider.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/31/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CoreDataHelpers

public class FetchedResultsDataViewModelProvider<Delegate:DataProviderDelegate, ModelType:TableViewCellModelType where ModelType.Model == Delegate.Object, ModelType:ManagedObjectType>: NSObject, NSFetchedResultsControllerDelegate, DataProvider {

    public typealias Object = Delegate.Object

    public init(fetchedResultsController:NSFetchedResultsController, delegate:Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
   
    public func reconfigureFetchRequest(@noescape block:NSFetchRequest->()) {
        NSFetchedResultsController.deleteCacheWithName(fetchedResultsController.cacheName)
        block(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("Fetch request failed") }
        delegate.dataProviderDidUpdate(nil)
    }
    
    public func numRecordsForRequest()->Int {
        var error:NSError?
        let result = fetchedResultsController.managedObjectContext.countForFetchRequest(fetchedResultsController.fetchRequest, error: &error)
        guard result != NSNotFound else { fatalError("Failed to execute fetch request: \(error)") }
        return result
    }
    
    public func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        guard let result = fetchedResultsController.objectAtIndexPath(indexPath) as? ModelType else { fatalError("Unexpected object at \(indexPath)") }
        return result.tableCellViewModel()
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else { return 0 }
        return sec.numberOfObjects
    }
    
    
    
    // MARK: Private
    private let fetchedResultsController:NSFetchedResultsController
    private weak var delegate:Delegate!
    private var updates:[DataProviderUpdate<Object>] = []
    
   
    // MARK: NSFetchedResultControllerDelegate
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        updates = []
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.Insert(indexPath))
        case .Update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(indexPath)
            updates.append(.Update(indexPath, object))
        case .Move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("newIndexPath path should be not nil") }
            updates.append(.Move(indexPath, newIndexPath))
        case .Delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.Delete(indexPath))
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        delegate.dataProviderDidUpdate(updates)
    }
    
}

















