//
//  CMCancelButton.swift
//  Current-Tools
//
//  Created by Scott Jones on 11/17/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMCancelButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.whiteCurrent()
        backgroundColorActive               = UIColor.redCurrent()
        
        backgroundColorInactive             = UIColor.redCurrent()
        foregroundColorInactive             = UIColor.whiteCurrent()
        
        foregroundColorSelected             = UIColor.redCurrent()
        backgroundColorSelected             = UIColor.whiteCurrent()
        decorate()
    }

}
