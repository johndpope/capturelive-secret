//
//  CMLiveStreamView.swift
//  Current
//
//  Created by Scott Jones on 9/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//  

import UIKit
import CaptureUI

class LiveStreamView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var requestView:StreamRequestView?
    @IBOutlet weak var setupTimer:CMSetupTimer?
    @IBOutlet weak var actionMessenger:PublisherActionMessenger?
    @IBOutlet weak var timeLabel:UILabel?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var stopButton:UIButton?
    @IBOutlet weak var vielView:UIView?
    @IBOutlet weak var vielViewHieghtConstraint:NSLayoutConstraint?
    @IBOutlet weak var statusLabel:UILabel?
    @IBOutlet weak var statusLabelWidthConstraint:NSLayoutConstraint?
   
    @IBOutlet weak var lastFrameImageView:UIImageView?
    @IBOutlet weak var lastFrameGrayscaleImageView:UIImageView?
    @IBOutlet weak var videoLinesImageView:UIImageView?
 
    var countdownclock:CMCountdownClock!
    var videoView:CMVideoView?
    var isRecording                                     = false

    @IBOutlet weak var lowButton:CMPrimaryButton?
    @IBOutlet weak var normalButton:CMPrimaryButton?
    @IBOutlet weak var mediumButton:CMPrimaryButton?
    @IBOutlet weak var autoButton:CMPrimaryButton?
    @IBOutlet weak var intentionalCrashButton:UIButton?
    @IBOutlet weak var buttonContainer:UIView?
 
    override func layoutSubviews() {
        self.videoView?.bounds                          = self.bounds
        self.videoView?.frame                           = self.bounds

        self.videoView?.setOrientation()
        self.requestView?.setOrientation()

        super.layoutSubviews()
    }
   
    func addCMVideoView(videoView:CMVideoView) {
        self.videoView?.removeFromSuperview()
        self.videoView                                  = videoView
        self.insertSubview(videoView, atIndex:0)
    }
   
    func setOrientation() {
        self.videoView?.setOrientation()
        self.requestView?.setOrientation()
        self.layoutIfNeeded()
    }
    
    func populate(viewModel:EventHiredModel) {
        actionMessenger?.populate(viewModel)
    }
    
    func transitionToCameraView() {
        isRecording                                     = true
        requestView?.hidden                             = true
        requestView?.removeFromSuperview()
        requestView                                     = nil
        stopActivityIndicator()

        UIView.animateWithDuration(0.4, animations: {
            
             }, completion: { [weak self] finished in
                self?.transitionToRecordingView()
        })
    }
    
    func transitionToRecordingView() {
        setupTimer?.hidden                              = false
        setupTimer?.alpha                               = 0
        stopButton?.hidden                              = false
        stopButton?.alpha                               = 0
 
        UIView.animateWithDuration(0.7, animations: { [weak self] in
            self?.setupTimer?.alpha                     = 1
            self?.stopButton?.alpha                     = 1

            
            }, completion: { fin in
                
        })

        self.countdownclock                             = CMCountdownClock(progressClosure: { progress in
            
            }, incrementClosure: { [weak self] index in
                if index == 1 {
                    self?.setupTimer?.transitionToRecordingView()
                }
                self?.timeLabel?.text                   = "\(index)"
                
            }, finalClosure: { [weak self] in
                self?.timeLabel?.hidden                 = true
                self?.animateInUI()
        })
        
        countdownclock.from                             = 3
        timeLabel?.text                                 = "\(3)"
        
        countdownclock.start()
        stopActivityIndicator()
    }
    
    func updateTime(coverageTime:CoverageTime) {
        setupTimer?.updateTime(coverageTime)
    }

    func onActionStreamMessage(message:String) {
        actionMessenger?.showMessage(message)
    }
    
    func onConnected() {
    }
    
    func killActivity() {
    }
   
    func animateInUI() {
        actionMessenger?.animateIn()
        UIView.animateWithDuration(0.7, animations: { [weak self] in
            self?.vielViewHieghtConstraint?.constant    = 54
            self?.statusLabelWidthConstraint?.constant  = 150
            self?.layoutIfNeeded()
            
            }, completion: { fin in

        })
    }
    
    func transitionToSavingFiles() {
        startActivityIndicator()
        timeLabel?.hidden                               = false
        timeLabel?.font                                 = UIFont.proxima(.Regular, size: 20)

        let text                                        = NSLocalizedString("Wrapping up...", comment: "CMLiveStreamView : savingFiles : text")
        timeLabel?.text                                 = text
        
        actionMessenger?.animateOut { [weak self] in
            UIView.animateWithDuration(0.75,
                animations: { [weak self] in
                    self?.statusLabelWidthConstraint?.constant = 0
                    self?.actionMessenger?.widthConstraint?.constant = 0
                    self?.layoutIfNeeded()
                    
                }, completion: { [weak self] finished in
                    self?.actionMessenger?.removeFromSuperview()
                    self?.setupTimer?.animateOut()
 
            })
        }
    }
    
    func freezOnFrame(image:UIImage) {
        self.lastFrameImageView?.image                  = image
        self.videoView?.hidden                          = true
        
        UIView.animateWithDuration(1.0, animations: { [weak self] in
            self?.vielViewHieghtConstraint?.constant    = ScreenSize.SCREEN_WIDTH
            self?.layoutIfNeeded()

            }, completion: { fin in
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let img                                     = image.convertToGrayScale()
            dispatch_async(dispatch_get_main_queue()) {
                self.lastFrameGrayscaleImageView?.image = img
                self.videoLinesImageView?.hidden        = false
                self.videoLinesImageView?.alpha         = 0
                
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.lastFrameImageView?.alpha      = 0
                    self.videoLinesImageView?.alpha     = 1
                    }, completion: { (fin:Bool) -> Void in
                        self.lastFrameImageView?.hidden = true
                })
                
            }
        }
    }

}


