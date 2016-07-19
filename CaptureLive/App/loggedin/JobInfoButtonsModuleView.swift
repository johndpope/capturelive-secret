//
//  JobDetailsModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/14/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobInfoButtonsModuleView: UIView {
    
    @IBOutlet weak var jobDetailsButton:ImageTitleButton?
    @IBOutlet weak var jobPaysButton:ImageTitleButton?
    @IBOutlet weak var infoButton:ImageTitleButton?
    @IBOutlet weak var divider0:UIView?
    @IBOutlet weak var divider1:UIView?
    
}

extension JobInfoButtonsModuleView : CMViewProtocol {
    
    func didLoad() {
        layer.masksToBounds                 = false
        layer.cornerRadius                  = 2
       
        backgroundColor                     = UIColor.isabelline()
        
        divider0?.backgroundColor           = UIColor.silver()
        divider1?.backgroundColor           = UIColor.silver()
        
        let directionsText                  = NSLocalizedString("JOB DETAILS", comment: "JobDetailsModuleView : jobDetailsButton: text")
        jobDetailsButton?.setText("icon_jobdetails", titleString:directionsText, forState:.Normal)
        jobDetailsButton?.backgroundColor   = UIColor.isabelline()
        jobDetailsButton?.titleLabel?.font  = UIFont.proxima(.Bold, size: FontSizes.s10)
        
        let paysText                        = NSLocalizedString("JOB PAYS", comment: "JobDetailsModuleView : jobPaysButton: text")
        jobPaysButton?.setText("icon_jobpays_dark", titleString:paysText, forState:.Normal)
        jobPaysButton?.backgroundColor      = UIColor.isabelline()
        jobPaysButton?.titleLabel?.font     = UIFont.proxima(.Bold, size: FontSizes.s10)
 
        let infoText                        = NSLocalizedString("JOB INFO", comment: "JobDetailsModuleView : infoButton: text")
        infoButton?.setText("icon_jobinfo_dark", titleString:infoText, forState:.Normal)
        infoButton?.backgroundColor         = UIColor.isabelline()
        infoButton?.titleLabel?.font        = UIFont.proxima(.Bold, size: FontSizes.s10)
    }
    
}