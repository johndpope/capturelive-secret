//
//  CMLoadingButton.swift
//  Current-Tools
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMLoadingButton: CMBaseButton {

    override func assignColors() {
        foregroundColorActive               = UIColor.whiteCurrent()
        backgroundColorActive               = UIColor.greyLightCurrent()
        
        backgroundColorInactive             = UIColor.whiteCurrent()
        foregroundColorInactive             = UIColor.greyLightCurrent()
        
        foregroundColorSelected             = UIColor.whiteCurrent()
        backgroundColorSelected             = UIColor.greyLightCurrent()
        decorate()
        
        self.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Disabled)
        self.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Selected)
        self.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Normal)

        let image                           = UIImage(named:"connecting-lines")
        let imageview                       = UIImageView(image: image)
        imageview.contentMode               = UIViewContentMode.ScaleAspectFill
        imageview.frame                     = self.bounds
        self.addSubview(imageview)
        self.bringSubviewToFront(imageview)
    }

}
