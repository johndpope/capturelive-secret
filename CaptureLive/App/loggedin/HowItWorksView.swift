//
//  CMSupportView.swift
//  Current
//
//  Created by Scott Jones on 1/25/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

class HowItWorksView: UIView {
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var imageView:UIImageView?

}

extension HowItWorksView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor            = UIColor.whiteColor()
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowWhite(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        titleLabel?.text                = NSLocalizedString("How it Works", comment:"HowItWorksView : titleLabel : text")
        titleLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s17)
        titleLabel?.textColor           = UIColor.whiteColor()
        
        subTitleLabel?.text             = NSLocalizedString("CaptureLive makes it seamless to\nget hired for live stream jobs.", comment:"HowItWorksView : subTitleLabel : text")
        subTitleLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s14)
        subTitleLabel?.textColor        = UIColor.whiteColor()
        subTitleLabel?.numberOfLines    = 0
        
        tableView?.separatorStyle       = .None
        tableView?.contentInset         = UIEdgeInsetsMake(15, 0, 40, 0)
        
        imageView?.image                = UIImage(named:"onboarding_image1")
        imageView?.contentMode          = .ScaleAspectFill
        self.layoutIfNeeded()
    }
    
}
