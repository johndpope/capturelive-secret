//
//  CMBlackButton.swift
//  Capture-Live
//
//  Created by hatebyte on 2/24/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMBlackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        decorate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        decorate()
    }
    
    func decorate() {
        self.titleLabel?.font             = UIFont(name:CMFont.Regular.rawValue, size: CMFontSize.Large.rawValue)
        self.layer.masksToBounds          = true
        self.layer.cornerRadius           = 2
        self.layer.borderColor            = UIColor.grayColorAC().CGColor;
        self.layer.borderWidth            = 0.5;
        self.backgroundColor                = UIColor.blackColor()
        self.setTitleColor(UIColor.grayColorAC(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.setTitleColor(UIColor.grayColorAC(), forState: UIControlState.Disabled)
    }
    
    override var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.grayDarkestColorAC()
            } else {
                self.backgroundColor = UIColor.blackColor()
            }
        }
        
        didSet {
            
        }
    }
    
    override var highlighted: Bool {
        willSet(newValue) {
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.grayDarkestColorAC()
            } else {
                self.backgroundColor = UIColor.blackColor()
            }
        }
        
        didSet {
            
        }
    }
    
    override var enabled: Bool {
        willSet(newValue) {
            super.enabled = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.blackColor()
            } else {
                self.backgroundColor = UIColor.grayDarkestColorAC()
            }        }
        
        didSet {
            
        }
    }
    
    
}
