//
//  CMSecondaryButton.swift
//  Current-Tools
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMSecondaryButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.greyCurrent()
        backgroundColorActive               = UIColor.clearColor()
        strokeColorActive                   = UIColor.greyLightCurrent()
        
        backgroundColorInactive             = UIColor.greyCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        strokeColorInactive                 = UIColor.clearColor()

        foregroundColorSelected             = UIColor.whiteCurrent()
        backgroundColorSelected             = UIColor.greyCurrent()
        decorate()
    }

}
