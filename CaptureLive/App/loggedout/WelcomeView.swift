//
//  CMWelcomeView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class WelcomeView: UIView, ActivityIndicatable {

    @IBOutlet weak var nextButton:CMPrimaryButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var imageContainerView:UIView?
    @IBOutlet weak var containerView:UIView?
    
    func addUserName(name:String) {
        let titleText               = NSLocalizedString("Welcome\n%@", comment: "WelcomeView : title : text")
        let titleAttString          = NSMutableAttributedString(string: String(NSString(format:titleText, name)))
        let paragraphStyle          = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing  = 2
        paragraphStyle.alignment    = .Center
        titleAttString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, titleAttString.length))

        titleLabel?.attributedText  = titleAttString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.layer.cornerRadius = (containerView!.frame.size.width * 0.16) / 2
        imageView?.clipsToBounds    = true
    }

}

extension WelcomeView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor             = UIColor.isabelline()
     
        imageContainerView?.backgroundColor = UIColor.clearColor()
        imageContainerView?.layer.shadowOpacity  = 0.5
        imageContainerView?.layer.shadowOffset   = CGSizeMake(0, 0.6)
        imageContainerView?.layer.shadowRadius   = 0.5
 
        titleLabel?.font            = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        titleLabel?.textColor       = UIColor.bistre()
        titleLabel?.numberOfLines   = 0
        titleLabel?.adjustsFontSizeToFitWidth = true
       
        containerView?.layer.shadowOpacity  = 0.5
        containerView?.layer.shadowOffset   = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius   = 0.5
       
        let bodyText                = NSLocalizedString("In order to apply to get hired for CaptureLIVE jobs you’ll need to fill out your profile.", comment: "WelcomeView : body : text")
        let bodyAttString           = NSMutableAttributedString(string: bodyText)
        let paragraphStyle          = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing  = 4
        paragraphStyle.alignment    = .Center
        bodyAttString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, bodyAttString.length))
        
        bodyLabel?.attributedText   = bodyAttString
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
    
        let startText               = NSLocalizedString("START MY PROFILE", comment: "WelcomeView : submitButton : text")
        nextButton?.setTitle(startText, forState: .Normal)
        nextButton?.titleLabel?.font = UIFont.proxima(.Bold, size: FontSizes.s15)
        
        layoutIfNeeded()
    }
    
}