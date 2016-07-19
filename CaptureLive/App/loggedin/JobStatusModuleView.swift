//
//  JobStatusModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobStatusModuleView: UIView {

    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var titleLabel:UILabel?
    
    func showApplied() {
        let titleText               = NSLocalizedString("YOU'VE APPLIED", comment: "JobStatusModuleView : youveApplied : text")
        titleLabel?.text            = titleText
        titleLabel?.textColor       = UIColor.bistre()
        imageView?.image            = UIImage(named: "icon_youapplied")
        backgroundColor             = UIColor.whiteColor()
    }
    
    func showExpired() {
        let titleText               = NSLocalizedString("JOB HAS EXPIRED", comment: "JobStatusModuleView : expired : text")
        titleLabel?.text            = titleText
        titleLabel?.textColor       = UIColor.bistre()
        imageView?.image            = UIImage(named: "icon_jobexpired")
        backgroundColor             = UIColor.whiteColor()
    }
    
    func showHired() {
        let titleText               = NSLocalizedString("YOU'RE HIRED", comment: "JobStatusModuleView : youreHired : text")
        titleLabel?.text            = titleText
        titleLabel?.textColor       = UIColor.whiteColor()
        imageView?.image            = nil
        backgroundColor             = UIColor.mountainMeadow()
    }
    
}

extension JobStatusModuleView : CMViewProtocol {

    func didLoad() {
        layer.masksToBounds         = false
        layer.cornerRadius          = 2
        layer.shadowColor           = UIColor.bistre().CGColor
        layer.shadowOpacity         = 0.5
        layer.shadowOffset          = CGSizeMake(0, 0.5)
        layer.shadowRadius          = 0.8
        
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s15)
        titleLabel?.textColor       = UIColor.bistre()
        
        showApplied()
    }
    
}