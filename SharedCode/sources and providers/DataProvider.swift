//
//  DataProvider.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public protocol TableViewCellModelType {
    associatedtype Model
    func tableCellViewModel()->Model
}

public protocol DataProvider: class {
    associatedtype Object
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object
    func numberOfItemsInSection(section: Int) -> Int
    func numberOfSections()->Int
}
extension DataProvider {
    public func numberOfSections()->Int {
        return 1
    }
}

public protocol DataProviderDelegate: class {
    associatedtype Object
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Object>]?)
}

public enum DataProviderUpdate<Object> {
    case Insert(NSIndexPath)
    case Update(NSIndexPath, Object)
    case Move(NSIndexPath, NSIndexPath)
    case Delete(NSIndexPath)
}

