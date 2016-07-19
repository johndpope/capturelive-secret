//
//  EndJobView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class EndJobView: UIView {

    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bannerImageView:UIImageView?
    @IBOutlet weak var organizationLogoView:UIImageView?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var timeLabel:UILabel?
    @IBOutlet weak var backgroundBannerView:UIView?
    @IBOutlet weak var organizationNameLabel:UILabel?
    @IBOutlet weak var paymentAmountLabel:UILabel?
    @IBOutlet weak var paymentStatusLabel:UILabel?
    @IBOutlet weak var titleLabelHeightConstraint:NSLayoutConstraint?

    func update(viewModel:EventTableCellViewModel) {
        organizationLogoView?.image             = nil
        organizationLogoView?.backgroundColor   = UIColor.whiteColor()
        CMImageCache.defaultCache().imageForPath(viewModel.organizationLogoPath, complete: { [weak self] error, image in
            if error == nil {
                self?.organizationLogoView?.image = image
            }
        })
        bannerImageView?.image = nil
        CMImageCache.defaultCache().imageForPath(viewModel.bannerImagePath, complete: { [weak self] error, image in
            if error == nil {
                self?.bannerImageView?.image    = image
            }
        })
        
        let titleWidth = viewModel.titleString.heightWithConstrainedWidth(ScreenSize.SCREEN_WIDTH - 80, font: titleLabel!.font)
        titleLabelHeightConstraint?.constant    = titleWidth
        titleLabel?.text                        = viewModel.titleString
        timeLabel?.text                         = viewModel.completionDateString
        paymentAmountLabel?.text                = viewModel.paymentString
        organizationNameLabel?.text             = viewModel.organizationNameString
        paymentStatusLabel?.text                = viewModel.paymentStatusString
       
        backgroundBannerView?.backgroundColor   = UIColor.whiteColor()
        paymentStatusLabel?.textColor           = UIColor.taupeGray()
        organizationNameLabel?.textColor        = UIColor.taupeGray()
        
        if viewModel.isCancelledBool {
            let txt                             = NSLocalizedString("CANCELED", comment: "EndJobView : jobIsCancelled : text")
            paymentStatusLabel?.text            = txt
            paymentStatusLabel?.textColor       = UIColor.whiteColor()
            organizationNameLabel?.textColor    = UIColor.whiteColor()
            backgroundBannerView?.backgroundColor = UIColor.carmineRed()
        }
    }
    
}

extension EndJobView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor                         = UIColor.whiteColor()
        layer.shadowOpacity                     = 0.5
        layer.shadowOffset                      = CGSizeMake(0, 0.2)
        layer.shadowRadius                      = 0.5
        layer.cornerRadius                      = 2

        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = UIFont.proxima(.SemiBold, size: FontSizes.s14)
        titleLabel?.textColor                   = UIColor.whiteColor()
        titleLabel?.layer.shadowOpacity         = 0.7
        titleLabel?.layer.shadowOffset          = CGSizeMake(0, 0.2)
        titleLabel?.layer.shadowRadius          = 0.5
        
        bannerImageView?.contentMode            = .ScaleAspectFill
        bannerImageView?.clipsToBounds          = true
        
        iconImageView?.image                    = UIImage(named:"icon_jobname_star_wht")
        
        organizationLogoView?.clipsToBounds     = true
        organizationLogoView?.layer.cornerRadius = ((ScreenSize.SCREEN_WIDTH - 20) * 0.15) / 2
        
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
    }
    
}
