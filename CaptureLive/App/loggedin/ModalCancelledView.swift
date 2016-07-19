//
//  ModalCanceledView.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ModalCancelledView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var eventNameLabel:UILabel?
    @IBOutlet weak var eventSublabel:UILabel?
    @IBOutlet weak var dismissButton:UIButton?
    
    func populate(event event:EventViewModel) {
        self.eventNameLabel?.text               = event.titleString
    }
    
}

extension ModalCancelledView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                    = UIColor.whiteCurrent()
        
        let titleLabelText                      = NSLocalizedString("This job has been cancelled", comment: "ModalCancelledView : titleLabel : text")
        titleLabel?.textColor                   = UIColor.carmineRed()
        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = UIFont.comfortaa(.Regular, size:38)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.text                        = titleLabelText
        
        eventNameLabel?.textColor               = UIColor.blackCurrent()
        eventNameLabel?.numberOfLines           = 0
        eventNameLabel?.font                    = UIFont.comfortaa(.Regular, size:18)
        
        let titleSubLabelText                   = NSLocalizedString("Sorry, the publisher has backed out.", comment: "ModalCancelledView : eventSublabel : text")
        eventSublabel?.textColor                = UIColor.greyCurrent()
        eventSublabel?.numberOfLines            = 0
        eventSublabel?.font                     = UIFont.comfortaa(.Regular, size:14)
        eventSublabel?.text                     = titleSubLabelText
        
        let dismissText                         = NSLocalizedString("Dismiss", comment: "ModalCancelledView : viewJobButton : text")
        dismissButton?.backgroundColor          = UIColor.carmineRed()
        dismissButton?.setTitle(dismissText, forState: UIControlState.Normal)
        dismissButton?.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Normal)
    }
}