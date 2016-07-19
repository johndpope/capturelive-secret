//
//  CMOnboardGetAJobViewController.swift
//  Current
//
//  Created by Scott Jones on 8/27/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMGetAJobOnboardViewController: CMOnboardBaseViewController, CYNavigationPush, CYNavigationPop {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl?.currentPage                               = 1
    }
 
}
