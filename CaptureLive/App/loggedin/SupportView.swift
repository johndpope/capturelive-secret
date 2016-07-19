//
//  CMSupportView.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class SupportView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var tableHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var tableTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var containerView:UIView?
    
    func updateTableViewHeight(rows:Int) {
        tableHeightConstraint?.constant     = SupportTableViewCell.SupportTableViewCellHeight * CGFloat(rows) + 10
        self.layoutIfNeeded()
    }
    
}

extension SupportView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor                     = UIColor.isabelline()
        
        tableTopConstraint?.constant        = 1
       
        containerView?.layer.shadowOpacity  = 0.5
        containerView?.layer.shadowOffset   = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius   = 0.5
        
        tableView?.separatorColor           = UIColor.silver()
        tableView?.separatorStyle           = .SingleLine
        tableView?.separatorInset           = UIEdgeInsetsZero
        tableView?.backgroundView?.backgroundColor = UIColor.clearColor()
        tableView?.backgroundColor          = UIColor.clearColor()
        tableView?.scrollEnabled            = false
        
        navTitleLabel?.text                 = NSLocalizedString("Support", comment:"CMSupportView : navTitleLabel : text")
        navTitleLabel?.font                 = UIFont.proxima(.Regular, size: FontSizes.s17)
        navTitleLabel?.textColor            = UIColor.bistre()
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
    }

}