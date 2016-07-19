//
//  NSPersistentStore+Extensions.swift
//  Current
//
//  Created by Scott Jones on 3/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
    public static func destroyStoreAtURL(url: NSURL) {
        do {
            let psc = self.init(managedObjectModel: NSManagedObjectModel())
            if #available(iOS 9.0, *) {
                try psc.destroyPersistentStoreAtURL(url, withType: NSSQLiteStoreType, options: nil)
            }
        } catch let e {
            print("failed to destroy persistent store at \(url)", e)
        }
    }
    
    public static func replaceStoreAtURL(targetURL: NSURL, withStoreAtURL sourceURL: NSURL) throws {
        let psc = self.init(managedObjectModel: NSManagedObjectModel())
        if #available(iOS 9.0, *) {
            try psc.replacePersistentStoreAtURL(targetURL, destinationOptions: nil, withPersistentStoreFromURL: sourceURL, sourceOptions: nil, storeType: NSSQLiteStoreType)
        }
    }
}