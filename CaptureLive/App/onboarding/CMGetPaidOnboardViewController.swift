//
//  CMGetPaidOnboardViewController.swift
//  Current
//
//  Created by Scott Jones on 8/27/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMGetPaidOnboardViewController: CMOnboardBaseViewController, CYNavigationPop {

    override var theView:CMGetPaidOnboardView {
        return self.view as! CMGetPaidOnboardView
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl?.hidden                                    = true
        self.pageControl?.currentPage                               = 3
    }

    override func nextScreen() {
       
    }
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
        if let npg = self.nextPageTapRecognizer {
            self.view.removeGestureRecognizer(npg)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.getStartedButton?.addTarget(self, action: #selector(CMGetPaidOnboardViewController.getStarteButtonHandler), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.getStartedButton?.removeTarget(self, action: #selector(CMGetPaidOnboardViewController.getStarteButtonHandler), forControlEvents: .TouchUpInside)
    }

    func getStarteButtonHandler() {
        // send notification
        self.performSegueWithIdentifier("endOnboarding", sender: self)
    }
    
}
