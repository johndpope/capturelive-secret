//
//  JobInfoModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobInfoModuleView: UIView {

    @IBOutlet weak var directionsButton:ImageTitleButton?
    @IBOutlet weak var jobPaysButton:ImageTitleButton?
    @IBOutlet weak var infoButton:ImageTitleButton?
    @IBOutlet weak var divider0:UIView?
    @IBOutlet weak var divider1:UIView?
    
}


extension JobInfoModuleView : CMViewProtocol {
    
    func didLoad() {
        layer.masksToBounds                 = false
        layer.cornerRadius                  = 2
        
        divider0?.backgroundColor           = UIColor.munsell()
        divider1?.backgroundColor           = UIColor.munsell()
        
        let directionsText                  = NSLocalizedString("DIRECTIONS", comment: "JobInfoModuleView : directionsButton: text")
        directionsButton?.setText("icon_directions", titleString:directionsText, forState:.Normal)
        directionsButton?.titleLabel?.font     = UIFont.proxima(.Bold, size: FontSizes.s10)
 
        let paysText                        = NSLocalizedString("JOB PAYS", comment: "JobInfoModuleView : jobPaysButton: text")
        jobPaysButton?.setText("icon_jobpays_light", titleString:paysText, forState:.Normal)
        jobPaysButton?.titleLabel?.font     = UIFont.proxima(.Bold, size: FontSizes.s10)
       
        let infoText                        = NSLocalizedString("JOB INFO", comment: "JobInfoModuleView : infoButton: text")
        infoButton?.setText("icon_jobinfo_light", titleString:infoText, forState:.Normal)
        infoButton?.titleLabel?.font        = UIFont.proxima(.Bold, size: FontSizes.s10)
    }
    
}
