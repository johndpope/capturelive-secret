//
//  HistoryView.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

class CMEquipmentView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var deviceKeyLabel:UILabel?
    @IBOutlet weak var deviceValueLabel:UILabel?
    @IBOutlet weak var spaceKeyLabel:UILabel?
    @IBOutlet weak var spaceValueLabel:UILabel?
    @IBOutlet weak var batteryKeyLabel:UILabel?
    @IBOutlet weak var batteryValueLabel:UILabel?
    @IBOutlet weak var whatEquipmentLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var nextButton:UIButton?
    
    func showForAttemptingLogin() {
        let nextButtonText              = NSLocalizedString("NEXT", comment: "CMEquipmentView : nextButton : text")
        nextButton?.setTitle(nextButtonText, forState: .Normal)
    }
    
}

extension CMEquipmentView : CMContractViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
       
        backButton?.setBackgroundImage(UIImage.iconBackArrow(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        let navTitleText                = NSLocalizedString("APPLICATION FORM", comment: "CMEquipmentView : navTitleLabel : text")
        self.navTitleLabel?.text        = navTitleText
        self.navTitleLabel?.font        = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.textColor   = UIColor.blackCurrent()
       
        let deviceText                  = NSLocalizedString("Your device:", comment: "CMEquipmentView : deviceKeyLabel : text")
        deviceKeyLabel?.text            = deviceText
        deviceKeyLabel?.font            = UIFont.sourceSansPro(.Bold, size: 18)
        deviceKeyLabel?.textColor       = UIColor.greyCurrent()
        deviceKeyLabel?.adjustsFontSizeToFitWidth = true
        deviceKeyLabel?.numberOfLines   = 0
      
        deviceValueLabel?.font          = UIFont.comfortaa(.Regular, size: 18)
        deviceValueLabel?.textColor     = UIColor.greenCurrent()
        deviceValueLabel?.adjustsFontSizeToFitWidth = true
        deviceValueLabel?.numberOfLines = 0

        let spaceText                   = NSLocalizedString("Space:", comment: "CMEquipmentView : spaceKeyLabel : text")
        spaceKeyLabel?.text             = spaceText
        spaceKeyLabel?.font             = UIFont.sourceSansPro(.Bold, size: 12)
        spaceKeyLabel?.textColor        = UIColor.greyCurrent()
        spaceKeyLabel?.adjustsFontSizeToFitWidth = true
        spaceKeyLabel?.numberOfLines    = 0

        spaceValueLabel?.font           = UIFont.comfortaa(.Regular, size: 12)
        spaceValueLabel?.textColor      = UIColor.greenCurrent()
        spaceValueLabel?.adjustsFontSizeToFitWidth = true
        spaceValueLabel?.numberOfLines  = 0

        let batteryText                 = NSLocalizedString("Battery:", comment: "CMEquipmentView : batteryKeyLabel : text")
        batteryKeyLabel?.text           = batteryText
        batteryKeyLabel?.font           = UIFont.sourceSansPro(.Bold, size: 12)
        batteryKeyLabel?.textColor      = UIColor.greyCurrent()
        batteryKeyLabel?.adjustsFontSizeToFitWidth = true
        batteryKeyLabel?.numberOfLines  = 0
 
        batteryValueLabel?.font         = UIFont.comfortaa(.Regular, size: 12)
        batteryValueLabel?.textColor    = UIColor.greenCurrent()
        batteryValueLabel?.adjustsFontSizeToFitWidth = true
        batteryValueLabel?.numberOfLines = 0
 
        let whatEquipmentText           = NSLocalizedString("What smartphone equipment do you own?", comment: "CMEquipmentView : whatEquipmentLabel : text")
        whatEquipmentLabel?.text        = whatEquipmentText
        whatEquipmentLabel?.font        = UIFont.sourceSansPro(.Bold, size: 18)
        whatEquipmentLabel?.textColor   = UIColor.blackCurrent()
        whatEquipmentLabel?.adjustsFontSizeToFitWidth = true
        whatEquipmentLabel?.numberOfLines = 0
 
        let nextButtonText              = NSLocalizedString("SAVE", comment: "CMEquipmentView : saveButton : text")
        nextButton?.setTitle(nextButtonText, forState: .Normal)
        nextButton?.setTitleColor(UIColor.whiteCurrent(), forState: .Normal)
        nextButton?.setTitleColor(UIColor.greyLightCurrent(), forState: .Disabled)
        nextButton?.backgroundColor     = UIColor.greyCurrent()
        nextButton?.enabled             = false
    }
    
}
