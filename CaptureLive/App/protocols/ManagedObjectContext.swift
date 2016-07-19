//
//  ManagedObjectContextSettable.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreData

protocol ManagedObjectContextSettable:class {
    var managedObjectContext: NSManagedObjectContext! { get set }
}
