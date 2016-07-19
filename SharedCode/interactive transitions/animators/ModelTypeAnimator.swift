//
//  ModelTypeAnimator.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import Foundation

public class SlideUpPushAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fVC                             = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let firstVCView                     = fVC.view
        let secondVCView                    = context.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let b                               = UIScreen.mainScreen().bounds
        let screenWidth                     = b.size.width
        let screenHeight                    = b.size.height
        
        secondVCView.frame                  = CGRectMake(0, screenHeight, screenWidth, screenHeight)
        firstVCView.frame                   = b
        
        context.containerView()!.addSubview(firstVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
        
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, 0, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
                
        }
    }
    
}

public class SlideDownPopAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fVC                             = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let firstVCView                     = fVC.view
        let secondVCView                    = context.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let b                               = context.containerView()!.bounds
        let screenWidth                     = b.size.width
        let screenHeight                    = b.size.height
        
        firstVCView.frame                   = b
        secondVCView.frame                  = b
        
        context.containerView()!.addSubview(secondVCView)
        context.containerView()!.insertSubview(firstVCView, aboveSubview:secondVCView)
        
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, screenHeight, screenWidth, screenHeight)
            
            }) { (Finished:Bool) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}