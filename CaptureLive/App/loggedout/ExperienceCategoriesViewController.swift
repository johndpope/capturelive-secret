//
//  ExperienceCategoriesViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

class ExperienceCategoriesViewController: UIViewController {
    
    var theView:ExperienceCategoriesView {
        guard let v = self.view as? ExperienceCategoriesView else { fatalError("Not a \(ExperienceCategoriesView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<ExperienceCategoriesViewController>
    private var dataSource:CollectionViewDataSource<ExperienceCategoriesViewController, Data, NoTitleProfileCollectionCell>!
    private var dataProvider: Data!
    
    var categoriesPicked:CategoriesPicked?
    var items:[RoundButtonDecoratable] = []
    var pickedCategories:[CaptureModel.Category] = []
    var allCategories:[CaptureModel.Category] = Category.allValues
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        
        theView.collectionView?.delegate = self
        createViewModelList()
        createDataProvider()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDataProvider() {
        dataProvider    = DefaultDataProvider(items:items, delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
    func subtractCategory(category:CaptureModel.Category) {
        guard let index = pickedCategories.indexOf(category) else { return }
        pickedCategories.removeAtIndex(index)
        let f = pickedCategories.filter { $0 != .None }.flatMap { $0 }
        pickedCategories = f
        if pickedCategories.count == 0 { pickedCategories = [.None] }
    }
    
    func addCategory(category:CaptureModel.Category) {
        let r = pickedCategories.filter { $0 != .None }.filter { $0 != category }.flatMap { $0 }
        pickedCategories = [category] + r
        if pickedCategories.count == 0 { pickedCategories = [.None] }
    }
    
    func categorySelected(category:CaptureModel.Category)  {
        if category == .None {
            pickedCategories = [.None]
            createViewModelList()
            createDataProvider()
            return
        }
        if pickedCategories.contains(category) {
            subtractCategory(category)
        } else {
            addCategory(category)
        }
        createViewModelList()
        createDataProvider()
    }
    
    func createViewModelList() {
        items       = CaptureModel.Category.modelsWithSelection(pickedCategories)
        let last    = items.popLast()
        items.append(
            self.doneCellModel
        )
        items.append(last!)
    }
    
    var doneCellModel:CellDecoratable {
        if pickedCategories.count == 0 {
            return ProfileImageCellViewModel(
                type:"x"
                ,title:""
                ,imageName:"bttn_x_closecircle"
                ,color:UIColor.platinum()
            )
 
        } else {
            return ProfileImageCellViewModel(
                 type:"x"
                ,title:"Done"
                ,imageName:""
                ,color:UIColor.platinum()
            )
        }
    }
    
}

extension ExperienceCategoriesViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject as? LargeCategoryTextCellViewModel  else {
            categoriesPicked?(pickedCategories)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        guard let c = Category(rawValue: object.type) else { fatalError("Not a category : \(object.type)") }
        categorySelected(c)
    }
}

extension ExperienceCategoriesViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<RoundButtonDecoratable>]?) {
    }
}

extension ExperienceCategoriesViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:RoundButtonDecoratable) -> String {
        return NoTitleProfileCollectionCellIdentifier
    }
}