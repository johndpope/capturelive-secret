//
//  CMCheckbox.swift
//  Current
//
//  Created by Scott Jones on 1/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

public class CMCheckbox: UIControl {

    var boxView:UIView!
    var checkImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setUpElements()
    }
    
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setUpElements()
    }
   
    deinit {
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let w                               = self.frame.width * 0.66
        let h                               = self.frame.height * 0.66
        let x                               = (self.frame.width * 0.5 ) - (w * 0.5)
        let y                               = (self.frame.height * 0.5 ) - (h * 0.5)
        let scaleH                          = (h * 0.2)
        let scaleW                          = (w * 0.2)
        self.boxView.frame                  = CGRectMake(x, y, w, h)
        self.checkImageView.frame           = CGRectMake(x, y, w + scaleW, h + scaleH)
        self.checkImageView.center          = CGPoint(x: boxView.center.x + scaleW, y: boxView.center.y - scaleH)
    }

    func setUpElements() {
        self.backgroundColor                = UIColor.clearColor()
        
        self.boxView                        = UIView()
        self.boxView.backgroundColor        = UIColor.whiteColor()
        self.boxView.layer.borderColor      = UIColor.grayColor().CGColor
        self.boxView.layer.borderWidth      = 1
        self.boxView.layer.cornerRadius     = 2
        self.boxView.userInteractionEnabled = false
        self.addSubview(self.boxView)
        
        self.checkImageView                 = UIImageView(image:UIImage(named:"icon_serviceenabled"))
        self.checkImageView.contentMode     = .Center
        self.checkImageView.backgroundColor = UIColor.clearColor()
        self.checkImageView.userInteractionEnabled = false
        self.addSubview(self.checkImageView)
       
        self.selected                       = false
        self.layoutIfNeeded()
    }
    
    override public var selected: Bool {
        willSet(newValue) {
            self.checkImageView.hidden      = !newValue
        }
    }
    
}
