//
//  CMActionSheetViewController.swift
//  Current
//
//  Created by Scott Jones on 11/6/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMActionSheetController:CMAlertController {
    
    override func loadView() {
        let aView:CMActionSheetView = UIView.fromNib()
        self.view = aView
    }
    
}

