//
//  YouveArrivedView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class YouveArrivedView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?
    
    func showYouveArrivedAttributtedText() {
        let topText                     = NSLocalizedString("YOU'VE ARRIVED", comment: "Youve arrived : toptext")
        let bottomText                  = NSLocalizedString("You are now able to live stream.", comment: "Youve arrived : bottomtext")
        let topAtt                      = [
            NSFontAttributeName            : UIFont.proxima(.Bold, size: FontSizes.s15)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let topAttString                = NSMutableAttributedString(string:"\(topText)\n", attributes: topAtt )
        let bottomAtt                   = [
            NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.dimGray()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let bottomAttString             = NSMutableAttributedString(string:bottomText, attributes:bottomAtt )
        topAttString.appendAttributedString(bottomAttString)
        titleLabel?.attributedText      = topAttString
    }
   
    func showGetToTheLocaton(milesAway:Double) {
        let topText                     = NSLocalizedString("GET TO THE LOCATION", comment: "Get to the Location : toptext")
        let bottomText                  = NSLocalizedString("You are %.f miles away.", comment: "Get to the Location : bottomtext")
        let topAtt                      = [
            NSFontAttributeName            : UIFont.proxima(.Bold, size: FontSizes.s15)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let topAttString                = NSMutableAttributedString(string:"\(topText)\n", attributes: topAtt )
        let bottomAtt                   = [
            NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.dimGray()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let bottomAttString             = NSMutableAttributedString(string:String(NSString(format:bottomText, milesAway)), attributes:bottomAtt )
        topAttString.appendAttributedString(bottomAttString)
        titleLabel?.attributedText      = topAttString
    }
    
}

extension YouveArrivedView : CMViewProtocol {
    
    func didLoad() {
        heightConstraint?.constant      = ScreenSize.SCREEN_HEIGHT * 0.132

        titleLabel?.numberOfLines       = 0
    }
    
}