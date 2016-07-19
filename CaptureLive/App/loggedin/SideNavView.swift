//
//  CMSettingsView.swift
//  Current
//
//  Created by Scott Jones on 1/22/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class SideNavView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var blackBackgroundView:UIView?
    @IBOutlet weak var bottomContainerView:UIView?
    @IBOutlet weak var topContainerView:UIView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var avatarView:UIImageView?
    @IBOutlet weak var facebookIcon:UIImageView?
    @IBOutlet weak var tableHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var logOutButton:CMNavButton?
    @IBOutlet weak var profileButton:UIButton?
    @IBOutlet weak var bkImageView:UIImageView?
    
    var banner:CMMicroBanner?
    
    override func layoutSubviews() {
        avatarView?.layer.cornerRadius      = (topContainerView!.frame.size.width * 0.37) / 2
        facebookIcon?.layer.cornerRadius    = (avatarView!.frame.size.width * 0.25) / 2
        super.layoutSubviews()
    }
    
    func updateTableViewHeight(rows:Int) {
        tableHeightConstraint?.constant     = SideNavTableViewCell.SideNavTableViewCellHeight * CGFloat(rows) + 10
        self.layoutIfNeeded()
    }
   
}

extension SideNavView : CMViewProtocol {
    
    func didLoad() {
        profileButton?.setImage(UIImage(named: "bttn_myprofilesettings"), forState: .Normal)
        
        nameLabel?.font                     = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        nameLabel?.textColor                = UIColor.whiteColor()
       
        avatarView?.clipsToBounds           = true
        avatarView?.layer.borderColor       = UIColor.whiteColor().CGColor
        avatarView?.layer.borderWidth       = 4
 
        facebookIcon?.image                 = UIImage(named:"icon_fb_large")
        facebookIcon?.clipsToBounds         = true
 
        backgroundColor                     = UIColor.clearColor()
        topContainerView?.backgroundColor   = UIColor.mountainMeadow()
       
        blackBackgroundView?.backgroundColor = UIColor.blackColor()
        
        bottomContainerView?.backgroundColor = UIColor.jungleGreen()
        bottomContainerView?.layer.shadowColor   = UIColor.blackCurrent().CGColor
        bottomContainerView?.layer.shadowOpacity = 0.3
        bottomContainerView?.layer.shadowOffset  = CGSizeMake(3, 0)
        bottomContainerView?.layer.shadowRadius  = 2.5
        
        tableView?.separatorColor           = UIColor.mountainMeadow()
        tableView?.separatorStyle           = .SingleLine
        tableView?.separatorInset           = UIEdgeInsetsZero
        tableView?.backgroundView?.backgroundColor = UIColor.jungleGreen()
        tableView?.backgroundColor          = UIColor.jungleGreen()
        tableView?.scrollEnabled            = false
        
        let logoutString                    = NSLocalizedString("Log Out", comment:"SideNavView : logoutButton : text")
        logOutButton?.setImage(UIImage(named:"bttn_logout"), forState: .Normal)
        logOutButton?.setImage(UIImage(named:"bttn_logout"), forState: .Highlighted)
        logOutButton?.setTitle(logoutString, forState: .Normal)
    }
    
}
