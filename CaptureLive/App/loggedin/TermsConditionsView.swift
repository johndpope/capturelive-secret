//
//  CMTermsConditionsView.swift
//  Current
//
//  Created by Scott Jones on 1/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

class TermsConditionsView : UIView, ActivityIndicatable {

    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navbar:UIView?
    @IBOutlet weak var webview:UIWebView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var topConstraint:NSLayoutConstraint?

}

extension TermsConditionsView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                                = UIColor.greyLightestCurrent()
        
        self.navbar?.layer.shadowColor                      = UIColor.blackCurrent().CGColor
        self.navbar?.layer.shadowOpacity                    = 0.5
        self.navbar?.layer.shadowOffset                     = CGSizeMake(0, 1)
        self.navbar?.layer.shadowRadius                     = 1
        
        let termsTitle                                      = NSLocalizedString("TERMS & CONDITIONS", comment:"TermsConditionsView : navTitleLabel : text")
        self.navTitleLabel?.font                            = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.text                            = termsTitle
        
        self.backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: UIControlState.Normal)
        self.backButton?.setTitle("", forState: UIControlState.Normal)
        
        self.webview?.alpha                                 = 0
        self.webview?.backgroundColor                       = UIColor.clearColor()
        
        self.activityIndicator?.startAnimating()
    }
    
}

