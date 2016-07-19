//
//  CMAlertWithImageView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class CMAlertWithImageView: CMAlertView {

    @IBOutlet weak var imageView:UIImageView?
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func addImage(imageName:String) {
        imageView?.image = UIImage(named:imageName)
    }
    
    override func addButtons(buttonArray:[UIButton]) {
        super.addButtons(buttonArray)
        
        self.heightConstraint?.constant         = self.heightConstraint!.constant + 110.0
        self.layoutIfNeeded()
    }
    
}
