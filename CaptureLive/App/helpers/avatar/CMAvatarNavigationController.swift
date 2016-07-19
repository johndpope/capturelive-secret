//
//  CMAvatarNavigationController.swift
//  Capture-Live
//
//  Created by hatebyte on 6/3/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

protocol CMAvatarNavigationDelegate {
    func dismiss(didSuccessFullyChangeAvatar:Bool)
}

class CMAvatarNavigationController: UINavigationController {

    var avatarDelegate:CMAvatarNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarHidden                            = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissCancel() {
        self.popToRootViewControllerAnimated(false)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if let d = self.avatarDelegate {
                d.dismiss(false)
            }
        })
    }
    
    func dismissSuccess() {
        self.popToRootViewControllerAnimated(false)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if let d = self.avatarDelegate {
                d.dismiss(true)
            }
        })
    }

}
