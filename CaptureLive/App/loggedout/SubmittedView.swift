//
//  SubmittedView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class SubmittedView: UIView {

    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var titleLabel:UILabel?

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.layer.cornerRadius = (frame.size.width * 0.25) / 2
        imageView?.clipsToBounds    = true
    }
    
    func animateIn(closure:()->()) {
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            self?.imageView?.alpha  = 1
            
            }) { finished in
                UIView.animateWithDuration(0.5, animations: { [weak self] in
                    self?.titleLabel?.alpha  = 1
                    
                }) { finished in
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        closure()
                    }
                    
                }
        }
    }
    
}

extension SubmittedView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor             = UIColor.mountainMeadow()
        
        let navText                 = NSLocalizedString("SUBMITTED", comment: "SubmittedView : navTitleLabel : text")
        titleLabel?.text            = navText
        titleLabel?.font            = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        titleLabel?.textColor       = UIColor.whiteColor()
        
        imageView?.image            = UIImage(named:"icon_complete")
        
        titleLabel?.alpha           = 0
        imageView?.alpha            = 0
    }
}

