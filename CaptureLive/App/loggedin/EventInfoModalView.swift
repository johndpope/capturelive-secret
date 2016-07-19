//
//  EventInfoModalView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class EventInfoModalView: UIView {

    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var dataLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var titleLabelHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var tableHeightConstraint:NSLayoutConstraint?
    
    func populate(viewModel:ModalInfo) {
        navTitleLabel?.text                 = viewModel.navTitleString
        titleLabel?.attributedText          = viewModel.titleString
        
        let paragraphRect                   = viewModel.titleString.boundingRectWithSize(CGSizeMake(300, 10000), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        titleLabelHeightConstraint?.constant = paragraphRect.height
       
        let tableHeight = viewModel.tableDataArray.totalHeight + titleLabelHeightConstraint!.constant + 40
        let maxtableheight                  = ScreenSize.SCREEN_HEIGHT - 95
        tableHeightConstraint?.constant     = min(tableHeight, maxtableheight)
    }
    
}

extension EventInfoModalView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor                     = UIColor.mountainMeadow()
        
        navTitleLabel?.font                 = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        navTitleLabel?.textColor            = UIColor.whiteColor()
        
        titleLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s14)
        titleLabel?.textColor               = UIColor.bistre()
        titleLabel?.textAlignment           = .Center
        titleLabel?.numberOfLines           = 0
      
        containerView?.layer.masksToBounds  = false
        containerView?.layer.cornerRadius   = 2
        containerView?.backgroundColor      = UIColor.whiteColor()
        containerView?.layer.shadowColor    = UIColor.bistre().CGColor
        containerView?.layer.shadowOpacity  = 0.7
        containerView?.layer.shadowOffset   = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius   = 0.5
       
        tableView?.separatorStyle           = .None
        
        closeButton?.setImage(UIImage.iconCloseXWhite(), forState: .Normal)
        closeButton?.setTitle("", forState: .Normal)
    }

}