//
//  CMAboutView.swift
//  Current
//
//  Created by Scott Jones on 1/25/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

class FAQsView: UIView, ActivityIndicatable {

    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navbar:UIView?
    @IBOutlet var webview:UIWebView?
    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var topConstraint:NSLayoutConstraint?
    
}

extension FAQsView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                                = UIColor.greyLightestCurrent()
        
        self.navbar?.layer.shadowColor                      = UIColor.blackCurrent().CGColor
        self.navbar?.layer.shadowOpacity                    = 0.5
        self.navbar?.layer.shadowOffset                     = CGSizeMake(0, 1)
        self.navbar?.layer.shadowRadius                     = 1
        
        let aboutTitle                                      = NSLocalizedString("FAQs", comment:"FAQsView : titleText")
        self.navTitleLabel?.font                            = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.text                            = aboutTitle
        
        self.backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: UIControlState.Normal)
        self.backButton?.setTitle("", forState: UIControlState.Normal)
        
        self.webview?.alpha                                 = 0
        self.webview?.backgroundColor                       = UIColor.clearColor()
        
        self.activityIndicator?.startAnimating()
        
        self.topConstraint?.constant                        = 0
        self.layoutIfNeeded()
    }
    
}