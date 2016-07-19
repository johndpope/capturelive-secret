//
//  CMBlackButton.swift
//  Capture-Live
//
//  Created by hatebyte on 2/24/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

public final class CMBlackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        decorate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        decorate()
    }
    
    func decorate() {
        self.titleLabel?.font             = UIFont(name:CMFontProxima.Regular.rawValue, size: CMFontSize.Large.rawValue)
        self.layer.masksToBounds          = true
        self.layer.cornerRadius           = 2
        self.layer.borderColor            = UIColor.greyCurrent().CGColor;
        self.layer.borderWidth            = 0.5;
        self.backgroundColor                = UIColor.blackColor()
        self.setTitleColor(UIColor.greyCurrent(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.setTitleColor(UIColor.greyCurrent(), forState: UIControlState.Disabled)
    }
    
    override public var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.greyDarkCurrent()
            } else {
                self.backgroundColor = UIColor.blackColor()
            }
        }
        
        didSet {
            
        }
    }
    
    override public var highlighted: Bool {
        willSet(newValue) {
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.greyDarkCurrent()
            } else {
                self.backgroundColor = UIColor.blackColor()
            }
        }
        
        didSet {
            
        }
    }
    
    override public var enabled: Bool {
        willSet(newValue) {
            super.enabled = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.blackColor()
            } else {
                self.backgroundColor = UIColor.greyDarkCurrent()
            }        }
        
        didSet {
            
        }
    }
    
    
}
