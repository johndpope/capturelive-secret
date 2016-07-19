//
//  CMModalReminderView.swift
//  Current
//
//  Created by Scott Jones on 3/31/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class ModalReminder1HourView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var eventNameLabel:UILabel?
    @IBOutlet weak var eventSublabel:UILabel?
    @IBOutlet weak var takeMeThereButton:UIButton?
 
    func populate(event event:EventViewModel) {
        self.eventNameLabel?.text               = event.titleString
     }

}

extension ModalReminder1HourView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                    = UIColor.whiteCurrent()
    
        let titleLabelText                      = NSLocalizedString("Get ready!\nit's almost showtime.", comment: "CMModalReminderView : titleLabel : text")
        titleLabel?.textColor                   = UIColor.greenCurrent()
        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = UIFont.comfortaa(.Regular, size:38)
        titleLabel?.adjustsFontSizeToFitWidth   = true
        titleLabel?.text                        = titleLabelText
       
        eventNameLabel?.textColor               = UIColor.blackCurrent()
        eventNameLabel?.numberOfLines           = 0
        eventNameLabel?.font                    = UIFont.comfortaa(.Regular, size:18)

        let titleSubLabelText                   = NSLocalizedString("this job is about to start", comment: "CMModalReminderView : eventSublabel : text")
        eventSublabel?.textColor                = UIColor.greyCurrent()
        eventSublabel?.numberOfLines            = 0
        eventSublabel?.font                     = UIFont.comfortaa(.Regular, size:14)
        eventSublabel?.text                     = titleSubLabelText
        
        let startsNow                           = NSLocalizedString("Start Job Now", comment: "CMModalReminderView : viewJobButton : text")
        takeMeThereButton?.backgroundColor      = UIColor.greenCurrent()
        takeMeThereButton?.setTitle(startsNow, forState: UIControlState.Normal)
        takeMeThereButton?.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Normal)
    }

}