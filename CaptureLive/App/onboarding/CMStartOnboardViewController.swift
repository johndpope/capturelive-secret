//
//  CMStartOnboardViewController.swift
//  Current
//
//  Created by Scott Jones on 8/27/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMStartOnboardViewController: CMOnboardBaseViewController, CYNavigationPush {
   
    override func viewDidLoad() {
        self.gestureNavigationController?.addOnboardingPageControl()
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl?.currentPage       = 0
    }
    
}
