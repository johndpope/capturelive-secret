//
//  UIView+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/4/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

extension UIView {
    
    public func makeImage()->UIImage {
        UIGraphicsBeginImageContext(self.bounds.size);
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let viewImage           = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
    }
    
}