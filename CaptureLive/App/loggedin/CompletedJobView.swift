//
//  CompletedJobView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class CompletedJobView: UIView {

    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bannerImageView:UIImageView?
    @IBOutlet weak var organizationLogoView:UIImageView?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var timeLabel:UILabel?
    @IBOutlet weak var organizationNameLabel:UILabel?
    @IBOutlet weak var paymentAmountLabel:UILabel?
    @IBOutlet weak var paymentStatusLabel:UILabel?
    @IBOutlet weak var titleLabelHeightConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var receiptView:UIView?
    @IBOutlet weak var helpButton:CMSecondaryButton?
    @IBOutlet weak var summaryLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var scrollView:UIScrollView?
    @IBOutlet weak var imageHeightConstant:NSLayoutConstraint?
    @IBOutlet weak var scrollContentHeight:NSLayoutConstraint?
   
    @IBOutlet weak var scrollContainerView:UIView?
    @IBOutlet weak var bottomCellView:UIView?
    
    func populate(viewModel:EventTableCellViewModel) {
        organizationLogoView?.image             = nil

        CMImageCache.defaultCache().imageForPath(viewModel.organizationLogoPath, complete: { [weak self] error, image in
            if error == nil {
                self?.organizationLogoView?.image = image
            }
        })
        bannerImageView?.image                  = nil
        CMImageCache.defaultCache().imageForPath(viewModel.bannerImagePath, complete: { [weak self] error, image in
            if error == nil {
                self?.bannerImageView?.image    = image
            }
        })
        
        let titleWidth                          = viewModel.titleString.heightWithConstrainedWidth(ScreenSize.SCREEN_WIDTH - 80, font: titleLabel!.font)
        titleLabelHeightConstraint?.constant    = titleWidth
        
        navTitleLabel?.text                     = viewModel.completionDateString
        titleLabel?.text                        = viewModel.titleString
        timeLabel?.text                         = viewModel.completionDateString
        paymentAmountLabel?.text                = viewModel.paymentString
        organizationNameLabel?.text             = viewModel.organizationNameString
        paymentStatusLabel?.text                = viewModel.paymentStatusString
        
        bottomCellView?.backgroundColor         = UIColor.whiteColor()
        paymentStatusLabel?.textColor           = UIColor.taupeGray()
        organizationNameLabel?.textColor        = UIColor.taupeGray()

        if viewModel.isCancelledBool {
            let txt                             = NSLocalizedString("CANCELED", comment: "EndJobView : jobIsCancelled : text")
            paymentStatusLabel?.text            = txt
            paymentStatusLabel?.textColor       = UIColor.whiteColor()
            organizationNameLabel?.textColor    = UIColor.whiteColor()
            bottomCellView?.backgroundColor     = UIColor.carmineRed()
        }
    }
    
}

let StatusBarMargin:CGFloat                     = 20.0
extension CompletedJobView : CMViewProtocol {
    
    func didLoad() {
        navView?.backgroundColor                = UIColor.whiteColor()
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        navTitleLabel?.textColor                = UIColor.bistre()
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        let cellContainerHeight                 = EndedJobTableViewCellHeight - (10 + StatusBarMargin)
        let cellBottomHeight                    = (ScreenSize.SCREEN_WIDTH - 20) * 0.166
        
        imageHeightConstant?.constant           = cellContainerHeight - cellBottomHeight
        
        scrollContentHeight?.constant           = ScreenSize.SCREEN_HEIGHT - (imageHeightConstant!.constant + 60) + 1
        
        backgroundColor                         = UIColor.isabelline()
        
        scrollView?.backgroundColor             = UIColor.whiteColor()
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.layer.cornerRadius          = 2
        scrollView?.layer.borderColor           = UIColor.taupeGray().CGColor
        scrollView?.layer.borderWidth           = 0.5
       
        receiptView?.layer.borderColor          = UIColor.taupeGray().CGColor
        receiptView?.layer.borderWidth          = 0.5
        receiptView?.backgroundColor            = UIColor.whiteSmoke()
        
        let helpText                            = NSLocalizedString("NEED HELP?", comment:"CompletedJobView : helpButton : text")
        helpButton?.setTitle(helpText, forState: .Normal)
        helpButton?.titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s12)
       
        let summaryText                         = NSLocalizedString("CAPTURELIVE JOB SUMMARY", comment:"CompletedJobView : summaryLabel : text")
        summaryLabel?.font                      = UIFont.proxima(.Bold, size: FontSizes.s12)
        summaryLabel?.textColor                 = UIColor.bistre()
        summaryLabel?.backgroundColor           = UIColor.whiteColor()
        summaryLabel?.layer.borderColor         = UIColor.taupeGray().CGColor
        summaryLabel?.layer.borderWidth         = 0.5
        summaryLabel?.text                      = summaryText
        
        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = UIFont.proxima(.SemiBold, size: FontSizes.s14)
        titleLabel?.textColor                   = UIColor.whiteColor()
        titleLabel?.layer.shadowOpacity         = 0.7
        titleLabel?.layer.shadowOffset          = CGSizeMake(0, 0.2)
        titleLabel?.layer.shadowRadius          = 0.5
        
        bannerImageView?.contentMode            = .ScaleAspectFill

//        iconImageView?.image                    = UIImage(named:"icon_jobname_star_wht")
        
        organizationLogoView?.clipsToBounds     = true
        organizationLogoView?.layer.cornerRadius = ((ScreenSize.SCREEN_WIDTH - 20) * 0.15) / 2
        organizationLogoView?.backgroundColor   = UIColor.whiteColor()
        
        timeLabel?.font                         = UIFont.proxima(.Bold, size: FontSizes.s14)
        timeLabel?.textColor                    = UIColor.bistre()
        timeLabel?.adjustsFontSizeToFitWidth    = true
        
        paymentAmountLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s14)
        paymentAmountLabel?.textColor           = UIColor.bistre()
        paymentAmountLabel?.adjustsFontSizeToFitWidth = true
        
        organizationNameLabel?.font             = UIFont.proxima(.Bold, size: FontSizes.s14)
        organizationNameLabel?.textColor        = UIColor.taupeGray()
        organizationNameLabel?.adjustsFontSizeToFitWidth = true
        
        paymentStatusLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s14)
        paymentStatusLabel?.textColor           = UIColor.taupeGray()
        paymentStatusLabel?.adjustsFontSizeToFitWidth = true
        
        tableView?.separatorStyle               = .None
        tableView?.backgroundColor              = UIColor.whiteColor()
    }

}