//
//  TermsOfServiceView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class TermsOfServiceRegistrationView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var bottomContainerView:UIView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var webView:UIWebView?
    @IBOutlet weak var disagreeButton:CMSecondaryButton?
    @IBOutlet weak var agreeButton:CMPrimaryButton?

}

extension TermsOfServiceRegistrationView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        backgroundColor                 = UIColor.isabelline()
       
        closeButton?.setImage(UIImage.iconCloseXBlack(), forState: .Normal)
        closeButton?.setTitle("", forState: .Normal)
        
        let navText                     = NSLocalizedString("TERMS OF SERVICE", comment: "TermsOfServiceRegistrationView : navTitleLabel : text")
        navTitleLabel?.text             = navText
        navTitleLabel?.font             = UIFont.proxima(.Bold, size: FontSizes.s15)
        navTitleLabel?.textColor        = UIColor.bistre()
        
        webView?.layer.shadowOpacity    = 0.5
        webView?.layer.shadowOffset     = CGSizeMake(0, 0.2)
        webView?.layer.shadowRadius     = 0.5
        
        navView?.backgroundColor        = UIColor.clearColor()
        bottomContainerView?.backgroundColor = UIColor.clearColor()
        
        agreeButton?.titleLabel?.font   = UIFont.proxima(.Bold, size: FontSizes.s15)
        let agreeText                   = NSLocalizedString("I AGREE", comment: "WelcomeView : agreeButton : text")
        agreeButton?.setTitle(agreeText, forState: .Normal)
        
        disagreeButton?.titleLabel?.font = UIFont.proxima(.Bold, size: FontSizes.s15)
        let disagreeText                = NSLocalizedString("I DISAGREE", comment: "WelcomeView : disagreeButton : text")
        disagreeButton?.setTitle(disagreeText, forState: .Normal)
        disagreeButton?.layer.borderWidth = 0
    }
    
}