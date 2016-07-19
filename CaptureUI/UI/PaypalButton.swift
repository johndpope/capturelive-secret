//
//  PaypalButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/24/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public final class CMPaypalButton: CMBaseButton {
    
    override func assignColors() {
        foregroundColorActive               = UIColor.whiteColor()
        backgroundColorActive               = UIColor.richBlueElectric()
        
        backgroundColorInactive             = UIColor.whiteColor()
        foregroundColorInactive             = UIColor.richBlueElectric()
        
        foregroundColorSelected             = UIColor.taupeGray()
        backgroundColorSelected             = UIColor.whiteColor()
        
        contentVerticalAlignment            = .Center
        contentHorizontalAlignment          = .Center
    }
    
    override func decorate() {
        super.decorate()
        
        self.titleLabel?.font               = UIFont.proxima(.Bold, size: FontSizes.s17)
        self.layer.masksToBounds            = true
        self.layer.cornerRadius             = 0
    }
}