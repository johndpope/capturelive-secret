//
//  CMStreamRequestView.swift
//  Current-Tools
//
//  Created by Scott Jones on 9/13/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class StreamRequestView: UIView {

    @IBOutlet var directionsLabel:UILabel?
    @IBOutlet var orientationLockLabel:UILabel?
    @IBOutlet var cancelButton:UIButton?
    @IBOutlet var rotateImageView:UIImageView?
    @IBOutlet var iconImageView:UIImageView?
    
    func didLoad() {
        backgroundColor                             = UIColor.blackCurrent(0.4)
        
        directionsLabel?.font                       = UIFont.proxima(.Bold, size:FontSizes.s22)
        directionsLabel?.textColor                  = UIColor.whiteColor()
        directionsLabel?.text                       = NSLocalizedString("Rotate your mobile device\nto begin streaming", comment: "CMStreamRequestView : directionsLabel : text")
        directionsLabel?.numberOfLines              = 0
        
        orientationLockLabel?.font                  = UIFont.proxima(.SemiBold, size:FontSizes.s18)
        orientationLockLabel?.textColor             = UIColor.whiteColor()
        orientationLockLabel?.text                  = NSLocalizedString("If you have screen orientation lock\nenabled, please disable it now", comment: "CMStreamRequestView : orientationLockLabel : text")
        orientationLockLabel?.numberOfLines         = 0
 
        rotateImageView?.image                      = UIImage(named:"icon_rotatedevice")
        iconImageView?.image                        = UIImage(named:"icon_orientationlock")
        
        cancelButton?.setImage(UIImage.iconCloseXWhite(), forState: UIControlState.Normal)
        cancelButton?.setTitle("", forState: UIControlState.Normal)
    }
    
    func setOrientation() {
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            self.hideToLandscape()
        } else {
            self.hideToPortrait()
        }
    }
    
    func hideToLandscape() {
        hidden = true
    }
    
    func hideToPortrait() {
        hidden = false
    }

}




























