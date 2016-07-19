//
//  CMUploadingArcProgressView.swift
//  Current-Tools
//
//  Created by Scott Jones on 9/11/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMUploadingArcProgressView: CMArcProgressView {
  
    public override func setupProperties() {
        self.backgroundColor        = UIColor.clearColor()
        self.strokeColor            = UIColor.greenCurrent()
        self.dotColor               = UIColor.greyAluminumCurrent()
    }
    
    public override func setupInterval() {
        self.strokeWidth            = frame.size.width / 80
        self.radius                 = frame.size.width * 0.5
        
        self.total                  = 50
        self.buffer                 = 2
    }

    public func showComplete() {
        self.total                  = 50
        self.buffer                 = 0
        
        progress(1)
    }

}
