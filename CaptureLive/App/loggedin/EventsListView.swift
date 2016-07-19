//
//  CMEventsListView.swift
//  Current
//
//  Created by Scott Jones on 2/23/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class EventsListView: UIView {
    
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var jobsLabel:UILabel?
    @IBOutlet weak var availableButton:UIButton?
    @IBOutlet weak var hiredButton:UIButton?
    @IBOutlet weak var buttonDividerView:UIView?
    @IBOutlet weak var buttonIndicatorView:UIView?
    @IBOutlet weak var buttonIndicatorViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var buttonIndicatorViewOffCenterConstraint:NSLayoutConstraint?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var zeroStateView:ZeroStateView?
    
    func animateAvailableSelected() {
        UIView.setAnimationsEnabled(false)
        UIView.setAnimationsEnabled(true)
        
        let w                               = ScreenSize.SCREEN_WIDTH * 0.45
        hiredButton?.selected               = false
        UIView.animateWithDuration(0.35, animations: { [weak self] in
            self?.buttonIndicatorViewOffCenterConstraint?.constant = -w * 0.5
            self?.layoutIfNeeded()
        }) { [weak self] fin in
            self?.availableButton?.selected = true
            self?.hiredButton?.selected     = false
        }
        populateZeroStateForAvailable()
    }
    
    func animateHiredSelected() {
        UIView.setAnimationsEnabled(false)
        UIView.setAnimationsEnabled(true)
        
        let w                               = ScreenSize.SCREEN_WIDTH * 0.45
        availableButton?.selected           = false
        UIView.animateWithDuration(0.35, animations: { [weak self] in
            self?.buttonIndicatorViewOffCenterConstraint?.constant = w * 0.5
            self?.layoutIfNeeded()
            }) { [weak self] fin in
            self?.hiredButton?.selected     = true
            self?.availableButton?.selected = false
        }
        populateZeroStateForHired()
    }
    
    func noAnimateAvailableSelected() {
        let w                               = ScreenSize.SCREEN_WIDTH * 0.45
        buttonIndicatorViewOffCenterConstraint?.constant = -w * 0.5
        availableButton?.selected           = true
        hiredButton?.selected               = false
        layoutIfNeeded()
        populateZeroStateForAvailable()
    }
    
    func noAnimateHiredSelected() {
        let w                               = ScreenSize.SCREEN_WIDTH * 0.45
        buttonIndicatorViewOffCenterConstraint?.constant = w * 0.5
        hiredButton?.selected               = true
        availableButton?.selected           = false
        layoutIfNeeded()
        populateZeroStateForHired()
    }

    func populateZeroStateForHired() {
        let noJobsText                      = NSLocalizedString("When you get hired\nfor a job it will appear here.", comment:"JobHistoryView : zeroStateView : hiredText")
        zeroStateView?.populate(noJobsText, imageName: "icon_briefcase")
    }
    
    func populateZeroStateForAvailable() {
        let noJobsText                      = NSLocalizedString("There’s currently no\njobs nearby. You’ll be\nnotified when a new job\nbecomesavailable.", comment:"JobHistoryView : zeroStateView : availableText")
        zeroStateView?.populate(noJobsText, imageName: "icon_notifications")
    }
    
}

extension EventsListView : CMViewProtocol {
    
    func didLoad() {
        populateZeroStateForAvailable()
        
        navView?.backgroundColor                    = UIColor.whiteColor()
        navView?.layer.shadowOpacity                = 0.5
        navView?.layer.shadowOffset                 = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius                 = 0.5
        
        let jobsLabelText                           = NSLocalizedString("LIVE JOBS", comment:"EventsListView : jobsLabel : titleText")
        let atts:[String: NSObject] = [
            NSForegroundColorAttributeName: UIColor.bistre(),
            NSKernAttributeName: 4.0,
            NSFontAttributeName : UIFont.proxima(.Bold, size:FontSizes.s17)
        ]
        jobsLabel?.attributedText                   = NSAttributedString(string: jobsLabelText, attributes: atts)

        backButton?.setImage(UIImage.iconHamburger(), forState: UIControlState.Normal)
        backButton?.setTitle("", forState: UIControlState.Normal)
        backButton?.imageView?.contentMode          = .ScaleAspectFill
        backButton?.contentHorizontalAlignment      = .Fill
        backButton?.contentVerticalAlignment        = .Fill
        backButton?.imageEdgeInsets                 = UIEdgeInsetsMake(12, 12, 12, 12)

        let unhiredJobs                             = NSLocalizedString("AVAILABLE", comment:"EventsListView : unhiredJobs : titleText")
        availableButton?.setTitle(unhiredJobs, forState: .Normal)
        availableButton?.setTitleColor(UIColor.mountainMeadow(), forState: .Selected)
        availableButton?.setTitleColor(UIColor.silver(), forState: .Normal)
        availableButton?.titleLabel?.font = UIFont.proxima(.Bold, size: FontSizes.s12)
        
        buttonDividerView?.backgroundColor          = UIColor.platinum()
        
        let hiredJobs                               = NSLocalizedString("HIRED", comment:"EventsListView : hiredJobs : titleText")
        hiredButton?.setTitle(hiredJobs, forState: .Normal)
        hiredButton?.setTitleColor(UIColor.mountainMeadow(), forState: .Selected)
        hiredButton?.setTitleColor(UIColor.silver(), forState: .Normal)
        hiredButton?.titleLabel?.font = UIFont.proxima(.Bold, size: FontSizes.s12)
        
        let w                                       = ScreenSize.SCREEN_WIDTH * 0.45
        buttonIndicatorViewWidthConstraint?.constant = w
        buttonIndicatorViewOffCenterConstraint?.constant = -w * 0.5
        buttonIndicatorView?.backgroundColor        = UIColor.mountainMeadow()
        
        availableButton?.selected                   = true
        hiredButton?.selected                       = false
        
        tableView?.contentInset                     = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView?.backgroundColor                  = UIColor.isabelline()
        tableView?.separatorStyle                   = .None
    }
    
}

