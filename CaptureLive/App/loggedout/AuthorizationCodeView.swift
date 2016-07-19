//
//  CMAuthorizationCodeView.swift
//  Current
//
//  Created by Scott Jones on 1/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class AuthorizationCodeView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var authCodeField:UITextField?
    @IBOutlet weak var authCodeContainerView:UIView?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var loginButton:UIButton?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var contentsHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var textFieldPaddingConstraint:NSLayoutConstraint?
    @IBOutlet weak var buttonPaddingConstraint:NSLayoutConstraint?
    @IBOutlet weak var bannerView:UIView?
    @IBOutlet weak var bannerLabel:UILabel?
    @IBOutlet weak var bannerBottomConstraint:NSLayoutConstraint?
    
    var animate = false
    func animateForKeyBoardIn(height:CGFloat) {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height - height
        self.layoutIfNeeded()
    }
    
    func animateForKeyBoardOut() {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height
        self.layoutIfNeeded()
    }
   
    func addPhoneNumber(phoneNumber:String) {
        let bodyText                                = NSLocalizedString("Enter the code sent to:\n%@", comment:"AuthorizationCodeView : bodyLabel : text")
        bodyLabel?.text                            = String(NSString(format: bodyText, phoneNumber))
    }

    func showInvalidCode() {
        let bannerText                              = NSLocalizedString("Invalid code!", comment:"CMPhoneAuthorization : bannerLabel : invalidCode tet")
        showError(bannerText)
    }
    
    func showError(text:String) {
        bannerLabel?.text                           = text
        bannerView?.backgroundColor                 = UIColor.bistre()
        UIView.animateWithDuration(0.4,
           delay: 0.0,
           usingSpringWithDamping: 0.7,
           initialSpringVelocity: 1.0,
           options:.CurveEaseInOut,
           animations: { [weak self] in
                self?.bannerBottomConstraint?.constant  = 0
                self?.layoutIfNeeded()
            },
                                 
            completion: { _ in
              
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.hideError()
                }
                                    
        })
    }
    
    func hideError() {
        UIView.animateWithDuration(0.4,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 1.0,
                                   options:.CurveEaseInOut,
                                   animations: { [weak self] in
                                    self?.bannerBottomConstraint?.constant  = -(ScreenSize.SCREEN_WIDTH * 0.12)
                                    self?.layoutIfNeeded()
            },
                                   
                                   completion: { _ in
                                    
        })
    }
    
    
    func animateOut(closure:()->()) {
        animateOutAuthCode(closure)
    }
   
    private func animateOutAuthCode(closure:()->()) {
        closeButton?.hidden = true
        bannerView?.hidden = true
        backgroundColor = UIColor.mountainMeadow()
        authCodeField?.resignFirstResponder()

        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 500.0,
                                   initialSpringVelocity: 0,
                                   options:UIViewAnimationOptions.CurveLinear,
                                   animations: { [weak self] in
            self?.authCodeContainerView?.alpha = 0
            self?.contentsHeightConstraint?.constant = ScreenSize.SCREEN_HEIGHT
            self?.layoutIfNeeded()
        }) { [weak self] finished in
            
            UIView.animateWithDuration(0.5, animations: { [weak self] in
                self?.titleLabel?.alpha = 0
                self?.bodyLabel?.alpha = 0
                
            }) { [weak self] finished in
                
                UIView.animateWithDuration(0.5, animations: { [weak self] in
                    self?.imageView?.alpha  = 0
                    
                }) { [weak self] finished in
                    
                    self?.animateInVerified(closure)
                }
            }
            
        }
    }
   
    
    private func animateInVerified(closure:()->()) {
        self.imageView?.image = UIImage(named:"icon_complete")
        let subLabelText                            = NSLocalizedString("Verified!", comment:"AuthorizationCodeView : titleLabel : Verifiedtext")
        titleLabel?.text                            = subLabelText

        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.imageView?.alpha  = 1
            
        }) { finished in
            UIView.animateWithDuration(0.5, animations: { [weak self] in
                self?.titleLabel?.alpha  = 1
                
            }) { finished in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    closure()
                }
                
            }
        }
    }

}

extension AuthorizationCodeView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        textFieldPaddingConstraint?.constant        = 0.5
        buttonPaddingConstraint?.constant           = 0.5
        
        contentsHeightConstraint?.constant          = ScreenSize.SCREEN_HEIGHT
        
        bannerBottomConstraint?.constant            = -(ScreenSize.SCREEN_WIDTH * 0.12)
        
        imageView?.image                            = UIImage.iconMobile()
        
        var attrs                                   = [NSString:AnyObject]();
        attrs[NSForegroundColorAttributeName]       = UIColor.taupeGray()
        attrs[NSFontAttributeName]                  = UIFont.proxima(.Regular, size:FontSizes.s14)
        
        closeButton?.setImage(UIImage.iconCloseXWhite(), forState: .Normal)
        closeButton?.setTitle("", forState: .Normal)
 
        let placeholder                             = NSLocalizedString("Verification Code", comment:"AuthorizationCodeView : codeField : placeholderText")
        authCodeField?.attributedPlaceholder        = NSAttributedString(string:placeholder, attributes:attrs as? [String:AnyObject])
        
        authCodeContainerView?.backgroundColor      = UIColor.taupeGray()
        backgroundColor                             = UIColor.mountainMeadow()
        containerView?.backgroundColor              = UIColor.mountainMeadow()
        
        authCodeField?.returnKeyType                = UIReturnKeyType.Done
        authCodeField?.autocorrectionType           = UITextAutocorrectionType.No
        authCodeField?.textAlignment                = NSTextAlignment.Center
        authCodeField?.backgroundColor              = UIColor.whiteColor()
        authCodeField?.textColor                    = UIColor.bistre()
        authCodeField?.layer.borderWidth            = 0
        authCodeField?.font                         = UIFont.proxima(.Regular, size:FontSizes.s14)
        
        let subLabelText                            = NSLocalizedString("Code Verification", comment:"AuthorizationCodeView : titleLabel : text")
        titleLabel?.font                            = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        titleLabel?.numberOfLines                   = 0
        titleLabel?.text                            = subLabelText
        titleLabel?.textColor                       = UIColor.whiteColor()
 
        bodyLabel?.textColor                        = UIColor.whiteColor()
        bodyLabel?.font                             = UIFont.proxima(.Regular, size: FontSizes.s14)
        bodyLabel?.numberOfLines                    = 0
        
        bannerLabel?.textColor                      = UIColor.whiteColor()
        bannerLabel?.font                           = UIFont.proxima(.Regular, size: FontSizes.s14)
 
        loginButton!.setTitle("", forState: UIControlState.Normal)
        loginButton?.setImage(UIImage.activeLoginArrow(), forState: .Normal)
        loginButton?.setImage(UIImage.inactiveLoginArrow(), forState: .Disabled)
        loginButton!.enabled                        = false
    }
    
}
