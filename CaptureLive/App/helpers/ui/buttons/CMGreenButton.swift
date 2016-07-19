//
//  CLButton.swift
//  Capture-Live
//
//  Created by hatebyte on 2/24/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMGreenButton: UIButton {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        decorate()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        self.setTitleColor(UIColor.grayColorAC(), forState: UIControlState.Disabled)
        self.backgroundColor            = UIColor.greenColorAC()
    }
    
    override var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.whiteColor()
            } else {
                self.backgroundColor = UIColor.greenColorAC()
            }
        }
        
        didSet {

        }
    }
    
    override var highlighted: Bool {
        willSet(newValue) {
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.whiteColor()
            } else {
                self.backgroundColor = UIColor.greenColorAC()
            }
        }
        
        didSet {

        }
    }
    
    override var enabled: Bool {
        willSet(newValue) {
            super.enabled = newValue;
            if newValue == true {
                self.backgroundColor = UIColor.greenColorAC()
            } else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
        
        didSet {

        }
    }


}
