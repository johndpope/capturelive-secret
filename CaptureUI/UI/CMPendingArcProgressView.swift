//
//  CMPendingArcView.swift
//  Current
//
//  Created by Scott Jones on 9/25/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMPendingArcProgressView: CMArcProgressView {

    override func setupProperties() {
        self.radius                 = self.frame.size.width * 0.5
        self.backgroundColor        = UIColor.clearColor()
        self.strokeColor            = UIColor.yellowCurrent()
        self.dotColor               = UIColor.greyIronCurrent()

        self.strokeWidth            = 5
        self.total                  = 40
        self.buffer                 = 0
    }
    
    func setForDenied() {
        self.backgroundColor        = UIColor.clearColor()
        self.strokeColor            = UIColor.greyIronCurrent()
        progress(Double(1))
    }

    func setForAccepted() {
        self.backgroundColor        = UIColor.clearColor()
        self.strokeColor            = UIColor.greenConfirmCurrent()
        progress(Double(1))
    }
    
}
