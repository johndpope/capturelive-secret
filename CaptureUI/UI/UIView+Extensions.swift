//
//  UIView+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit


extension UIView {
    
    public func makeImage()->UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
//        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let viewImage           = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
    }
    
}