//
//  CMEventDetailAcceptedView.swift
//  Current
//
//  Created by Scott Jones on 3/15/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

let DefaultInfoContainerBottom:CGFloat      = -(ScreenSize.SCREEN_HEIGHT * 0.22)
let ShowPublisherContainerBottom:CGFloat    = 0
let ButtonHeight:CGFloat                    = (ScreenSize.SCREEN_HEIGHT * 0.07)
let ToggleButtonBottomTop:CGFloat           = (ScreenSize.SCREEN_HEIGHT * 0.195) - ButtonHeight
let CollectionViewSingle                    = ScreenSize.SCREEN_WIDTH * 0.3
let CollectionViewTopSingle                 = -(ScreenSize.SCREEN_WIDTH * 0.04)
let CollectionViewDouble                    = ScreenSize.SCREEN_WIDTH * 0.8
let CollectionViewTopDouble                 = ScreenSize.SCREEN_WIDTH * 0.071

class GetToJobView: UIView, ActivityIndicatable, UIScrollViewDelegate {

    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var infoContainerView:UIView?
    @IBOutlet weak var infoContainerBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var toggleButtonTop:UIButton?
    @IBOutlet weak var toggleButtonBottom:CenteredButton?
    @IBOutlet weak var toggleButtonBottomHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var collectionViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var collectionViewTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var publisherCell:EventInfoView?
    @IBOutlet weak var publisherCellWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var teamCell:EventInfoView?
    @IBOutlet weak var teamCellWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var jobInfoButtonsModuleView:JobInfoButtonsModuleView?
    @IBOutlet weak var contactButton:UIButton?
    @IBOutlet weak var labelContainer:UIView?
    @IBOutlet weak var publisherTitleLabel:UILabel?
    @IBOutlet weak var publisherNameLabel:UILabel?
    @IBOutlet weak var teamTitleLabel:UILabel?
    @IBOutlet weak var teamNameLabel:UILabel?
    @IBOutlet weak var jobLocationTitleLabel:UILabel?
    @IBOutlet weak var jobAddressLabel:UILabel?
    @IBOutlet weak var navigateToMapsButton:UIButton?
    @IBOutlet weak var mapPinButton:UIButton?
    @IBOutlet weak var getToJobLabel:UILabel?
    @IBOutlet weak var jobDirectionsContainer:UIView?
    @IBOutlet weak var mapView:MKMapView?
    
    @IBOutlet weak var jobDetailsModuleView:JobDetailsModuleView?
    
    func populate(hiredModel:EventHiredModel) {
        jobDetailsModuleView?.populate(hiredModel.eventModel.titlesAndData)
        publisherNameLabel?.text                    = hiredModel.publisherNameString
        teamNameLabel?.text                         = hiredModel.eventModel.organizationNameString
        jobAddressLabel?.text                       = hiredModel.eventModel.exactAddressString
        
        publisherCell?.configure(hiredModel.publisherNameString, imagePathString: hiredModel.publisherAvatarString)
        teamCell?.configure(hiredModel.eventModel.organizationNameString, imagePathString: hiredModel.eventModel.organizationLogoPath)
    }
   
    func togglePublisherInfo() {
        if infoContainerBottomConstraint!.constant < 0 {
            animateToPublisherDisplay()
        } else {
            animateToDefaultDisplay()
        }
    }
    
    func defaultInfoDisplay() {
        infoContainerBottomConstraint?.constant     = DefaultInfoContainerBottom
        collectionViewWidthConstraint?.constant     = CollectionViewSingle
        collectionViewTopConstraint?.constant       = CollectionViewTopSingle
        toggleButtonTop?.alpha                      = 0
        toggleButtonBottom?.alpha                   = 1
        labelContainer?.alpha                       = 1
        layoutIfNeeded()
    }
    
    func showPublisherInfoDisplay() {
        infoContainerBottomConstraint?.constant     = ShowPublisherContainerBottom
        collectionViewWidthConstraint?.constant     = CollectionViewDouble
        collectionViewTopConstraint?.constant       = CollectionViewTopDouble
        toggleButtonTop?.alpha                      = 1
        toggleButtonBottom?.alpha                   = 0
        labelContainer?.alpha                       = 0
        layoutIfNeeded()
    }
    
    func animateToDefaultDisplay() {
        publisherCell?.hideLabels()
        teamCell?.hideLabels()
        
        labelContainer?.hidden                      = false
        toggleButtonBottom?.hidden                  = false
        toggleButtonTop?.hidden                     = false
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.9,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
            self?.defaultInfoDisplay()
                                    
        }) { [weak self] fin in
            self?.toggleButtonTop?.hidden           = true
            self?.teamCell?.hidden                  = true
        }
    }
    
    func animateToPublisherDisplay() {
        teamCell?.hidden                            = false
        toggleButtonBottom?.hidden                  = false
        toggleButtonTop?.hidden                     = false
        publisherCell?.showLabels()
        teamCell?.showLabels()
        UIView.animateWithDuration(0.7,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.7,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
            self?.showPublisherInfoDisplay()
                                    
        }) { [weak self] fin in
            self?.toggleButtonBottom?.hidden        = true
            self?.labelContainer?.hidden            = true
        }
    }
 
    // MARK: Job Details Module
    func showDetails() {
        jobDetailsModuleView?.show()
    }
    
    func hideDetails() {
        jobDetailsModuleView?.hide()
    }

    func toggleJobDetails() {
        jobDetailsModuleView?.toggleJobDetails()
    }
    
}

extension GetToJobView : CMViewProtocol {

