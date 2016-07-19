//
//  CMPrimaryButton.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public final class CMPrimaryButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.whiteCurrent()
        backgroundColorActive               = UIColor.blueCurrent()
        
        backgroundColorInactive             = UIColor.greyLightCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        
        foregroundColorSelected             = UIColor.blueCurrent()
        backgroundColorSelected             = UIColor.whiteCurrent()
    }

}

