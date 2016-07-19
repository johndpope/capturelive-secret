//
//  CMSecondaryButton.swift
//  Current-Tools
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public final class CMSecondaryButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.silver()
        backgroundColorActive               = UIColor.whiteColor()
        strokeColorActive                   = UIColor.whiteColor()
 
        backgroundColorInactive             = UIColor.greyCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        strokeColorInactive                 = UIColor.silver()
 
        foregroundColorSelected             = UIColor.silver()
        backgroundColorSelected             = UIColor.whiteColor()
        
        decorate()
    }
    
    override internal func decorate() {
        super.decorate()
        self.layer.borderColor              = UIColor.silver().CGColor
    }
    
    override public var highlighted: Bool {
        willSet(newValue) {
            if self.enabled == false {
                return
            }
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = backgroundColorSelected
                if let sa = self.strokeColorInactive {
                    self.layer.borderColor      = sa.CGColor
                }
                
            } else {
                self.backgroundColor = backgroundColorActive
                if let sa = self.strokeColorActive {
                    self.layer.borderColor      = sa.CGColor
                }
            }
        }
        
        didSet {
            
        }
    }

}
