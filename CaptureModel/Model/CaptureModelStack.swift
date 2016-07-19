//
//  CurrentModelStack.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreData
import CoreDataHelpers

private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("CaptureModel.currentmodel")

public func createCurrentMainContext(progress: NSProgress? = nil, migrationCompletion: NSManagedObjectContext -> () = { _ in }) -> NSManagedObjectContext? {
    let version = CaptureModelVersion(storeURL: StoreURL)
    User.registerBinaryStringableTransformers()
    User.registerDicationaryTransformers()
    User.registerDictionaryArrayTransformers()
    
    guard version == nil || version == CaptureModelVersion.CurrentVersion else {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, modelVersion: CaptureModelVersion.CurrentVersion, storeURL: StoreURL, progress: progress)
            dispatch_async(dispatch_get_main_queue()) {
                migrationCompletion(context)
            }
        }
        return nil
    }
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, modelVersion: CaptureModelVersion.CurrentVersion, storeURL: StoreURL)
    context.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
    return context
}