    func didLoad() {
        jobInfoButtonsModuleView?.didLoad()
        jobDetailsModuleView?.didLoad()
        
        navView?.backgroundColor                = UIColor.whiteColor()
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        navTitleLabel?.textColor                = UIColor.bistre()
        navTitleLabel?.text                     = NSLocalizedString("On the Job", comment:"GetToJobView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        getToJobLabel?.text                     = NSLocalizedString("Get to the job location", comment:"GetToJobView : getToJobLabel : text")
        getToJobLabel?.font                     = UIFont.proxima(.SemiBold, size: FontSizes.s16)
        getToJobLabel?.textColor                = UIColor.whiteColor()
        getToJobLabel?.backgroundColor          = UIColor.mountainMeadow()
        
        jobLocationTitleLabel?.text             = NSLocalizedString("Job Location", comment:"GetToJobView : jobLocationTitleLabel : text")
        jobLocationTitleLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        jobLocationTitleLabel?.textColor        = UIColor.taupeGray()
        
        jobAddressLabel?.font                   = UIFont.proxima(.Regular, size: FontSizes.s12)
        jobAddressLabel?.textColor              = UIColor.bistre()
        jobAddressLabel?.numberOfLines          = 0
        jobAddressLabel?.adjustsFontSizeToFitWidth = true
        
        
        jobDirectionsContainer?.layer.cornerRadius  = 2
        jobDirectionsContainer?.layer.shadowColor   = UIColor.bistre().CGColor
        jobDirectionsContainer?.layer.shadowOpacity = 0.2
        jobDirectionsContainer?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        jobDirectionsContainer?.layer.shadowRadius  = 4
       
        infoContainerView?.layer.shadowColor    = UIColor.bistre().CGColor
        infoContainerView?.layer.shadowOpacity  = 0.2
        infoContainerView?.layer.shadowOffset   = CGSizeMake(0, 0.5)
        infoContainerView?.layer.shadowRadius   = 4
        
        jobDetailsModuleView?.layer.shadowColor   = UIColor.bistre().CGColor
        jobDetailsModuleView?.layer.shadowOpacity = 0.2
        jobDetailsModuleView?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        jobDetailsModuleView?.layer.shadowRadius  = 4
 

        
        let openMapsText                        = NSLocalizedString("Open\nMap", comment:"GetToJobView : navigateToMapsButton : text")
        navigateToMapsButton?.setTitle(openMapsText, forState: .Normal)
        navigateToMapsButton?.setTitleColor(UIColor.mountainMeadow(), forState: .Normal)
        navigateToMapsButton?.titleLabel?.font  = UIFont.proxima(.Regular, size: FontSizes.s12)
        navigateToMapsButton?.titleLabel?.numberOfLines = 0
        
        mapPinButton?.setImage(UIImage(named: "icon_gps_small_red"), forState: .Normal)
        mapPinButton?.setTitle("", forState: .Normal)
        
        toggleButtonTop?.setImage(UIImage.iconDownArrowGray(), forState: .Normal)
        toggleButtonTop?.setTitle("", forState: .Normal)
        
        let infoText                            = NSLocalizedString("JOB DETAILS", comment:"GetToJobView : toggleButtonBottom : text")
        toggleButtonBottom?.setTitle(infoText, forState: .Normal)
        toggleButtonBottom?.setImage(UIImage.iconDownArrowGray(), forState: .Normal)
        toggleButtonBottom?.setTitleColor(UIColor.bistre(), forState: .Normal)
        toggleButtonBottom?.titleLabel?.font    = UIFont.proxima(.Bold, size: FontSizes.s12)
        toggleButtonBottom?.backgroundColor     = UIColor.isabelline()
        toggleButtonBottom?.titleLabel?.numberOfLines = 0
        toggleButtonBottom?.titleLabel?.textAlignment = .Center
        toggleButtonBottomHeightConstraint?.constant = ButtonHeight

        let contactText = NSLocalizedString("CONTACT", comment:"GetToJobView : contactButton : text")
        contactButton?.setTitle(contactText, forState: .Normal)
        contactButton?.setTitleColor(UIColor.bistre(), forState: .Normal)
        contactButton?.titleLabel?.font         = UIFont.proxima(.Bold, size: FontSizes.s10)
        contactButton?.backgroundColor          = UIColor.isabelline()
        contactButton?.layer.borderColor        = UIColor.pastelGray().CGColor
        contactButton?.layer.borderWidth        = 1
        contactButton?.layer.cornerRadius       = 2
       
        let publTitleText                        = NSLocalizedString("Job Manager", comment:"GetToJobView : publisherTitleLabel : text")
        publisherTitleLabel?.text               = publTitleText
        publisherTitleLabel?.font               = UIFont.proxima(.Regular, size: FontSizes.s10)
        publisherTitleLabel?.textColor          = UIColor.taupeGray()
        
        publisherNameLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s12)
        publisherNameLabel?.textColor           = UIColor.bistre()
        publisherNameLabel?.adjustsFontSizeToFitWidth = true
 
        let teamTitleText                        = NSLocalizedString("Job Manager", comment:"GetToJobView : teamTitleLabel : text")
        teamTitleLabel?.text                    = teamTitleText
        teamTitleLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s10)
        teamTitleLabel?.textColor               = UIColor.taupeGray()
 
        teamNameLabel?.font                     = UIFont.proxima(.Bold, size: FontSizes.s12)
        teamNameLabel?.textColor                = UIColor.bistre()
        teamNameLabel?.adjustsFontSizeToFitWidth = true

        publisherCellWidthConstraint?.constant  = CollectionViewSingle
        teamCellWidthConstraint?.constant       = CollectionViewSingle
       
        publisherCell?.hideLabels()
        teamCell?.hideLabels()
        teamCell?.hidden                        = true
 
        toggleButtonTop?.hidden                 = true
        defaultInfoDisplay()
    }
    
}
