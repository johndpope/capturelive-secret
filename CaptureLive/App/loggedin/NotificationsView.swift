//
//  CMNotificationsView.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class NotificationsView: UIView, ActivityIndicatable {

    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var navView:UIView?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

extension NotificationsView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
       
        navView?.backgroundColor                = UIColor.mountainMeadow()
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        tableView?.separatorStyle               = .None
        
        navTitleLabel?.textColor                = UIColor.whiteColor()
        navTitleLabel?.text                     = NSLocalizedString("Notifications", comment:"CMNotificationsView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowWhite(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
    }

}