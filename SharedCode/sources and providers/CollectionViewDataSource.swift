//
//  CollectionViewDataSource.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/10/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class CollectionViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UICollectionViewCell where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object>: NSObject, UICollectionViewDataSource {
    
    public required init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate) {
        self.collectionView = collectionView
        self.dataProvider = dataProvider
        self.delegate = delegate
        super.init()
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    public var selectedObject: Data.Object? {
        guard let indexPath = collectionView.indexPathsForSelectedItems()?.first else { return nil }
        return dataProvider.objectAtIndexPath(indexPath)
    }
    
    public func processUpdates(updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates else { return collectionView.reloadData() }
        collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case .Insert(let indexPath):
                    self.collectionView.insertItemsAtIndexPaths([indexPath])
                case .Update(let indexPath, let object):
                    guard let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? Cell else { fatalError("wrong cell type") }
                    cell.configureForObject(object)
                case .Move(let indexPath, let newIndexPath):
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
                    self.collectionView.insertItemsAtIndexPaths([newIndexPath])
                case .Delete(let indexPath):
                    self.collectionView.deleteItemsAtIndexPaths([indexPath])
                }
            }
            }, completion: nil)
    }
    
    
    // MARK: Private
    
    private let collectionView: UICollectionView
    private let dataProvider: Data
    private weak var delegate: Delegate!
    
    
    // MARK: UICollectionViewDataSource
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let object = dataProvider.objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        cell.configureForObject(object)
        return cell
    }
    
}
