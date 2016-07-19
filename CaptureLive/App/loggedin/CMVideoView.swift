//
//  CMVideoView.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 5/14/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AVFoundation

func DEGREES(radians:Double)->Double {
    return radians * Double(180.0 / M_PI)
}
func RADIANS(degrees:Double)->Double {
    return degrees / 180.0 * M_PI
}

public class CMVideoView: UIView {
    
    private var lastTransform :CGAffineTransform?
    
    var w:CGFloat {
        get {
            return max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        }
    }
    var h:CGFloat {
        get {
            return min(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        }
    }

    var containerView:UIView!
    public var previewLayer:AVCaptureVideoPreviewLayer!

    public init(previewLayer:AVCaptureVideoPreviewLayer) {
        super.init(frame:UIScreen.mainScreen().bounds)
        self.layer.masksToBounds                = true
        containerView                  = UIView(frame:UIScreen.mainScreen().bounds)
        containerView.layer.masksToBounds = true
        self.previewLayer                   = previewLayer
        self.previewLayer.frame             = self.containerView.frame
        self.previewLayer.masksToBounds     = true
        
        let layer                           = self.containerView.layer
        layer.masksToBounds                 = true
        
        layer.insertSublayer(self.previewLayer, atIndex:0)
        addSubview(containerView)
        containerView.frame                 = CGRect(x: 0.0, y: 0.0, width:h, height:w)
        self.previewLayer.frame             = CGRect(x: 0.0, y: 0.0, width:h, height:w)
        backgroundColor                     = UIColor.blackColor()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setOrientation() {
        containerView.transform             = CGAffineTransformMakeRotation(CGFloat(RADIANS(0.0)))
        switch UIDevice.currentDevice().orientation {
        case .LandscapeLeft, .FaceUp:
            containerView.transform         = CGAffineTransformMakeRotation(CGFloat(RADIANS(-90.0)))
        case .LandscapeRight, .FaceDown:
            containerView.transform         = CGAffineTransformMakeRotation(CGFloat(RADIANS(90.0)))
        default:
            containerView.transform         = lastTransform ?? containerView.transform
        }
        lastTransform                       = containerView.transform
        containerView.center                = center
    }
    
}
