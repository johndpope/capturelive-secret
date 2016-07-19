//
//  JobCompletedAlertView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobCompletedAlertView: UIView {
    
    @IBOutlet weak var greenLabel:UILabel?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var viewJobReceiptButton:CMPrimaryButton?
    
    func hide() {
        hidden = true
        transform                           = CGAffineTransformMakeScale(0.0, 0.0)
    }
    
    func show() {
        hidden = false
        transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.transform = CGAffineTransformMakeScale(1.07, 1.07)
            
        }) { (fin:Bool) -> Void in
            
            UIView.animateWithDuration(1.0/15.0, animations: { [weak self] in
                self?.transform = CGAffineTransformMakeScale(0.96, 0.96)
                
            }) { (fin:Bool) -> Void in
                
                UIView.animateWithDuration(1.0/7.5, animations: { [weak self] in
                    self?.transform = CGAffineTransformIdentity
                    
                }) { (fin:Bool) -> Void in
                    
                }
            }
        }
    }

}

extension JobCompletedAlertView : CMViewProtocol {
    
    func didLoad() {
        greenLabel?.backgroundColor         = UIColor.mountainMeadow()
        greenLabel?.textColor               = UIColor.whiteColor()
        greenLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s14)
        let jobCompTxt                      = NSLocalizedString("Job Completed!", comment: "JobCompletedAlertView : greenLabel : text")
        greenLabel?.text                    = jobCompTxt
        
        
        titleLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s14)
        titleLabel?.textColor               = UIColor.dimGray()
        let titleTxt                        = NSLocalizedString("Upload Successful", comment: "JobCompletedAlertView : titleLabel : text")
        titleLabel?.text                    = titleTxt
 
        imageView?.image                    = UIImage(named: "icon_youapplied")
        
        let buttonTxt                       = NSLocalizedString("VIEW JOB CONFIRMATION", comment: "JobCompletedAlertView : viewJobReceiptButton : text")
        viewJobReceiptButton?.setTitle(buttonTxt, forState: .Normal)
        
        hide()
    }
    
}