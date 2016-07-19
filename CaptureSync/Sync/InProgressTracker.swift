//
//  InProgressTracker.swift
//  Trans
//
//  Created by Scott Jones on 3/1/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CoreDataHelpers

class InProgressTracker<O:ManagedObject where O:ManagedObjectType> {
    
    private var objectsInProgress = Set<O>()
    
    init() {}
    
    func objectsToProcessFromObjects(objects:[O]) -> [O] {
        let added = objects.filter { !objectsInProgress.contains($0) }
        objectsInProgress.unionInPlace(added)
        return added
    }
    
    func markObjectsAsComplete(objects:[O]) {
        objectsInProgress.subtractInPlace(objects)
    }
    
}

extension InProgressTracker: CustomDebugStringConvertible {
    var debugDescription: String {
        var components = ["InProgressTracker"]
        components.append("count=\(objectsInProgress.count)")
        let all = objectsInProgress.map { $0.objectID.description }.joinWithSeparator("\n")
        components.append("{\n\(all)\n}")
        return components.joinWithSeparator(" ")
    }
}