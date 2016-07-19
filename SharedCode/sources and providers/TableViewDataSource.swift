//
//  TableViewDataSource.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class TableViewDataSource<Delegate: DataSourceDelegate, Data:DataProvider, Cell:UITableViewCell where Delegate.Object == Data.Object, Cell:ConfigurableCell, Cell.DataSource == Data.Object>: NSObject, UITableViewDataSource {

    public required init(tableView:UITableView, dataProvider:Data, delegate:Delegate) {
        self.tableView          = tableView
        self.dataProvider       = dataProvider
        self.delegate           = delegate
        super.init()
        tableView.dataSource    = self
        tableView.reloadData()
    }
    
    public var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.objectAtIndexPath(indexPath)
    }
    
    public func processUpdates(updates:[DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates else { return tableView.reloadData() }
        tableView.beginUpdates()
        for update in updates {
            switch update {
            case .Insert(let indexPath):
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            case .Update(let indexPath, let object):
                guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell else { break }
                cell.configureForObject(object)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            case .Move(let indexPath, let newIndexPath):
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            case .Delete(let indexPath):
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
        tableView.endUpdates()
    }
    
    
    private let tableView:UITableView
    private let dataProvider:Data
    private weak var delegate:Delegate!
    
    // MARK: UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataProvider.numberOfSections()
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = dataProvider.objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath) : \(tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath))")
        }

        cell.configureForObject(object)
        return cell
    }

}
