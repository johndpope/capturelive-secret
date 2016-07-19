//
//  CMActionSheetView.swift
//  Current
//
//  Created by Scott Jones on 11/6/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMActionSheetView: CMAlertView {
    
    var onscreenY:CGFloat {
        get {
            return (UIScreen.mainScreen().bounds.height * 0.5) - (self.heightConstraint!.constant * 0.5)
        }
    }
    
    var offscreenY:CGFloat {
        get {
            return (UIScreen.mainScreen().bounds.height * 0.5) + (self.heightConstraint!.constant * 0.5)
        }
    }
    
    override func didLoad() {
        self.getWidth = UIScreen.mainScreen().bounds.width
        super.didLoad()
        self.alertViewContainer?.layer.cornerRadius = 0
    }
    
    override func present() {
        self.widthConstraint?.constant          = UIScreen.mainScreen().bounds.width
        self.centerYConstraint?.constant        = self.offscreenY
        self.layoutIfNeeded()
        
        UIView.animateWithDuration(0.5, delay:0.0, usingSpringWithDamping:0.7, initialSpringVelocity:1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.centerYConstraint?.constant    = self.onscreenY
            self.layoutIfNeeded()

            }) { (fin:Bool) -> Void in
                
        }
    }
    
    override func dismiss() {
        UIView.animateWithDuration(0.3, delay:0.0, usingSpringWithDamping:1.0, initialSpringVelocity:1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.centerYConstraint?.constant    = self.offscreenY
            self.layoutIfNeeded()
            
            }) { (fin:Bool) -> Void in
                
        }
    }

}
