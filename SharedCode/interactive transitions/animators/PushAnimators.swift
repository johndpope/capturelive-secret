//
//  Animators.swift
//  NavTest
//
//  Created by Scott Jones on 1/6/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

public protocol NavigationAnimatorIgnorable {
    var navAnimatorDelegate : NavigationAnimatable? { get set }
}

public class PopRightAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
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
        secondVCView.frame                  = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
        
        context.containerView()!.addSubview(secondVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
       
        secondVCView?.layer.shadowColor     = UIColor.blackColor().CGColor
        secondVCView?.layer.shadowOpacity   = 0.5
        secondVCView?.layer.shadowOffset    = CGSizeMake(0, 1)
        secondVCView?.layer.shadowRadius    = 1
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
            
            }) { (Finished:Bool) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PushLeftAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fVC                             = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let firstVCView                     = fVC.view
        let secondVCView                    = context.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let b = UIScreen.mainScreen().bounds
        let screenWidth                     = b.size.width
        let screenHeight                    = b.size.height
        
        secondVCView.frame                  = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
        firstVCView.frame                   = b
        
        context.containerView()!.addSubview(firstVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
       
        secondVCView?.layer.shadowColor     = UIColor.blackColor().CGColor
        secondVCView?.layer.shadowOpacity   = 0.5
        secondVCView?.layer.shadowOffset    = CGSizeMake(0, 1)
        secondVCView?.layer.shadowRadius    = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PopLeftAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let firstVCView                     = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        let secondVCView                    = context.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let b = context.containerView()!.bounds
        let screenWidth                     = b.size.width
        let screenHeight                    = b.size.height
        
        firstVCView.frame                   = b
        secondVCView.frame                  = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
        
        context.containerView()!.addSubview(firstVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
        
        secondVCView?.layer.shadowColor     = UIColor.blackColor().CGColor
        secondVCView?.layer.shadowOpacity   = 0.5
        secondVCView?.layer.shadowOffset    = CGSizeMake(0, 1)
        secondVCView?.layer.shadowRadius    = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
            
            }) { (Finished:Bool) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
                
        }
    }
    
}

public class PushRightAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let firstVCView                     = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        let secondVCView                    = context.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let b = UIScreen.mainScreen().bounds
        let screenWidth                     = b.size.width
        let screenHeight                    = b.size.height
        
        secondVCView.frame                  = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
        firstVCView.frame                   = b
        
        context.containerView()!.addSubview(secondVCView)
        context.containerView()!.insertSubview(firstVCView, aboveSubview:secondVCView)
        
        firstVCView?.layer.shadowColor      = UIColor.blackColor().CGColor
        firstVCView?.layer.shadowOpacity    = 0.5
        firstVCView?.layer.shadowOffset     = CGSizeMake(0, 1)
        firstVCView?.layer.shadowRadius     = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PopTopAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
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
        secondVCView.frame                  = CGRectMake(0, screenHeight, screenWidth, screenHeight)
        
        context.containerView()!.addSubview(secondVCView)
        context.containerView()!.insertSubview(firstVCView, aboveSubview:secondVCView)
       
        firstVCView?.layer.shadowColor      = UIColor.blackColor().CGColor
        firstVCView?.layer.shadowOpacity    = 0.5
        firstVCView?.layer.shadowOffset     = CGSizeMake(0, 1)
        firstVCView?.layer.shadowRadius     = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PushBottomAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
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
        
        secondVCView.frame                  = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
        firstVCView.frame                   = b
        
        context.containerView()!.addSubview(firstVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
        
        secondVCView?.layer.shadowColor     = UIColor.blackColor().CGColor
        secondVCView?.layer.shadowOpacity   = 0.5
        secondVCView?.layer.shadowOffset    = CGSizeMake(0, 1)
        secondVCView?.layer.shadowRadius    = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, screenHeight, screenWidth, screenHeight)
            
            }) { (Finished) -> Void in
                self.navAnimatorDelegate?.enable()
                context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PopBottomAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
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
        secondVCView.frame                  = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
        
        context.containerView()!.addSubview(secondVCView)
        context.containerView()!.insertSubview(firstVCView, aboveSubview:secondVCView)
       
        firstVCView?.layer.shadowColor      = UIColor.blackColor().CGColor
        firstVCView?.layer.shadowOpacity    = 0.5
        firstVCView?.layer.shadowOffset     = CGSizeMake(0, 1)
        firstVCView?.layer.shadowRadius     = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, screenHeight, screenWidth, screenHeight)
            
        }) { (Finished) -> Void in
            self.navAnimatorDelegate?.enable()
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class PushTopAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
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
        
        secondVCView.frame                  = CGRectMake(0, screenHeight, screenWidth, screenHeight)
        firstVCView.frame                   = b
        
        context.containerView()!.addSubview(firstVCView)
        context.containerView()!.insertSubview(secondVCView, aboveSubview:firstVCView)
        
        secondVCView?.layer.shadowColor     = UIColor.blackColor().CGColor
        secondVCView?.layer.shadowOpacity   = 0.5
        secondVCView?.layer.shadowOffset    = CGSizeMake(0, 1)
        secondVCView?.layer.shadowRadius    = 1

        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            secondVCView.frame              = b
            firstVCView.frame               = CGRectMake(0, -screenHeight, screenWidth, screenHeight)
            firstVCView.alpha               = 0
            
        }) { (Finished) -> Void in
            self.navAnimatorDelegate?.enable()
            firstVCView.alpha               = 1
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}
