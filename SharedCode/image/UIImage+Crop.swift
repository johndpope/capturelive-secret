//
//  UIImage+Crop.swift
//  Capture-Live
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func getCenterSquareAtPercent(percent:CGFloat)->UIImage! {
        let y:CGFloat                                   = -((self.size.height - self.size.width) * 0.5);
        let imageSize                                   = CGSizeMake( ceil(CGFloat(self.size.width * percent)), ceil(CGFloat(self.size.width * percent)) );
        let imageRect                                   = CGRectMake(0, ceil(CGFloat(y * percent)), ceil(CGFloat(self.size.width * percent)), ceil(CGFloat(self.size.height * percent)));
        
        var newImage:UIImage!
        UIGraphicsBeginImageContext(imageSize);
        self.drawInRect(imageRect)
        newImage                                        = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    public func combineAsTop(image:UIImage, atSize size:CGSize)->UIImage {
        let finalSize                                   = self.size
        var finishedImage:UIImage!
        
        UIGraphicsBeginImageContext(finalSize);
        var underRect                                   = CGRectMake(0, 0, size.width, size.height);
        underRect.origin.x                              = (self.size.width - underRect.size.width) * 0.5;
        underRect.origin.y                              = (self.size.height - underRect.size.height) * 0.5;
        image.drawInRect(underRect)
        
        let overRect                                    = CGRectMake(0, 0, self.size.width, self.size.height);
        self.drawInRect(overRect)
        finishedImage                                   = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return finishedImage
    }
    
    public func getTinted(color:UIColor)->UIImage {
        var tintedImage:UIImage!
        UIGraphicsBeginImageContext(self.size);
        let drawRect                                   = CGRectMake(0, 0, self.size.width, self.size.height);
        self.drawInRect(drawRect)
        color.set()
        UIRectFillUsingBlendMode(drawRect, CGBlendMode.SourceAtop)
        
        tintedImage                                     = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    public func getCenterSquare(size:CGFloat, alpha:CGFloat)->UIImage! {
        let imageSize                                   = CGSizeMake(size, size);
        
        let largest                                     = max(self.size.width, self.size.height)
        let smallest                                    = min(self.size.width, self.size.height)
        let percent                                     = size / smallest
        let y:CGFloat                                   = (smallest - largest) * 0.5;
        
        let imageRect                                   = CGRectMake(0, y * percent, ceil(self.size.width * percent), self.size.height * percent);
        var newImage:UIImage!
        UIGraphicsBeginImageContext(imageSize);
        self.drawInRect(imageRect, blendMode:CGBlendMode.Normal, alpha:alpha)
        newImage                                        = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    
    
}