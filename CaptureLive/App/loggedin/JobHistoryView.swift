//
//  JobHistoryView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/31/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class JobHistoryView : UIView {

    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var zeroStateView:ZeroStateView?

}

extension JobHistoryView : CMViewProtocol {
    
    func didLoad() {
        navView?.backgroundColor                = UIColor.whiteColor()
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        navTitleLabel?.textColor                = UIColor.bistre()
        navTitleLabel?.text                     = NSLocalizedString("Job History", comment:"JobHistoryView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        tableView?.contentInset                 = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView?.backgroundColor              = UIColor.isabelline()
        tableView?.separatorStyle               = .None
    
        let noJobsText                          = NSLocalizedString("There’s currently no\n completed jobs. Return here\nwhen you have completed\nat least one.", comment:"JobHistoryView : zeroStateView : text")
        zeroStateView?.populate(noJobsText, imageName: "icon_briefcase")
    }

}