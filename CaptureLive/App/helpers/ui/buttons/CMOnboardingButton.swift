//
//  CMOnboardingButton.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMOnboardingButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.blueCurrent()
        backgroundColorActive               = UIColor.whiteCurrent()
        
        backgroundColorInactive             = UIColor.greyLightCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        
        foregroundColorSelected             = UIColor.whiteCurrent()
        backgroundColorSelected             = UIColor.blueCurrent()
        decorate()
    }
    
}
