//
//  CMActivatedButton.swift
//  Current-Tools
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMActivatedButton: CMBaseButton {
    
    override func assignColors() {
        foregroundColorActive               = UIColor.whiteCurrent()
        backgroundColorActive               = UIColor.greyCurrent()
        
        backgroundColorInactive             = UIColor.greyLightCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        
        foregroundColorSelected             = UIColor.greyCurrent()
        backgroundColorSelected             = UIColor.greyLightCurrent()
        decorate()
    }
    
}