extension LiveStreamView : CMViewProtocol {
    
    func didLoad() {
        actionMessenger?.didLoad()
        requestView?.didLoad()
        
        stopActivityIndicator()
        
        vielView?.backgroundColor                   = UIColor.blackCurrent(0.5)

        timeLabel?.font                             = UIFont.comfortaa(.Regular, size: 80)
        timeLabel?.textColor                        = UIColor.whiteCurrent()
        timeLabel?.text                             = ""
        
        videoLinesImageView?.image                  = UIImage(named:"static-lines")
        videoLinesImageView?.hidden                 = true

        stopButton?.setImage(UIImage(named:"bttn_camerarecord_active"), forState: .Normal)
        stopButton?.setImage(UIImage(named:"bttn_camerarecord_active_hit"), forState: .Selected)
        stopButton?.setImage(UIImage(named:"bttn_camerarecord_active_hit"), forState: .Highlighted)
        stopButton?.setTitle("", forState: .Normal)
        
        vielViewHieghtConstraint?.constant          = ScreenSize.SCREEN_HEIGHT

        stopButton?.hidden                          = true

        setupTimer?.hidden                          = true
        setupTimer?.setup()
        setupTimer?.layer.cornerRadius              = 2

        statusLabel?.backgroundColor                = UIColor.blackCurrent(0.7)
        statusLabel?.textAlignment                  = .Center
        statusLabel?.layer.cornerRadius             = 2
        statusLabel?.clipsToBounds                  = true
        
        statusLabelWidthConstraint?.constant        = 0
        
        showNoNetworkData()
    }
    
}

protocol NetworkUpdatable {
    func showMediumNetwork()
    func showGoodNetwork()
    func showBadNetwork()
}

extension LiveStreamView : NetworkUpdatable {
    
    func createAttributedStatusText(statusString:String, color:UIColor)->NSAttributedString {
        let networkText             = NSLocalizedString("Network : ", comment: "CMLiveStreamView : networkText : text")
        let boldAtt                 = [
             NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s10)
            ,NSForegroundColorAttributeName : UIColor.whiteColor()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let statusAtt               = [
             NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s10)
            ,NSForegroundColorAttributeName : color
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]

        let networkString           = NSMutableAttributedString(string:networkText, attributes:boldAtt)
        let statusString            = NSMutableAttributedString(string:statusString, attributes:statusAtt)
        networkString.appendAttributedString(statusString)
        return networkString
    }
    
    func showMediumNetwork() {
        let mediumText              = NSLocalizedString("Medium", comment: "CMLiveStreamView : mediumText : text")
        statusLabel?.attributedText = createAttributedStatusText(mediumText, color: UIColor.yellowColor())
    }
    
    func showGoodNetwork() {
        let goodText              = NSLocalizedString("Good", comment: "CMLiveStreamView : goodText : text")
        statusLabel?.attributedText = createAttributedStatusText(goodText, color: UIColor.mountainMeadow())
    }
    
    func showBadNetwork() {
        let badText              = NSLocalizedString("Bad", comment: "CMLiveStreamView : badText : text")
        statusLabel?.attributedText = createAttributedStatusText(badText, color: UIColor.carmineRed())
    }
    
    func showNoNetworkData() {
        let badText              = NSLocalizedString("----", comment: "CMLiveStreamView : badText : text")
        statusLabel?.attributedText = createAttributedStatusText(badText, color: UIColor.whiteColor())
    }

}




















