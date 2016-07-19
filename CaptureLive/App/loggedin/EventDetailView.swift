//
//  CMEventDetailView.swift
//  Current
//
//  Created by Scott Jones on 2/23/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

protocol EventStatusUpdatable {
    func updateForAccepted()
    func updateForHired()
    func updateForCancelled()
    func updateForArrived()
    func updateForArrivedAndHasRecordedVideo()
}

class EventDetailView: UIView, ActivityIndicatable {

    @IBOutlet var backButton:UIButton?
    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var bannerImageView:UIImageView?
    @IBOutlet weak var logoImageView:UIImageView?
    @IBOutlet weak var scrollView:UIScrollView?
    @IBOutlet weak var imageHeightConstant:NSLayoutConstraint?
    @IBOutlet weak var scrollContentHeight:NSLayoutConstraint?
    @IBOutlet weak var unappliedEventModuleView:UnappliedEventModuleView?
    @IBOutlet weak var appliedEventModuleView:AppliedEventModuleView?
    @IBOutlet weak var agreementFormModuleView:AgreementFormModuleView?
    @IBOutlet weak var appliedInfoModuleView:AppliedInfoModuleView?
    
    func populate(viewModel:EventApplicationModel) {
        logoImageView?.image                = nil
        CMImageCache.defaultCache().imageForPath(viewModel.organizationLogoPath, complete: { [weak self] error, image in
            if error == nil {
                self?.logoImageView?.image  = image
            }
        })
        bannerImageView?.image              = nil
        CMImageCache.defaultCache().imageForPath(viewModel.bannerImagePath, complete: { [weak self] error, image in
            if error == nil {
                self?.bannerImageView?.image = image
            }
        })
        subTitleLabel?.text                 = viewModel.titleString
        unappliedEventModuleView?.populate(viewModel.titlesAndData)
        appliedEventModuleView?.populate(viewModel)
        appliedInfoModuleView?.populate(viewModel.titlesAndData)
    }

    func startProcessing() {
        alpha                               = 0.4
    }
    func stopProcessing() {
        alpha                               = 1
    }
    
    func showUnapplied() {
        backgroundColor                     = UIColor.mountainMeadow()
        hideAllEventModules()
        unappliedEventModuleView?.hidden    = false
        agreementFormModuleView?.hide()
    }
    
    func showApplication() {
        backgroundColor                     = UIColor.silver()
        agreementFormModuleView?.show()
    }
    
    func hideApplication() {
        backgroundColor                     = UIColor.mountainMeadow()
        agreementFormModuleView?.hide()
    }
    
    func toggleShowDetails(hasApplied:Bool) {
        backgroundColor                     = UIColor.isabelline()
        if appliedInfoModuleView?.bottomConstraint?.constant < 0 {
            appliedInfoModuleView?.show()
            animateLayoutTall()
        } else {
            appliedInfoModuleView?.hide()
            if hasApplied {
                animateLayoutShortApplied()
            } else {
                animateLayoutShort()
            }
        }
    }
    
    func showApplied() {
        backgroundColor                     = UIColor.isabelline()
        hideAllEventModules()
        appliedInfoModuleView?.hidden       = false
        appliedEventModuleView?.hidden      = false
    }
    
    func hideAllEventModules() {
        agreementFormModuleView?.hidden     = true
        appliedInfoModuleView?.hidden       = true
        unappliedEventModuleView?.hidden    = true
        appliedEventModuleView?.hidden      = true
    }
   
    
    // MARK: Applied
    func revealApplied() {
        backgroundColor                     = UIColor.isabelline()
        showApplied()
        agreementFormModuleView?.hide()
    }
    
    func animateLayoutTall() {
        UIView.animateWithDuration(0.5,
                                   delay: 0.15,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
            self?.layoutTall()
            
            }) { fin in
                
        }
    }
    
    func animateLayoutShort() {
        UIView.animateWithDuration(0.75,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
            self?.layoutShort()
            
        }) { fin in
            
        }
    }
    
    func animateLayoutShortApplied() {
        UIView.animateWithDuration(0.75,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                                    self?.layoutShortApplied()
                                    
        }) { fin in
            
        }
    }

    
    func layoutShort() {
        let height                          = unappliedEventModuleView!.totalHeight
        imageHeightConstant?.constant       = ScreenSize.SCREEN_HEIGHT - height
        scrollContentHeight?.constant       = height + 1
        agreementFormModuleView?.hiddenHeight = height
        layoutIfNeeded()
    }
    
    func layoutShortApplied() {
        let height                          = ScreenSize.SCREEN_HEIGHT * 0.549
        imageHeightConstant?.constant       = ScreenSize.SCREEN_HEIGHT - height
        scrollContentHeight?.constant       = height + 1
        agreementFormModuleView?.hiddenHeight = height
        layoutIfNeeded()
    }
    
    func layoutTall() {
        let height                          = appliedInfoModuleView!.totalHeight
        imageHeightConstant?.constant       = ScreenSize.SCREEN_HEIGHT - height
        scrollContentHeight?.constant       = height + 1
        layoutIfNeeded()
    }
 
}

extension EventDetailView : CMViewProtocol {
    
    func didLoad() {
        unappliedEventModuleView?.didLoad()
        appliedEventModuleView?.didLoad()
        agreementFormModuleView?.didLoad()
        appliedInfoModuleView?.didLoad()
        
        logoImageView?.clipsToBounds        = true
        logoImageView?.layer.cornerRadius   = (ScreenSize.SCREEN_WIDTH * 0.25) / 2
        logoImageView?.backgroundColor      = UIColor.whiteColor()
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowWhite(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)

        let titleText                       = NSLocalizedString("Apply to be hired for:", comment: "EventDetailView : applyTitle : text")
        titleLabel?.text                    = titleText
        titleLabel?.font                    = UIFont.sourceSansPro(.SemiBold, size:FontSizes.s22)
        titleLabel?.textColor               = UIColor.whiteColor()
        titleLabel?.layer.shadowOpacity     = 0.7
        titleLabel?.layer.shadowOffset      = CGSizeMake(0, 0.2)
        titleLabel?.layer.shadowRadius      = 0.5
        titleLabel?.clipsToBounds           = false
        
        subTitleLabel?.font                 = UIFont.sourceSansPro(.SemiBold, size:FontSizes.s14)
        subTitleLabel?.textColor            = UIColor.whiteColor()
        subTitleLabel?.numberOfLines        = 0
        subTitleLabel?.layer.shadowOpacity  = 0.7
        subTitleLabel?.layer.shadowOffset   = CGSizeMake(0, 0.2)
        subTitleLabel?.layer.shadowRadius   = 0.5
    }
    
}


