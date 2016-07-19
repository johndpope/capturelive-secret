//
//  CMShowLiveStreamSegue.swift
//  Current
//
//  Created by Scott Jones on 10/23/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMShowLiveStreamSegue: UIStoryboardSegue {
    
    var blackView:UIView!
    
    override func perform() {
        let firstVCView                     = self.sourceViewController.view as UIView!
        let secondVCView                    = self.destinationViewController.view as UIView!
        
        let screenWidth                     = UIScreen.mainScreen().bounds.size.width
        let screenHeight                    = UIScreen.mainScreen().bounds.size.height

        secondVCView.frame                  = UIScreen.mainScreen().bounds
        firstVCView.frame                   = UIScreen.mainScreen().bounds
        
        secondVCView.alpha = 0

        let window                          = UIApplication.sharedApplication().keyWindow
        self.blackView                      = UIView(frame: CGRectMake((screenWidth / 2) - 1, (screenHeight / 2) - 1, 0.0, 0.0))
        self.blackView.backgroundColor      = UIColor.blackCurrent()
        window?.addSubview(self.blackView)

        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.blackView.frame            = CGRectMake(0, self.blackView.frame.origin.y, screenWidth, 2)
            
            }) { (Finished) -> Void in

                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.blackView.frame    = CGRectMake(0, 0, screenWidth, screenHeight)
                    
                    }) { (Finished) -> Void in
                        
                        window?.insertSubview(secondVCView, aboveSubview:self.blackView)

                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            secondVCView.alpha = 1
                            
                            }) { (Finished) -> Void in
                                
                                secondVCView.alpha = 1
                                self.blackView.removeFromSuperview()
                                print("animation doen")
                                self.sourceViewController.navigationController?.pushViewController(self.destinationViewController as UIViewController, animated: false)
                        }
                }

        }
        
        
        
    }

}
