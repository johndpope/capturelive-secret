//
//  CMPhoneLoginView.swift
//  Current
//
//  Created by Scott Jones on 1/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class PhoneLoginView: UIView, ActivityIndicatable {
   
    @IBOutlet weak var phoneNumberField:UITextField?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var loginButton:UIButton?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var contentsHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var closeButton:UIButton?
    
    func animateForKeyBoardIn(height:CGFloat) {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height - (height + 0.5)
        self.layoutIfNeeded()
    }
    
    func animateForKeyBoardOut() {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height + 0.5
        self.layoutIfNeeded()
    }

    
}

extension PhoneLoginView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        contentsHeightConstraint?.constant          = UIScreen.mainScreen().bounds.size.height + 0.5
        
        imageView?.image                            = UIImage.iconMobile()
        
        var attrs                                   = [NSString:AnyObject]();
        attrs[NSForegroundColorAttributeName]       = UIColor.taupeGray()
        attrs[NSFontAttributeName]                  = UIFont.proxima(.Regular, size:FontSizes.s14)

        closeButton?.setImage(UIImage.iconCloseXWhite(), forState: .Normal)
        closeButton?.setTitle("", forState: .Normal)
        
        let placeholder                             = NSLocalizedString("Enter your phone number", comment:"CMPhoneAuthorization : phoneNumberField : placeholderText")
        phoneNumberField?.attributedPlaceholder     = NSAttributedString(string:placeholder, attributes:attrs as? [String:AnyObject])
        
        backgroundColor                             = UIColor.taupeGray()
        containerView?.backgroundColor              = UIColor.mountainMeadow()
        
        phoneNumberField!.returnKeyType             = UIReturnKeyType.Done
        phoneNumberField?.autocorrectionType        = UITextAutocorrectionType.No
        phoneNumberField?.textAlignment             = NSTextAlignment.Center
        phoneNumberField?.backgroundColor           = UIColor.whiteColor()
        phoneNumberField?.textColor                 = UIColor.bistre()
        phoneNumberField?.layer.borderWidth         = 0
        phoneNumberField?.font                      = UIFont.proxima(.Regular, size:FontSizes.s14)
        
        let subLabelText                            = NSLocalizedString("Account Verification", comment:"CMPhoneAuthorization : titleLabel : text")
        titleLabel?.textColor                       = UIColor.whiteColor()
        titleLabel?.font                            = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        titleLabel?.text                            = subLabelText
        titleLabel?.numberOfLines                   = 0
        
        let bodyText                                = NSLocalizedString("In order to start using\nCaptureLIVE we need you\nto verify your mobile number", comment:"CMPhoneAuthorization : bodyLabel : text")
        bodyLabel?.textColor                        = UIColor.whiteColor()
        bodyLabel?.font                             = UIFont.proxima(.Regular, size: FontSizes.s14)
        bodyLabel?.text                             = bodyText
        bodyLabel?.numberOfLines                    = 0
        
        loginButton!.setTitle("", forState: UIControlState.Normal)
        loginButton?.setImage(UIImage.activeLoginArrow(), forState: .Normal)
        loginButton?.setImage(UIImage.inactiveLoginArrow(), forState: .Disabled)
        loginButton!.enabled                        = false
    }

}
