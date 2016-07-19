//
//  ExperienceLevelViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

class ExperienceLevelViewController: UIViewController {
    
    var theView:ExperienceLevelView {
        guard let v = self.view as? ExperienceLevelView else { fatalError("Not a \(ExperienceLevelView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<ExperienceLevelViewController>
    private var dataSource:CollectionViewDataSource<ExperienceLevelViewController, Data, NoTitleProfileCollectionCell>!
    private var dataProvider: Data!
    
    var experienceLevelPicked:ExperienceLevelPicked?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theView.didLoad()
        
        theView.didLoad()
        var items:[RoundButtonDecoratable] = Level.allValues.map { $0.largeCellViewModel }
        let last = items.popLast()
        items.append(
            ProfileImageCellViewModel(
                type:"x"
                ,title:""
                ,imageName:"bttn_x_closecircle"
                ,color:UIColor.platinum()
            )
        )
        items.append(last!)
        
        theView.collectionView?.delegate = self
        
        dataProvider    = DefaultDataProvider(items:items, delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ExperienceLevelViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject as? LargeLevelTextCellViewModel  else {
            experienceLevelPicked?(nil)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated:false)
        experienceLevelPicked?(object.toLevel)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ExperienceLevelViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<RoundButtonDecoratable>]?) {
    }
}

extension ExperienceLevelViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:RoundButtonDecoratable) -> String {
        return NoTitleProfileCollectionCellIdentifier
    }
}
