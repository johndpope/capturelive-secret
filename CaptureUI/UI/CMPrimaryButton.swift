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
        foregroundColorActive               = UIColor.whiteColor()
        backgroundColorActive               = UIColor.mountainMeadow()
        
        backgroundColorInactive             = UIColor.silver()
        foregroundColorInactive             = UIColor.platinum()
        
        foregroundColorSelected             = UIColor.whiteColor()
        backgroundColorSelected             = UIColor.jungleGreen()
    }

}

