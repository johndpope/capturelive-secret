//
//  DottedLineView.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/1/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class DottedLineView: UIView {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.whiteSmoke()
    }
    
    override public func drawRect(rect: CGRect) {
        
        let width                   = CGRectGetWidth(self.bounds)
        let height                  = CGRectGetHeight(self.bounds)
 
        let path                    = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(width, height))
        
        let shapeLayer              = CAShapeLayer()
        shapeLayer.name             = "DashedBorder"
        shapeLayer.strokeColor      = UIColor.blackColor().CGColor
        shapeLayer.fillColor        = UIColor.clearColor().CGColor
        shapeLayer.lineDashPattern  = [1, 1]
        shapeLayer.path             = path.CGPath
        shapeLayer.lineWidth        = 1.0

        layer.addSublayer(shapeLayer)
    }
    
}
