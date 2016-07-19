//
//  CMFacebookAuthView.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureUI

class FacebookAuthView: UIView, ActivityIndicatable {

    @IBOutlet weak var authButton:UIButton?
    @IBOutlet weak var whyButton:UIButton?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?

    @IBOutlet weak var revealTitleLabel:UILabel?
    @IBOutlet weak var revealBodyLabel:UILabel?
    @IBOutlet weak var revealCloseButton:UIButton?
    @IBOutlet weak var revealView:UIView?
    @IBOutlet weak var revealConstraint:NSLayoutConstraint?
    @IBOutlet weak var revealHeightConstraint:NSLayoutConstraint?
    
    var revealHeight:CGFloat = 0
    
    func revealOverlay() {
        UIView.animateWithDuration(0.7,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 1.5,
                                   options:.CurveEaseInOut,
                                   animations: { [weak self] in
                self?.revealConstraint?.constant = 0
                self?.layoutIfNeeded()
            },
                completion: { _ in
        })
    }
    
    func dismisOverlay() {
        let delta      = -revealHeight
        UIView.animateWithDuration(0.4,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 1.5,
                                   options:.CurveEaseInOut,
                                   animations: { [weak self] in
                                    self?.revealConstraint?.constant = delta
                self?.layoutIfNeeded()
            },
               completion: { _ in
        })
    }
    
}

extension FacebookAuthView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        imageView?.image                    = UIImage(named:"icon_mobile")
        backgroundColor                     = UIColor.mountainMeadow()
       
        let joinText                        = NSLocalizedString("Be a Photographer\nwith CaptureLIVE", comment:"CMFacebookAuthView : titleLabel : text")
        titleLabel?.text                    = joinText
        titleLabel?.font                    = UIFont.proxima(.SemiBold, size:FontSizes.s20)
        titleLabel?.textColor               = UIColor.whiteColor()
        titleLabel?.numberOfLines           = 0
       
        let fillAText                       = NSLocalizedString("Get hired by top media companies\nto live stream nearby events.", comment:"CMFacebookAuthView : bodyLabel : text")
        bodyLabel?.text                     = fillAText
        bodyLabel?.font                     = UIFont.proxima(.Regular, size:FontSizes.s14)
        bodyLabel?.textColor                = UIColor.whiteColor()
        bodyLabel?.numberOfLines            = 0
        
        let whyButtonText                   = NSLocalizedString("Why is Facebook required", comment:"CMFacebookAuthView : whyButton : text")
        whyButton?.backgroundColor          = UIColor.clearColor()
        whyButton?.setTitle(whyButtonText, forState: .Normal)
        whyButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        whyButton?.setImage(UIImage(named:"icon_fb_why"), forState: .Normal)
        whyButton?.transform                = CGAffineTransformMakeScale(-1.0, 1.0);
        whyButton?.titleLabel?.transform    = CGAffineTransformMakeScale(-1.0, 1.0)
        whyButton?.imageView?.transform     = CGAffineTransformMakeScale(-1.0, 1.0)
        whyButton?.imageEdgeInsets          = UIEdgeInsetsMake(0, 0, 0, 12)

        let facebookText                    = NSLocalizedString("CONTINUE WITH FACEBOOK", comment:"CMFacebookAuthView : authButton : text")
        authButton?.backgroundColor         = UIColor.lapisLazuli()
        authButton?.titleLabel?.font        = UIFont.proxima(.Bold, size:FontSizes.s15)
        authButton?.setTitle(facebookText, forState: .Normal)
        authButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        authButton?.setImage(UIImage(named:"icon_fbauth_wht"), forState: .Normal)
        authButton?.transform               = CGAffineTransformMakeScale(-1.0, 1.0);
        authButton?.titleLabel?.transform   = CGAffineTransformMakeScale(-1.0, 1.0)
        authButton?.imageView?.transform    = CGAffineTransformMakeScale(-1.0, 1.0)
        authButton?.imageEdgeInsets         = UIEdgeInsetsMake(0, 0, 0, 12)
        
        revealCloseButton?.setImage(UIImage.iconCloseXBlack(), forState: .Normal)
        revealCloseButton?.setTitle("", forState: .Normal)
 
        let revelTitleText                  = NSLocalizedString("Why is Facebook required?", comment:"CMFacebookAuthView : revealTitleLabel : text")
        revealTitleLabel?.text              = revelTitleText
        revealTitleLabel?.font              = UIFont.proxima(.SemiBold, size:FontSizes.s15)
        revealTitleLabel?.textColor         = UIColor.bistre()
        revealTitleLabel?.numberOfLines     = 0
        
        let revealBodyText                  = NSLocalizedString("Your application is an important step in keeping our community healthy. It also provides Capture and its end hiring managers a genuine gauge for your photography and video experience prior to making a decision.", comment:"CMFacebookAuthView : revealBodyLabel : text")
        let attRBT                          = NSMutableAttributedString(string: revealBodyText)
        let paragraphStyle                  = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing          = 6
        paragraphStyle.alignment            = .Center
        attRBT.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attRBT.length))
 
        revealBodyLabel?.attributedText     = attRBT
        revealBodyLabel?.font               = UIFont.proxima(.Regular, size:FontSizes.s13)
        revealBodyLabel?.textColor          = UIColor.taupeGray()
        revealBodyLabel?.numberOfLines      = 0
        
        revealHeight                        = ScreenSize.SCREEN_WIDTH * 0.6 + 40
        revealConstraint?.constant          = -revealHeight
        layoutIfNeeded()
    }
    
}