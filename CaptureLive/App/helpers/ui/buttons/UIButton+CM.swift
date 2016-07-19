//
//  UIButton+CM.swift
//  Current
//
//  Created by Scott Jones on 1/24/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

extension UIButton {
    
    func alignImageRight() {
        if let titleLabel = self.titleLabel, imageView = self.imageView {
            titleLabel.sizeToFit()
            imageView.sizeToFit()
            imageView.contentMode                           = .ScaleAspectFit
            
            // Set the insets so that the title appears to the left and the image appears to the right.
            // Make the image appear slightly off the top/bottom edges of the button.
            let screen = UIScreen.mainScreen().bounds.size.width
            let titleSpace = (screen - (titleLabel.frame.size.width + 40)) * -1
            let buttonSpace = (screen - (imageView.frame.size.width + 40)) * -1
            
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleSpace, bottom: 0, right: imageView.frame.size.width)
            self.imageEdgeInsets = UIEdgeInsets(top: 4, left: titleLabel.frame.size.width, bottom: 4, right:buttonSpace)
        }
    }
}
