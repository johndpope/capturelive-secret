//
//  ProfileDataProvider.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/10/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureUI

class DefaultDataProvider<Delegate:DataProviderDelegate>:NSObject, DataProvider {
    
    typealias Object            = Delegate.Object
    
    private var items :[Object]!
    private weak var delegate:Delegate!
    
    init(items:[Object], delegate:Delegate) {
        self.items              = items
        self.delegate           = delegate
        super.init()
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        return items[indexPath.row]
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return items.count
    }
    
}

class DefaultSectionableDataProvider<Delegate:DataProviderDelegate>:NSObject, DataProvider {
    
    typealias Object            = Delegate.Object
    
    private var items :[[Object]]!
    private weak var delegate:Delegate!
    
    init(items:[[Object]], delegate:Delegate) {
        self.items              = items
        self.delegate           = delegate
        super.init()
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        return items[indexPath.section][indexPath.row]
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return items[section].count
    }
   
    func numberOfSections()->Int {
        return items.count
    }
    
}