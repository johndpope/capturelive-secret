//
//  CMArcProgressView.swift
//  Current
//
//  Created by Scott Jones on 9/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

func degreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func radiansToDegrees (value:Double) -> Double {
    return value * 180.0 / M_PI
}

public class CMArcProgressView: UIView {

    private var _strokeColor                = UIColor.greenColor()
    private var _dotColor                   = UIColor.whiteColor()
    private var _startAngle:CGFloat         = 0
    private var _endAngle:CGFloat           = 0
    private var _stroke:CGFloat             = 1
    private var _radius:CGFloat             = 100
    private var _total:UInt                 = 40
    private var _buffer:CGFloat             = 0
    private var _interval:CGFloat           = 0
    private var _adjustedRadius:CGFloat     = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public var strokeColor:UIColor {
        get {
            return _strokeColor
        }
        set {
            _strokeColor                    = newValue
        }
    }
    
    public var dotColor:UIColor {
        get {
            return _dotColor
        }
        set {
            _dotColor                       = newValue
        }
    }
    
    public var strokeWidth:CGFloat {
        get {
            return _stroke
        }
        set {
            _stroke                         = newValue
        }
    }
    
    public var radius:CGFloat {
        get {
            return _radius
        }
        set {
            _radius                         = newValue
        }
    }
    
    public var total:UInt {
        get {
            return _total
        }
        set {
            _total                          = newValue
        }
    }
    
    public var buffer:CGFloat {
        get {
            return _buffer
        }
        set {
            _buffer                         = newValue
        }
    }
    
    private func createAdjustedRadius()->CGFloat {
        return _radius - _stroke
    }
    
    private func createInterval()->CGFloat {
        return CGFloat(M_PI * 2) / CGFloat(_total)
    }

    public func setupProperties() {
    }
    
    public func setupInterval() {
    }
    
    private func setup() {
        self.setupInterval()
        
        _adjustedRadius             = createAdjustedRadius()
        _interval                   = createInterval()

        _startAngle                 = CGFloat(degreesToRadians(0.0)) + _interval * _buffer
        _endAngle                   = CGFloat(degreesToRadians(360.0)) - _interval * _buffer
        
        self.transform              = CGAffineTransformMakeRotation(-CGFloat(M_PI_2));
        self.setupProperties() // set colors, radius, strokes
    }
    
    public func progress(progress:Double) {
        let e                       = CGFloat(degreesToRadians(360.0)) - (_interval * (_buffer * 2))
        _endAngle                   = CGFloat(e * CGFloat(progress)) + _startAngle
        self.setNeedsDisplay()
    }
    
    func dotDraw(i:UInt, context:CGContext?, startX:CGFloat, startY:CGFloat) {
        switch i {
        case _ where i == 0, _ where i < UInt(self.buffer), _ where i > (total - UInt(self.buffer)): break
        default:
            CGContextSetFillColorWithColor(context, _dotColor.CGColor)
            CGContextFillEllipseInRect(context, CGRectMake(startX - (_stroke * 0.5), startY - (_stroke * 0.5),  _stroke, _stroke));
        }
    }
    
    override public func drawRect(rect: CGRect) {
        let context                 = UIGraphicsGetCurrentContext()
        var angle:CGFloat           = 0
        
        let centerX:CGFloat         = rect.size.width * 0.5
        let centerY:CGFloat         = rect.size.width * 0.5
        
        var startX:CGFloat          = 0.0
        var startY:CGFloat          = 0.0
        
        for i in 0..<_total {
            startX                  = centerX + cos(angle) * (centerX - (strokeWidth * 0.5))
            startY                  = centerY + sin(angle) * (centerX - (strokeWidth * 0.5))
            self.dotDraw(i, context:context, startX: startX, startY: startY)
            angle                   = angle + _interval
        }
        
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
        CGContextSetLineCap(context, CGLineCap.Round);
        CGContextSetLineJoin(context, CGLineJoin.Round);
        CGContextSetAllowsAntialiasing(context, true);
        
        CGContextSetLineWidth(context, _stroke);
        CGContextSetShouldAntialias(context, true);
        CGContextSetMiterLimit(context, 2);
        CGContextAddArc(context, centerX, centerY, (centerX - (strokeWidth * 0.5)), CGFloat(_startAngle), CGFloat(_endAngle), 0);
        CGContextStrokePath(context);
    }
    
}
