//
//  IsFilmingDoneView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class FootageView: UIView {

    @IBOutlet weak var decisionTitleLabel:UILabel?
    @IBOutlet weak var yesButton:CMPrimaryButton?
    @IBOutlet weak var noButton:CMSecondaryButton?
    @IBOutlet weak var pauseButton:CMSecondaryButton?
    @IBOutlet weak var progressContainerView:UIView?
    @IBOutlet weak var progressBarView:UIView?
    @IBOutlet weak var progressBarViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var progressContainerViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?

    @IBOutlet weak var decisionView:UIView?
    @IBOutlet weak var uploadingTitleLabel:UILabel?
    @IBOutlet weak var uploadingView:UIView?

    func showDecisionView() {
        progressBarViewWidthConstraint?.constant = 0
        decisionView?.hidden            = false
        uploadingView?.hidden           = true
    }
    
    func pauseUploading() {
        let resumeText                  = NSLocalizedString("PAUSE", comment: "FootageView : pauseButton : resumetext")
        pauseButton?.setTitle(resumeText, forState: .Normal)
    }
    
    func resumeUploading() {
        let pauseTxt                       = NSLocalizedString("RESUME", comment: "FootageView : pauseButton : text")
        pauseButton?.setTitle(pauseTxt, forState: .Normal)
    }
    
    func showUploadingVideos(numVideosUploaded:Int, totalNumVideos:Int, progress:CGFloat) {
        decisionView?.hidden            = true
        uploadingView?.hidden           = false
       
        let cVid = (numVideosUploaded == 0) ? 1 : numVideosUploaded
        let uploadingText               = NSLocalizedString("Uploading footage %d of %d...", comment: "FootageView : uploading : text")
        uploadingTitleLabel?.text       = String(NSString(format: uploadingText, cVid, totalNumVideos))

        progressBarViewWidthConstraint?.constant = (ScreenSize.SCREEN_WIDTH - 20) * progress
    }
    
    func showUploadingPaused() {
        decisionView?.hidden = true
        uploadingView?.hidden = false
    }
    
}

extension FootageView : CMViewProtocol {
    
    func didLoad() {
        progressBarViewWidthConstraint?.constant = 0
        heightConstraint?.constant      = ScreenSize.SCREEN_HEIGHT * 0.132
        
        decisionTitleLabel?.font        = UIFont.proxima(.Regular, size: FontSizes.s12)
        decisionTitleLabel?.textColor   = UIColor.bistre()
        let titleText                   = NSLocalizedString("Are you done filming for this job?", comment: "FootageView : filmOrComplete : text")
        decisionTitleLabel?.text        = titleText
        
        let noTxt                       = NSLocalizedString("NO", comment: "FootageView : noButton : text")
        noButton?.setTitle(noTxt, forState: .Normal)
        
        let yesTxt                      = NSLocalizedString("YES", comment: "FootageView : noButton : text")
        yesButton?.setTitle(yesTxt, forState: .Normal)
        
        
        uploadingTitleLabel?.font       = UIFont.proxima(.Regular, size: FontSizes.s12)
        uploadingTitleLabel?.textColor  = UIColor.bistre()
        
        let pauseTxt                       = NSLocalizedString("PAUSE", comment: "FootageView : pauseButton : text")
        pauseButton?.setTitle(pauseTxt, forState: .Normal)

        progressContainerView?.backgroundColor = UIColor.isabelline()
        progressBarView?.backgroundColor = UIColor.mountainMeadow()
        
        progressContainerView?.hidden   = true
    }

}

