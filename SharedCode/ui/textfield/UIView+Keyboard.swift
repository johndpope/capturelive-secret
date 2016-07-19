//
//  Key.swift
//  Capture-Live
//
//  Created by hatebyte on 7/6/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public typealias KeyBoardValues = (height:Float, curve:UIViewAnimationCurve, duration:NSTimeInterval)

extension UIView {

    public static func keyboardNotificationValues(notification:NSNotification)->KeyBoardValues {
        if let info = notification.userInfo {
            let rawAnimationCurveValue  = info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
            let keyboardAnimationCurve  = UIViewAnimationCurve(rawValue: Int(rawAnimationCurveValue.unsignedIntegerValue))!
            let duration                = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber ?? NSNumber(double:7.0)
            let keyboardSize            = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            return (Float(keyboardSize!.height), keyboardAnimationCurve, NSTimeInterval(duration.doubleValue))
        }
        return (Float(0), UIViewAnimationCurve.EaseOut, NSTimeInterval(0))
    }

    public func scrollToY(y:Float) {
        var r                       = self.frame
        r.origin.y                  = CGFloat(y)
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 500.0,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.frame = r
            }, completion: { (complet:Bool) -> Void in
                
        })
    }
    
    public func scrollToY(y:Float, animations:()->()) {
        var r                       = self.frame
        r.origin.y                  = CGFloat(y)
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 500.0,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.frame = r
                animations()
            }, completion: { (complet:Bool) -> Void in
                
        })
    }
    
    public func scrollToView(view:UIView, keyboardHeight:Float) {
        let y = view.frame.origin.y + view.frame.size.height
        let threshold = UIScreen.mainScreen().bounds.size.height - CGFloat(keyboardHeight)
        if y > threshold {
            self.scrollToY(Float(UIScreen.mainScreen().bounds.size.height - (y + CGFloat(keyboardHeight))))
        } else {
            self.scrollToY(0)
        }
    }
    
    public func scrollToView(view:UIView) {
        let y = view.frame.origin.y + view.frame.size.height
        let threshold = UIScreen.mainScreen().bounds.size.height - 274.0
        if y > threshold {
            self.scrollToY(Float(threshold - y))
        } else {
            self.scrollToY(0)
        }
    }

    public func scrollToView(view:UIView, withCurve curve:UIViewAnimationCurve, andDuration duration:NSTimeInterval) {
        let y = view.frame.origin.y + view.frame.size.height
        let threshold = UIScreen.mainScreen().bounds.size.height - 274.0

        if y > threshold {
            self.scrollToY(Float(threshold - y), withCurve: curve, andDuration: duration)
        } else {
            self.scrollToY(0, withCurve: curve, andDuration: duration)
        }
    }
    
    public func scrollToY(y:Float, withCurve curve:UIViewAnimationCurve, andDuration duration:NSTimeInterval) {
        var r                       = self.frame
        r.origin.y                  = CGFloat(y)
        
        UIView.animateWithDuration(0.55,
            delay: 0,
            usingSpringWithDamping: 500.0,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                UIView.setAnimationCurve(curve)
                self.frame = r
            }, completion: { (complet:Bool) -> Void in
                
        })
    }
    
    public func scrollToY(y:Float, withCurve curve:UIViewAnimationCurve, andDuration duration:NSTimeInterval, animations:()->()) {
        var r                       = self.frame
        r.origin.y                  = CGFloat(y)
        
        UIView.animateWithDuration(0.55,
            delay: 0,
            usingSpringWithDamping: 500.0,
            initialSpringVelocity: 0,
            options:UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                UIView.setAnimationCurve(curve)
                self.frame = r
                animations()
            }, completion: { (complet:Bool) -> Void in
                
        })
    }

    public func scrollToElement(view:UIView, toPoint y:Float) {
        let theFrame = view.frame
        let orig_y = theFrame.origin.y
        let diff = CGFloat(y) - orig_y
        if diff < 0 {
            self.scrollToY(Float(diff))
        } else {
            self.scrollToY(0)
        }
    }

}


