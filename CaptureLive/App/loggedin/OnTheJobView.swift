//
//  CMEventBossView.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class OnTheJobView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var mapView:MKMapView?

    @IBOutlet weak var cameraButton:UIButton?
    @IBOutlet weak var directionsHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var directionsModuleView:DirectionsModuleView?
    @IBOutlet weak var jobCompletedAlertView:JobCompletedAlertView?
    @IBOutlet weak var alertBackgroundView:UIView?
    @IBOutlet weak var mapTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var mapBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var cameraButtonBottomConstraint:NSLayoutConstraint?
   
    @IBOutlet weak var infoContainerView:UIView?
    @IBOutlet weak var infoContainerBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var publisherCell:EventInfoView?
    @IBOutlet weak var publisherCellWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var teamCell:EventInfoView?
    @IBOutlet weak var teamCellWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var jobInfoButtonsModuleView:JobInfoButtonsModuleView?
    @IBOutlet weak var toggleButtonTop:UIButton?
    @IBOutlet weak var toggleButtonBottom:CenteredButton?
    @IBOutlet weak var toggleButtonBottomHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var contactButton:UIButton?
    @IBOutlet weak var collectionViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var collectionViewTopConstraint:NSLayoutConstraint?
   
    @IBOutlet weak var jobDetailsModuleView:JobDetailsModuleView?
    
    func populate(contract contract:ContractOnTheJobViewModel, hiredModel:EventHiredModel) {
        jobDetailsModuleView?.populate(hiredModel.eventModel.titlesAndData)
      
        publisherCell?.configure(hiredModel.publisherNameString, imagePathString: hiredModel.publisherAvatarString)
        teamCell?.configure(hiredModel.eventModel.organizationNameString, imagePathString: hiredModel.eventModel.organizationLogoPath)
        
        if contract.isUploadingBool {
            let total:Int = Int(contract.numUploadedAttachmentsInt + contract.numUnuploadedAttachmentsInt)
            var mark:Int = Int(contract.numUploadedAttachmentsInt) - 1
            mark = mark < 0 ? 0 : mark
            directionsModuleView?.showUploadingVideos(mark, totalNumVideos:total, progress:0)
            
            showUploading()
            return
        }
        
        if contract.numUnuploadedAttachmentsInt > 0 {
            showDecision()
            return
        }
        
        if contract.numUnuploadedAttachmentsInt == 0 {
            if contract.hasArrivedBool {
                showYouveArrived()
            } else {
                showGetToLocation(contract.distanceAwayDouble)
            }
        }
    }

    func keepFilming() {
        cameraButton?.hidden = false
        showYouveArrived()
    }
    
    func addAttachments(attachments:[AttachmentCollectionViewModel]) {
        directionsModuleView?.addAttachments(attachments)
    }
    
    func pauseUploading() {
        directionsModuleView?.pauseUploading()
    }
    
    func resumeUploading() {
        directionsModuleView?.resumeUploading()
    }
    
    func showUploadingVideos(numVideosUploaded:Int, totalNumVideos:Int, progress:CGFloat) {
        directionsModuleView?.showUploadingVideos(numVideosUploaded, totalNumVideos:totalNumVideos, progress:progress)
    }
    
    func showCompletedAlert() {
        alertBackgroundView?.hidden             = false
        alertBackgroundView?.alpha              = 0

        UIView.animateWithDuration(0.4, animations: { [weak self] in
            self?.alertBackgroundView?.alpha    = 1
            
            }) { [weak self] fin in
                self?.jobCompletedAlertView?.show()

        }
    }
    
    private func showGetToLocation(milesAway:Double) {
        cameraButton?.hidden = false
        directionsModuleView?.showGetToLocation(milesAway)
        useShortHeight()
    }
    
    private func showYouveArrived() {
        cameraButton?.hidden = false
        directionsModuleView?.showYouveArrived()
        animateShort()
    }
    
    private func showDecision() {
        cameraButton?.hidden = true
        directionsModuleView?.showDecision()
        animateTall()
    }
    
    private func showUploading() {
        cameraButton?.hidden = true
        directionsModuleView?.showUploading()
        animateTall()
    }
    
    private func animateShort() {
        UIView.animateWithDuration(0.7,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.7,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                self?.useShortHeight()
                                    
        }) { fin in
        }
    }
    
    private func animateTall() {
        UIView.animateWithDuration(0.7,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.7,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                self?.useTallHeight()
                                    
       }) { fin in
        }
    }
    
    private func useTallHeight() {
        let height = ScreenSize.SCREEN_HEIGHT * 0.519
        directionsHeightConstraint?.constant    = height
    }
    
    private func useShortHeight() {
        let height = ScreenSize.SCREEN_HEIGHT * 0.186
        directionsHeightConstraint?.constant    = height
    }
    
    func showLandscape() {
        mapTopConstraint?.constant              = 0
        mapBottomConstraint?.constant           = 0
        layoutIfNeeded()
    }
    
    func showPortrait() {
        mapTopConstraint?.constant              = ScreenSize.SCREEN_WIDTH * 0.187
        mapBottomConstraint?.constant           = ScreenSize.SCREEN_WIDTH * 0.125
        layoutIfNeeded()
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
        infoContainerView?.alpha                    = 0
        cameraButton?.alpha                         = 1
        layoutIfNeeded()
    }
    
    func showPublisherInfoDisplay() {
        infoContainerBottomConstraint?.constant     = ShowPublisherContainerBottom
        collectionViewWidthConstraint?.constant     = CollectionViewDouble
        collectionViewTopConstraint?.constant       = CollectionViewTopDouble
        toggleButtonTop?.alpha                      = 1
        toggleButtonBottom?.alpha                   = 0
        infoContainerView?.alpha                    = 1
        cameraButton?.alpha                         = 0
        layoutIfNeeded()
    }
    
    func animateToDefaultDisplay() {
        publisherCell?.hideLabels()
        teamCell?.hideLabels()
        
        toggleButtonBottom?.hidden                  = false
        toggleButtonTop?.hidden                     = false
        cameraButton?.hidden                        = false

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
            self?.infoContainerView?.hidden         = true

        }
    }
    
    func animateToPublisherDisplay() {
        teamCell?.hidden                            = false
        toggleButtonBottom?.hidden                  = false
        toggleButtonTop?.hidden                     = false
        infoContainerView?.hidden                   = false

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
            self?.cameraButton?.hidden              = true
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

extension OnTheJobView : CMViewProtocol {
    
    func didLoad() {
        jobInfoButtonsModuleView?.didLoad()
        jobDetailsModuleView?.didLoad()
        
        alertBackgroundView?.hidden             = true
        alertBackgroundView?.backgroundColor    = UIColor.blackCurrent(0.7)
        
        jobCompletedAlertView?.didLoad()
        directionsModuleView?.didLoad()
        
        cameraButton?.setBackgroundImage(UIImage(named: "bttn_camera_green_active"), forState: .Normal)
        cameraButton?.setBackgroundImage(UIImage(named: "bttn_camera_green_hit"), forState: .Highlighted)
        cameraButton?.setTitle("", forState: .Normal)
        
        navView?.backgroundColor                = UIColor.whiteColor()
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        navTitleLabel?.textColor                = UIColor.bistre()
        navTitleLabel?.text                     = NSLocalizedString("On the Job", comment:"GetToJobView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        
        backButton?.setBackgroundImage(UIImage.iconBackArrowBlack(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        cameraButtonBottomConstraint?.constant  = (ScreenSize.SCREEN_WIDTH * 0.125) + 10
        showPortrait()

        infoContainerView?.layer.shadowColor    = UIColor.bistre().CGColor
        infoContainerView?.layer.shadowOpacity  = 0.2
        infoContainerView?.layer.shadowOffset   = CGSizeMake(0, 0.5)
        infoContainerView?.layer.shadowRadius   = 4
        
        jobDetailsModuleView?.layer.shadowColor   = UIColor.bistre().CGColor
        jobDetailsModuleView?.layer.shadowOpacity = 0.2
        jobDetailsModuleView?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        jobDetailsModuleView?.layer.shadowRadius  = 4
        
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
        toggleButtonBottom?.layer.shadowColor   = UIColor.bistre().CGColor
        toggleButtonBottom?.layer.shadowOpacity = 0.2
        toggleButtonBottom?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        toggleButtonBottom?.layer.shadowRadius  = 4
        toggleButtonBottomHeightConstraint?.constant = ButtonHeight
        
        let contactText = NSLocalizedString("CONTACT", comment:"GetToJobView : contactButton : text")
        contactButton?.setTitle(contactText, forState: .Normal)
        contactButton?.setTitleColor(UIColor.bistre(), forState: .Normal)
        contactButton?.titleLabel?.font         = UIFont.proxima(.Bold, size: FontSizes.s10)
        contactButton?.backgroundColor          = UIColor.isabelline()
        contactButton?.layer.borderColor        = UIColor.pastelGray().CGColor
        contactButton?.layer.borderWidth        = 1
        contactButton?.layer.cornerRadius       = 2

        publisherCellWidthConstraint?.constant  = CollectionViewSingle
        teamCellWidthConstraint?.constant       = CollectionViewSingle
        
        publisherCell?.hideLabels()
        teamCell?.hideLabels()
        teamCell?.hidden                        = true
        
        toggleButtonTop?.hidden                 = true
        defaultInfoDisplay()
    }
    
}































