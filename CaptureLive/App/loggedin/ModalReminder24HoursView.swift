//
//  ModalReminder24HourView.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class ModalReminder24HoursView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var eventNameLabel:UILabel?
    @IBOutlet weak var eventSublabel:UILabel?
    @IBOutlet weak var takeMeThereButton:UIButton?
    
    func populate(event event:EventViewModel) {
        self.eventNameLabel?.text               = event.titleString
    }
    
}

extension ModalReminder24HoursView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                    = UIColor.whiteCurrent()
        
        let titleLabelText                      = NSLocalizedString("Reminder!\nYou are on tomorrow.", comment: "CMModalReminderView : titleLabel : text")
        titleLabel?.textColor                   = UIColor.greenCurrent()
        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = UIFont.comfortaa(.Regular, size:38)
        titleLabel?.adjustsFontSizeToFitWidth   = true
        titleLabel?.text                        = titleLabelText
        
        eventNameLabel?.textColor               = UIColor.blackCurrent()
        eventNameLabel?.numberOfLines           = 0
        eventNameLabel?.font                    = UIFont.comfortaa(.Regular, size:18)
        
        let titleSubLabelText                   = NSLocalizedString("this job is will start tomorrow", comment: "CMModalReminderView : eventSublabel : text")
        eventSublabel?.textColor                = UIColor.greyCurrent()
        eventSublabel?.numberOfLines            = 0
        eventSublabel?.font                     = UIFont.comfortaa(.Regular, size:14)
        eventSublabel?.text                     = titleSubLabelText
        
        let startsNow                           = NSLocalizedString("See you there", comment: "CMModalReminderView : viewJobButton : text")
        takeMeThereButton?.backgroundColor      = UIColor.greenCurrent()
        takeMeThereButton?.setTitle(startsNow, forState: UIControlState.Normal)
        takeMeThereButton?.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Normal)
    }
    
}