//
//  CMSetupTimer.swift
//  Current-Tools
//
//  Created by Scott Jones on 9/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMSetupTimer: UIView {

    @IBOutlet weak var clockView:UIView?
    @IBOutlet weak var setupView:UIView?
    @IBOutlet weak var setupLabel:UILabel?
    @IBOutlet weak var liveLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor                     = UIColor.blackCurrent(0.7)

        liveLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s10)
        liveLabel?.textColor                = UIColor.carmineRed()
        liveLabel?.text                     = NSLocalizedString("LIVE", comment: "CMSetupTimer : livelabel : text")
        
        setupLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s10)
        setupLabel?.textColor               = UIColor.whiteColor()
        
        clockView?.hidden                   = true
        clockView?.backgroundColor          = UIColor.clearColor()
        clockView?.layer.cornerRadius       = 2
        clockView?.clipsToBounds            = true
        
        setupView?.hidden                   = false
        setupView?.backgroundColor          = UIColor.clearColor()
        setupView?.layer.cornerRadius       = 2
        setupView?.clipsToBounds            = true
 
        liveLabel?.attributedText           = createAttributedClockText("--:--:--", color: UIColor.carmineRed())
        setupLabel?.attributedText          = createAttributedClockText(" -- : -- : -- ", color: UIColor.bistre())
    }
    
    func transitionToRecordingView() {
        self.setupView?.hidden              = true
        self.clockView?.hidden              = false

        UIView.transitionFromView(self.setupView!,
            toView: self.clockView!,
            duration: 0.7,
            options: UIViewAnimationOptions.TransitionFlipFromTop ) { (fin:Bool) -> Void in

        }
    }
    
    func animateOut() {
        UIView.transitionWithView(self,
            duration: 0.7,
            options: UIViewAnimationOptions.TransitionFlipFromBottom,
            animations: { () -> Void in
                self.alpha                  = 0
            }) { (fin) -> Void in
                self.hidden                 = true
                
        }
    }
   
    func createAttributedClockText(timeString:String, color:UIColor)->NSAttributedString {
        let liveText                        = NSLocalizedString("LIVE ", comment: "CMSetupTimer : live : text")
        let boldAtt                         = [
             NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s10)
            ,NSForegroundColorAttributeName : color
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let timeAtt                         = [
             NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s10)
            ,NSForegroundColorAttributeName : UIColor.whiteColor()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        
        let networkString                   = NSMutableAttributedString(string:liveText, attributes:boldAtt)
        let statusString                    = NSMutableAttributedString(string:timeString, attributes:timeAtt)
        networkString.appendAttributedString(statusString)
        return networkString
    }
    
    func updateTime(coverageTime:CoverageTime) {
        liveLabel?.attributedText           = createAttributedClockText("\(coverageTime.minutes):\(coverageTime.seconds):\(coverageTime.milliseconds)", color: UIColor.carmineRed())
    }

}
