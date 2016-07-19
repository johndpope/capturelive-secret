//
//  CMTimedArcProgressView.swift
//  Current
//
//  Created by Scott Jones on 9/11/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMTimedArcProgressView: CMArcProgressView {
    
    public override func setupProperties() {
        self.radius                 = self.frame.size.width * 0.5
        self.backgroundColor        = UIColor.clearColor()
        self.strokeColor            = UIColor.whiteColor()
        self.dotColor               = UIColor.whiteColor()

        self.strokeWidth            = 5
        self.total                  = 40
        self.buffer                 = 0
    }
    
    public override func setupInterval() {
        
    }

}
