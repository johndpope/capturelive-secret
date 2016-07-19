//
//  CMUnwindLiveStreamSegue.swift
//  Current
//
//  Created by Scott Jones on 10/23/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureCore
import CaptureUI

class CMUnwindLiveStreamSegue: UIStoryboardSegue {

    override func perform() {

        let homeVC = self.destinationViewController
        let homeView = homeVC.view

        let streammImage = self.sourceViewController.view.makeImage()
        let streamView     = UIImageView(image: streammImage)

        let window = self.sourceViewController.view.window
        window?.addSubview(homeView)
        window?.insertSubview(streamView, aboveSubview:homeView)

        let screenHeight    = UIScreen.mainScreen().bounds.size.height
        let screenWidth     = UIScreen.mainScreen().bounds.size.width

        homeView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            streamView.frame = CGRectMake(0, (screenHeight / 2) - 1, screenWidth, 2)
            streamView.center = homeView.center
            
            }) { (Finished) -> Void in
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    streamView.frame = CGRectMake((screenWidth / 2) - 1, (screenHeight / 2) - 1, 0, 0)
                    streamView.center = homeView.center
                    
                    }) { (Finished) -> Void in
                        
                        streamView.removeFromSuperview()
                        if let nc = self.sourceViewController.navigationController {
                            nc.popViewControllerAnimated(false)
                            homeVC.setNeedsStatusBarAppearanceUpdate()
                        }
                }
                
        }
    }
    
}


