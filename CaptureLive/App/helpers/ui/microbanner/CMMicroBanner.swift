//
//  CMMicroBanner.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 7/7/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
typealias Completed = ()->()

public enum CMMicroBannerStyle {
    case Default
    case Error
    case Arrived
    case GPS
}

public class CMMicroBanner: UIView {

    let label                                   = UILabel()
    var font                                    = UIFont.sourceSansPro(.Regular, size:13)
    private var _didDismiss:Completed?
    private var formattedTextSize:CGSize!
    private var message:String!
    private var newMessage:String?
    private var bannerStyle:CMMicroBannerStyle!
    private var timer:NSTimer?
    public weak var topView:UIView?
    var timeout:NSTimeInterval                  = 4.5
    var origin:CGPoint                          = CGPointMake(0, 64)
    var hBuffer:CGFloat                         = 8
    
    public static func errorBanner()->CMMicroBanner {
        let m                                   = CMMicroBanner(style:.Error)
        return m
    }
    
    public static func gpsBanner()->CMMicroBanner {
        let m                                   = CMMicroBanner(style:.GPS)
        m.timeout                               = NSTimeInterval(DISPATCH_TIME_FOREVER)
        m.origin                                = CGPointMake(0, 0)
        return m
    }
   
    public static func arrivedBanner()->CMMicroBanner {
        let m                                   = CMMicroBanner(style:.Arrived)
        m.timeout                               = NSTimeInterval(5)
        m.origin                                = CGPointMake(0, 100)
        m.font                                  = UIFont.sourceSansPro(.Regular, size:18)
        m.hBuffer                               = 14
        return m
    }
    
    public var isOnScreen : Bool {
         return !(self.label.frame.origin.y > self.origin.y)
    }
    
    public var style : CMMicroBannerStyle {
        get {
            return self.bannerStyle
        }
        set {
            self.bannerStyle                    = newValue
        }
    }
    
    public init(style:CMMicroBannerStyle) {
        self.formattedTextSize                  = CGSizeMake(0, 0)
        super.init(frame:CGRect(origin:CGPointMake(0, 64), size:self.formattedTextSize))
        self.bannerStyle                        = style
    }
    
    public func message(message:String) {
        let b                                   = UIScreen.mainScreen().bounds
        self.formattedTextSize                  = font.sizeOfString(message, constrainedToWidth:Double(b.size.width))
        self.formattedTextSize.width            = b.size.width
        self.formattedTextSize.height           = self.formattedTextSize.height + self.hBuffer
        self.message                            = message
        self.frame                              = CGRect(origin:CGPointMake(0, self.origin.y), size:self.formattedTextSize)
        createSubviews()
        self.label.frame                        = self.hideLabelFrame
        self.bannerStyle                        = style
    }
    
    private func createSubviews() {
        self.label.font                         = font
        self.addSubview(self.label)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds                      = true
        self.label.textAlignment                = NSTextAlignment.Center
        self.label.numberOfLines                = 0
        self.label.textColor                    = UIColor.whiteColor()
        self.label.text                         = self.message
    }
    
    private var showFrame : CGRect {
        get {
            return CGRect(origin:self.origin, size:self.formattedTextSize)
        }
    }
    
    private var hideFrame : CGRect {
        get {
            return CGRect(origin:self.origin, size:CGSizeZero)
         }
    }
    
    private var showLabelFrame : CGRect {
        get {
            return CGRect(origin:CGPointMake(0, 0), size:self.formattedTextSize)
        }
    }
    
    private var hideLabelFrame : CGRect {
        get {
            let newOrigin                       = CGPoint(x:0, y: -self.formattedTextSize.height)
            return CGRect(origin:newOrigin, size:self.formattedTextSize)
        }
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didDismiss:Completed {
        get {
            fatalError("You cannot read from this object.")
        }
        set {
            _didDismiss = newValue
        }
    }
    
    public func show(message:String) {
        self.newMessage                         = message
        show()
    }
    
    public func show() {
        let showb:()->() = {
            self.timer                          = NSTimer.scheduledTimerWithTimeInterval(self.timeout, target:self, selector:#selector(CMMicroBanner.hide as (CMMicroBanner) -> () -> ()), userInfo:nil, repeats:false)
            
            if let vc = self.topView {
                vc.addSubview(self)
                switch self.style {
                case .Default:
                    self.label.backgroundColor  = UIColor.greenCurrent()
                case .Error:
                    self.label.backgroundColor  = UIColor.redCurrent()
                case .GPS:
                    self.label.backgroundColor  = UIColor.blueCurrent()
                case .Arrived:
                    self.label.backgroundColor  = UIColor.blueCurrent()
                }

                self.label.frame                = self.hideLabelFrame
                self.frame                      = self.showFrame
                
                UIView.animateWithDuration(0.45,
                    delay: 0,
                    usingSpringWithDamping: 500.0,
                    initialSpringVelocity: 0,
                    options:UIViewAnimationOptions.CurveEaseOut,
                    animations: { () -> Void in
                        self.label.frame        = self.showLabelFrame
                    }, completion: { (complet:Bool) -> Void in
                        
                })
            }
        }
        
        if self.isOnScreen == true {
            hide({ () -> () in
                if let nm = self.newMessage {
                    self.message(nm)
                    self.newMessage             = nil
                }
                showb()
            })
        } else {
            showb()
        }
    }
    
    public func hide() {
        if self.isOnScreen == false {
            return
        }
        hide(nil)
    }
    
    private func hide(completed:Completed?) {
        self.timer?.invalidate()
        if let _ = self.topView {
            
            self.label.frame                    = self.showLabelFrame
            self.frame                          = self.showFrame

            UIView.animateWithDuration(0.30,
                delay: 0,
                usingSpringWithDamping: 800.0,
                initialSpringVelocity: 0,
                options:UIViewAnimationOptions.CurveEaseIn,
                animations: { () -> Void in
                    self.label.frame            = self.hideLabelFrame
                }, completion: { (complet:Bool) -> Void in
                    self.frame                  = self.hideFrame
                    if let c = completed {
                        c()
                    } else {
                        self.removeFromSuperview()
                        self._didDismiss?()
                    }
            })
        } else {
            completed?()
        }
    }
    
}























