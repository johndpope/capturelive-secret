//
//  EquipmentTableSource.swift
//  Current
//
//  Created by Scott Jones on 4/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureModel

typealias EquipmentSelected = (Equipment)->()

protocol EquipmentTableSourceProtocol {
    func equipmentSelected(equipment:Equipment)
}

private let EquipmentTableViewCellHeight:CGFloat = 54
final class EquipmentTableViewSource:NSObject {
    
    private unowned let tableView:UITableView
    var equipmentDelegate:EquipmentTableSourceProtocol!
    internal private(set) var equipments:[Equipment] = Equipment.allValues
    internal private(set) var ownedEquipment:[Equipment] = []
    
    init(tableView:UITableView, equipmentDelegate:EquipmentTableSourceProtocol) {
        self.tableView              = tableView
        self.equipmentDelegate           = equipmentDelegate
        super.init()
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
        self.tableView.reloadData()
    }
   
    func replaceEquip(equip:[Equipment]) {
        ownedEquipment = equip
        self.tableView.reloadData()
    }
    
    func subtractEquipment(eq:Equipment) {
        guard let index = ownedEquipment.indexOf(eq) else { return }
        ownedEquipment.removeAtIndex(index)
        let f = ownedEquipment.filter { $0 != .None }.flatMap { $0 }
        ownedEquipment = f
        self.tableView.reloadData()
    }
    
    func addEquipment(eq:Equipment) {
        let r = ownedEquipment.filter { $0 != .None }.filter { $0 != eq }.flatMap { $0 }
        ownedEquipment = [eq] + r
        self.tableView.reloadData()
    }
    
    var totalHeight:CGFloat {
        return CGFloat(ownedEquipment.count) * EquipmentTableViewCellHeight
    }
    
    func noneSelected() {
        ownedEquipment = [.None]
        self.tableView.reloadData()
    }
    
}

private let EquipmentTableViewCell = "EquipmentTableViewCell"
extension EquipmentTableViewSource : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equipments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(EquipmentTableViewCell, forIndexPath: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let eq = equipments[indexPath.row]
        cell.textLabel?.text = eq.localizedString
        
        if ownedEquipment.contains(eq) {
            cell.textLabel?.font = UIFont.comfortaa(.Bold, size: 14)
            cell.textLabel?.textColor = UIColor.greenCurrent()
        } else {
            cell.textLabel?.font = UIFont.comfortaa(.Light, size: 14)
            cell.textLabel?.textColor = UIColor.greyCurrent()
        }
        
        return cell
    }
    
}

extension EquipmentTableViewSource : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eq = equipments[indexPath.row]
        if eq == .None {
            noneSelected()
        } else {
            if ownedEquipment.contains(eq) {
                subtractEquipment(eq)
            } else {
                addEquipment(eq)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.equipmentDelegate.equipmentSelected(eq)
    }
    
}