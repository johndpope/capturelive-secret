//
//  CLButton.swift
//  Capture-Live
//
//  Created by hatebyte on 2/24/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMGreenButton: UIButton {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        decorate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        decorate()
    }
    
    func decorate() {
        self.titleLabel?.font             = UIFont.sourceSansPro(.Regular, size: CMFontSize.Large)
        self.layer.masksToBounds          = true
        self.layer.cornerRadius           = 24
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.setTitleColor(UIColor.greyCurrent(), forState: UIControlState.Disabled)
        self.backgroundColor            = UIColor.greenCurrent()
    }
    
    override public var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.whiteColor()
            } else {
                self.backgroundColor = UIColor.greenCurrent()
            }
        }
        
        didSet {

        }
    }
    
    override public var highlighted: Bool {
        willSet(newValue) {
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.whiteColor()
            } else {
                self.backgroundColor = UIColor.greenCurrent()
            }
        }
        
        didSet {

        }
    }
    
    override public var enabled: Bool {
        willSet(newValue) {
            super.enabled = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.greenCurrent()
            } else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
        
        didSet {

        }
    }


}
