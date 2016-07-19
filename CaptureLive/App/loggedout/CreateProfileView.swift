//
//  CMRegisterUserDescriptionView.swift
//  Current
//
//  Created by Scott Jones on 12/2/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class CreateProfileView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var backButton:UIButton?

    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var profileConstraint:NSLayoutConstraint?
    @IBOutlet weak var screenInteractionBlocker:UIView?
    
    var banner:CMMicroBanner!

    func updateTableViewHeight(rows:Int) {
        profileConstraint?.constant         = ProfileTableViewCell.ProfileTableViewCellHeight * CGFloat(rows) + 10
        self.layoutIfNeeded()
    }
    
    func animateUpdateTableViewHeight(rows:Int) {
        UIView.animateWithDuration(0.3, animations: { [weak self] in
            self?.updateTableViewHeight(rows)
            }) { finished in
        }
    }
    
    func profileUpdate(dictionary:[String:AnyObject]) {
        self.banner                                                 = CMMicroBanner(style: .Error)
        self.banner.message("\(dictionary)")
        self.banner.topView                                         = self
        self.banner.show()
    }

    func blockInteraction() {
        screenInteractionBlocker?.alpha     = 0
        screenInteractionBlocker?.hidden    = false
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.screenInteractionBlocker?.alpha = 1
        }
    }
    
    func unblockInteraction() {
        UIView.animateWithDuration(0.3, animations: { [weak self] in
            self?.screenInteractionBlocker?.alpha = 0
        }) { [weak self] finished in
            self?.screenInteractionBlocker?.hidden = true
        }
    }
    
}

extension CreateProfileView : CMViewProtocol {

    func didLoad() {
        backgroundColor                         = UIColor.isabelline()
 
        screenInteractionBlocker?.backgroundColor = UIColor.whiteCurrent(0.7)
        screenInteractionBlocker?.userInteractionEnabled = false
        screenInteractionBlocker?.hidden        = true
        
        containerView?.layer.shadowOpacity      = 0.5
        containerView?.layer.shadowOffset       = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius       = 0.5
        
        self.backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        self.backButton?.setTitle("", forState: .Normal)
        
        self.navTitleLabel?.text                = NSLocalizedString("My Profile", comment:"CMCreateProfileView : navTitleLabel : text")
        self.navTitleLabel?.font                = UIFont.proxima(.Regular, size: FontSizes.s17)
        self.navTitleLabel?.textColor           = UIColor.bistre()
        
        tableView?.separatorStyle               = .None
        tableView?.backgroundColor              = UIColor.isabelline()
    }

}
