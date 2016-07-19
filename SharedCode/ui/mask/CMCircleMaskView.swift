//
//  CMCircleMask.swift
//  Current
//
//  Created by Scott Jones on 11/30/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMCircleMaskView: UIView {

    var donutLayer                      = CALayer()
   
    public var radius:CGFloat                  = 0
    
    public var color:UIColor {
        get {
            return UIColor(CGColor:self.donutLayer.borderColor!)
        }
    
        set  {
            self.donutLayer.borderColor = newValue.CGColor
        }
    }
    
    public var isClosed:Bool {
        get {
            return donutLayer.bounds.size.width == (self.frame.size.height * 3)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor            = UIColor.clearColor()
        self.layer.addSublayer(donutLayer)
        donutLayer.backgroundColor      = UIColor.clearColor().CGColor
        donutLayer.borderColor          = UIColor.whiteColor().CGColor
        donutLayer.masksToBounds        = true
        
        self.radius                     = UIScreen.mainScreen().bounds.width * 0.75
        
        self.reCenter(self.center)
        
        
        CATransaction.setDisableActions(true)
        let bwidth:CGFloat              = self.frame.size.height * 1.5
        let size:CGFloat                = 0.0
        self.donutLayer.borderWidth     = bwidth
        self.donutLayer.bounds          = CGRectMake(-bwidth, -bwidth, size + (bwidth * 2), size + (bwidth * 2))
        let cr                          = (size + (bwidth * 2)) / 2.0
        self.donutLayer.cornerRadius    = cr
        CATransaction.setDisableActions(false)
    }

    public func reCenter(point:CGPoint) {
        CATransaction.setDisableActions(true)
        var cframe                      = donutLayer.frame
        cframe.origin.x                 = point.x - (cframe.size.width * 0.5)
        cframe.origin.y                 = point.y - (cframe.size.height * 0.5)
        donutLayer.frame                = cframe
        CATransaction.setDisableActions(false)
    }

    public func resize(size:CGFloat) {
        let bwidth:CGFloat              = self.frame.size.height
        donutLayer.bounds               = CGRectMake(-bwidth, -bwidth, size + (bwidth * 2), size + (bwidth * 2))
        donutLayer.cornerRadius         = (size + (bwidth * 2)) / 2.0
        donutLayer.borderWidth          = bwidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reveal() {
        let bwidth:CGFloat              = self.frame.size.height
        let size                        = self.radius
        animate(bwidth, size: size)
    }
    
    public func unreveal() {
        let bwidth:CGFloat              = self.frame.size.height * 1.5
        let size:CGFloat                = 0.0
        animate(bwidth, size: size)
    }

    public func animate(bwidth:CGFloat, size:CGFloat) {
        let border:CABasicAnimation     = CASpringAnimation(keyPath:"borderWidth")
        border.fromValue                = donutLayer.borderWidth
        border.toValue                  = bwidth
        self.donutLayer.borderWidth     = bwidth
        
        let bounds                      = CASpringAnimation(keyPath: "bounds")
        bounds.fromValue                = NSValue(CGRect: self.donutLayer.bounds)
        bounds.toValue                  = NSValue(CGRect:CGRectMake(-bwidth, -bwidth, size + (bwidth * 2), size + (bwidth * 2)))
        self.donutLayer.bounds          = CGRectMake(-bwidth, -bwidth, size + (bwidth * 2), size + (bwidth * 2))
        
        let cr                          = (size + (bwidth * 2)) / 2.0
        let cornerRadius                = CASpringAnimation(keyPath: "cornerRadius")
        cornerRadius.fromValue          = donutLayer.cornerRadius
        cornerRadius.toValue            = cr
        self.donutLayer.cornerRadius    = cr
        
        let both:CAAnimationGroup       = CAAnimationGroup()
        both.duration                   = 1.0
        both.animations                 = [border, bounds, cornerRadius]
        both.timingFunction             = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.donutLayer.addAnimation(both, forKey: nil)
    }
    
    public func close() {
        CATransaction.setDisableActions(true)
        self.resize(0)
        CATransaction.setDisableActions(false)
    }
    
    public func open() {
        CATransaction.setDisableActions(true)
        self.resize(self.radius)
        CATransaction.setDisableActions(false)
    }

    
}
