//
//  CMOnboardBaseViewController.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

extension CYNavigationPush where Self : CMOnboardBaseViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushLeftAnimator()
    }
}

extension CYNavigationPop where Self : CMOnboardBaseViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class CMOnboardBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var gestureNavigationController:CMNavigationController? {
        return self.navigationController as? CMNavigationController
    }

    var nextPageTapRecognizer:UITapGestureRecognizer?
    var segueInPlay = false

    var theView:CMOnboardView {
        return self.view as! CMOnboardView
    }
    
    var pageControl:UIPageControl? {
        get {
            if let nav = self.navigationController as? CMNavigationController {
                return nav.pageControl
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
        
        self.nextPageTapRecognizer                              = UITapGestureRecognizer(target: self, action:#selector(CMOnboardBaseViewController.nextScreen))
        self.nextPageTapRecognizer?.cancelsTouchesInView        = true
        self.nextPageTapRecognizer?.numberOfTouchesRequired     = 1
        self.nextPageTapRecognizer?.delegate                    = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl?.hidden                                = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let npg = self.nextPageTapRecognizer {
            self.view.addGestureRecognizer(npg)
        }
        self.segueInPlay                                        = false
    }
    
    deinit {
        if let npg = self.nextPageTapRecognizer {
            self.view.removeGestureRecognizer(npg)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (UIDevice.currentDevice().model.rangeOfString("iPad") != nil) {
            self.theView.topLabelConstraint?.constant                        = 10
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "viewControllerPush" {
            return !self.segueInPlay
        }
        return true
    }
   
    func nextScreen() {
        if let npg = self.nextPageTapRecognizer {
            self.view.removeGestureRecognizer(npg)
        }
        self.segueInPlay                                        = true
        self.performSegueWithIdentifier("viewControllerPush", sender: self)
    }
    
}
