//
//  CMExpandingButton.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

public final class CMExpandingButton: UIControl {
    
    // MARK: Properties
    var Size:CGFloat                                = 60.0
    let SizeHalf:CGFloat                            = 30.0
    let SizeQ:CGFloat                               = 15.0
    let Alpha:CGFloat                               = 0.2
    let LabelOrigX:CGFloat                          = 0.8
    let LabelOrigY:CGFloat                          = 0.9
    let LabelHeight:CGFloat                         = 42.0
    
    var imageView:UIImageView!
    var titleImage:UIImage!
    var labels:[UILabel]?
    var backgroundLayer:CALayer?
    var maxWidth:CGFloat?
    var closeTimer:NSTimer?
    var selectedItem:Int?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Init
    init(point:CGPoint, titleImageName:String, names:[String], selected:Int ) {
        super.init(frame:CGRectMake(point.x, point.y, self.SizeHalf, self.SizeHalf))
        self.setupBasic(titleImageName)
        self.setupSelection(names, selected: selected)
        self.addTarget(self, action:#selector(CMExpandingButton.selectionTouchOccured(_:event:)), forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    init(point:CGPoint, titleImageName:String) {
        super.init(frame:CGRectMake(point.x, point.y, self.SizeHalf, self.SizeHalf))
        self.setupBasic(titleImageName)
        self.addTarget(self, action:#selector(CMExpandingButton.toggleTouchOccured(_:event:)), forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    // MARK: Setup
    private func setupBasic(titleImageName:String) {
        self.backgroundLayer                        = self.layer
        self.backgroundLayer?.backgroundColor       = UIColor(red: 0, green: 0, blue: 0, alpha: Alpha).CGColor
        self.backgroundLayer?.borderColor           = UIColor(white: 1.0, alpha: Alpha).CGColor
        self.backgroundLayer?.cornerRadius          = 15.0
        self.backgroundLayer?.borderWidth           = 0.0
        
        self.titleImage                             = UIImage(named:titleImageName)
        
        self.imageView                              = UIImageView(image:self.titleImage)
        self.imageView.frame                        = CGRectMake(-self.SizeQ, -self.SizeQ, self.Size, self.Size)
        self.addSubview(self.imageView)
    }
    
    private func setupSelection(names:[String], selected:Int) {
        self.labels = [];
        for name:String in names {
            let l                                   = UILabel(frame:CGRectMake(self.SizeHalf-6, 0, self.SizeQ, self.SizeHalf))
            l.text                                  = name
            l.font                                  = UIFont.systemFontOfSize(16.0)
            l.textColor                             = UIColor.whiteColor()
            l.backgroundColor                       = UIColor.clearColor()
            l.textAlignment                         = NSTextAlignment.Center
            l.hidden                                = true
            
            if name != names.first {
                let border                          = CALayer()
                border.frame                        = CGRectMake(0, 0, 1, l.frame.height);
                border.backgroundColor              = UIColor(white: 1.0, alpha: Alpha).CGColor
                l.layer.addSublayer(border)
            }
            
            self.labels?.append(l)
            self.addSubview(l)
        }
        
        self.setSelectedItem(selected)
    }
    
    // MARK: Touch Handlers
    func toggleTouchOccured(sender:AnyObject, event:UIEvent) {
        self.addTint();
        self.closeTimer                             = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector:#selector(CMExpandingButton.removeTint), userInfo:nil, repeats:false)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func selectionTouchOccured(sender:AnyObject, event:UIEvent) {
        if self.labels![0].hidden == true {
            self.expand()
            self.closeTimer                         = NSTimer.scheduledTimerWithTimeInterval(3.0, target:self, selector:#selector(CMExpandingButton.contract), userInfo:nil, repeats:false)
        } else {
            if self.touchInside(event) {
                self.contract()
            }
        }
    }
    
    // MARK: Private
    func addTint() {
        self.imageView.image                        = self.titleImage.getTinted(UIColor(white:0.0, alpha:0.5))
    }
    
    func removeTint() {
        self.imageView.image                        = self.titleImage
    }
    
    private func expand() {
        for label:UILabel in self.labels! {
            label.hidden                            = false;
            label.alpha                             = 0.0
        }
        var maxSize                                 = self.labels![0].frame.origin.x
        
        UIView.animateWithDuration(0.2, animations: { () in
            
            for label:UILabel in self.labels! {
                let string                          = label.text! as NSString
                let size                            = string.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(16.0)])
                label.frame.size.width              = size.width + 30
                label.frame.origin.x                = maxSize
                maxSize                             += label.frame.size.width
                label.alpha                         = 1.0
            }
            self.backgroundLayer?.frame.size.width  = maxSize + 4
            }) { (fin:Bool) in
        }
    }
    
    func contract() {
        self.closeTimer?.invalidate()
        self.closeTimer                             = nil
        
        UIView.animateWithDuration(0.2, animations: { () in
            
            for label:UILabel in self.labels! {
                label.frame.origin.x                = self.SizeHalf-6
                label.alpha                         = -1.0
            }
            self.backgroundLayer?.frame.size.width  = self.SizeHalf
            }) { (fin:Bool) in
                
                for label:UILabel in self.labels! {
                    label.hidden                        = true;
                }
        }
    }
    
    private func setSelectedItem(index:Int) {
        if index < self.labels?.count {
            self.selectedItem                       = index
            for label:UILabel in self.labels! {
                label.font                          = UIFont.systemFontOfSize(16.0)
                label.textColor                     = UIColor.whiteColor()
            }
            
            let selectLab:UILabel                   = self.labels![index]
            selectLab.textColor                     = UIColor.blueColor()
            selectLab.font                          = UIFont.boldSystemFontOfSize(16.0)
        }
    }
    
    private func touchInside(event:UIEvent)->Bool {
        var inside                                  = false
        var choosen                                 = 0
        var index                                   = 0
        var point:CGPoint?
        let touch = event.allTouches()!.first as UITouch!
        for label:UILabel in self.labels! {
            point                                   = touch.locationInView(label)
            if label.pointInside(point!, withEvent: event) {
                inside                              = true
                choosen                             = index
            }
            index += 1
        }
        if inside != false {
            self.setSelectedItem(choosen)
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
        
        point                                       = touch.locationInView(self.imageView)
        if self.imageView.pointInside(point!, withEvent: event) {
            inside                                  = true
        }
        
        return inside
    }
    
}
