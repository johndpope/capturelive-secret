//
//  CMNavButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/23/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public final class CMNavButton: CMBaseButton {
    
    override func assignColors() {
        foregroundColorActive               = UIColor.whiteColor()
        backgroundColorActive               = UIColor.jungleGreen()
        
        backgroundColorInactive             = UIColor.whiteColor()
        foregroundColorInactive             = UIColor.jungleGreen()
        
        foregroundColorSelected             = UIColor.whiteColor()
        backgroundColorSelected             = UIColor.jade()
        
        contentVerticalAlignment            = .Center
        contentHorizontalAlignment          = .Left
    }

    override func decorate() {
        super.decorate()
        
        self.titleLabel?.font               = UIFont.proxima(.Bold, size: FontSizes.s17)
        self.layer.masksToBounds            = true
        self.layer.cornerRadius             = 0
    }
}