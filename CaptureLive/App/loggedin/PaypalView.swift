//
//  CMPaypalView.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class PaypalView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var verifyButton:CMPaypalButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var paypalLogoView:UIImageView?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var verifiedCenterLabel:UILabel?
    @IBOutlet weak var verifiedFooterLabel:UILabel?
    @IBOutlet weak var totalEarnedLabel:UILabel?
    @IBOutlet weak var amountEarnedLabel:UILabel?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var zeroView:UIView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var paypalLogoButton:CMPaypalButton?


    func populate(user:UserPaypalModel) {
        amountEarnedLabel?.text                 = user.totalAmountString
        paypalLogoButton?.setTitle("", forState: .Normal)
        paypalLogoButton?.setImage(UIImage(named:"icon_paypal_small"), forState: .Normal)
        paypalLogoButton?.transform         = CGAffineTransformMakeScale(-1.0, 1.0);
        paypalLogoButton?.titleLabel?.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        paypalLogoButton?.imageView?.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
        if user.needsPaypalEmailBool {
            verifyButton?.hidden                = true
            paypalLogoView?.hidden              = true
            paypalLogoButton?.hidden            = false
            tableView?.hidden                   = false
            let waitinForEmail                  = NSLocalizedString("Waiting for email ... ", comment: "PaypalView : waiting for email : text")
            paypalLogoButton?.setTitle(waitinForEmail, forState: .Normal)
        }
        if user.hasPaypalEmailBool {
            verifyButton?.hidden                = true
            paypalLogoView?.hidden              = true
            paypalLogoButton?.hidden            = false
            tableView?.hidden                   = false
        }
        
        if let email = user.paypalEmailString where email.characters.count > 0 {
            paypalLogoButton?.setTitle(email, forState: .Normal)
        }
    }
    
}

extension PaypalView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
       
        tableView?.hidden                       = true
        tableView?.separatorStyle               = .None
        
        paypalLogoButton?.hidden                = true
        paypalLogoButton?.titleLabel?.font      = UIFont.proxima(.Bold, size: FontSizes.s12)

        containerView?.layer.shadowOpacity      = 0.5
        containerView?.layer.shadowOffset       = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius       = 0.5
        
        paypalLogoView?.image                   = UIImage(named:"icon_paypaylogo")
       
        navTitleLabel?.textColor                = UIColor.blackCurrent()
        navTitleLabel?.text                     = NSLocalizedString("PAYPAL", comment:"CMPaypalView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        let verifytext                          = NSLocalizedString("VERIFY AN ACCOUNT", comment:"CMPaypalView : verifiedButton : text")
        verifyButton?.setTitle(verifytext, forState: .Normal)
        verifyButton?.contentHorizontalAlignment = .Center
        
        let paypalVerifiedText                  = NSLocalizedString("Paypal Verified!", comment:"CMPaypalView : verifiedCenterLabel : text")
        verifiedCenterLabel?.text               = paypalVerifiedText
        verifiedCenterLabel?.font               = UIFont.proxima(.Regular, size: 14)
        verifiedCenterLabel?.textColor          = UIColor.blackCurrent()
 
        let totalEarnedText                     = NSLocalizedString("Total Earned:", comment:"CMPaypalView : totalEarnedLabel : text")
        totalEarnedLabel?.text                  = totalEarnedText
        totalEarnedLabel?.font                  = UIFont.proxima(.Bold, size: FontSizes.s12)
        totalEarnedLabel?.textColor             = UIColor.taupeGray()
        
        amountEarnedLabel?.font                 = UIFont.proxima(.SemiBold, size: FontSizes.s36)
        amountEarnedLabel?.textColor            = UIColor.bistre()
        
        let verifiedFooterText                  = NSLocalizedString("You must verify your PayPal Account", comment:"CMPaypalView : verifiedFooterLabel : text")
        verifiedFooterLabel?.text               = verifiedFooterText
        verifiedFooterLabel?.font               = UIFont.proxima(.Bold, size: FontSizes.s12)
        verifiedFooterLabel?.textColor          = UIColor.bistre()
    }

}