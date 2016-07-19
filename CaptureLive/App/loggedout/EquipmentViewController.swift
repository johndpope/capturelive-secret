//
//  EquipmentViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

class EquipmentViewController: UIViewController {
    
    var theView:EquipmentView {
        guard let v = self.view as? EquipmentView else { fatalError("Not a \(EquipmentView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<EquipmentViewController>
    private var dataSource:CollectionViewDataSource<EquipmentViewController, Data, NoTitleProfileCollectionCell>!
    private var dataProvider: Data!
    
    var equipmentPicked:EquipmentPicked?
    var items:[RoundButtonDecoratable] = []
    var pickedEquipment:[Equipment] = []
    var allEquipment:[Equipment] = Equipment.allValues
    
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
    
    func subtractEquipment(equipment:Equipment) {
        guard let index = pickedEquipment.indexOf(equipment) else { return }
        pickedEquipment.removeAtIndex(index)
        let e = pickedEquipment.filter { $0 != .None }.flatMap { $0 }
        pickedEquipment = e
    }
    
    func addEquipment(equipment:Equipment) {
        let e = pickedEquipment.filter { $0 != .None }.filter { $0 != equipment }.flatMap { $0 }
        pickedEquipment = [equipment] + e
    }
    
    func equipmentSelected(equipment:Equipment)  {
        if pickedEquipment.contains(equipment) {
            subtractEquipment(equipment)
        } else {
            addEquipment(equipment)
        }
        createViewModelList()
        createDataProvider()
    }
    
    func createViewModelList() {
        items       = Equipment.modelsWithSelection(pickedEquipment)
        let last    = items.popLast()
        items.append(
            self.doneCellModel
        )
        items.append(last!)
    }
   
    var doneCellModel:CellDecoratable {
        if pickedEquipment.count == 0 {
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

extension EquipmentViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject as? LargeEquipmentTextCellViewModel  else {
            equipmentPicked?(pickedEquipment)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        guard let e = Equipment(rawValue: object.type) else { fatalError("Not an equipment : \(object.type)") }
        equipmentSelected(e)
    }
}

extension EquipmentViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<RoundButtonDecoratable>]?) {
    }
}

extension EquipmentViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:RoundButtonDecoratable) -> String {
        return NoTitleProfileCollectionCellIdentifier
    }
}
