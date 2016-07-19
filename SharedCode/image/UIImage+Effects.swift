//
//  UIImage+Effects.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

typealias MYImage = CIImage

extension UIImage {
    
    public func blurred(threshold:Int32)->UIImage {

        let imageToBlur             = MYImage(image:self)
        let blurfilter              = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue("\(threshold)", forKey:kCIInputRadiusKey)
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        let resultImage             = blurfilter.valueForKey("outputImage") as! MYImage

        let cgimageref              = CIContext(options:[kCIContextUseSoftwareRenderer : true]) .createCGImage(resultImage, fromRect: resultImage.extent)
        return UIImage(CGImage:cgimageref)
    }
    
    public static func imageFromSampleBuffer(sampleBuffer:CMSampleBufferRef?, complete:(UIImage?)->()) {
        if let sb = sampleBuffer {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let image               = UIImage(fromSampleBufferRef:sb)
                dispatch_async(dispatch_get_main_queue()) {
                    complete(image)
                }
            }
        } else {
            complete(nil)
        }
    }
    
    public func convertToGrayScaleNoAlpha() -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage)
        return CGBitmapContextCreateImage(context)!
    }
    
    public func convertToGrayScale() -> UIImage {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, nil, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
        let mask = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: CGImageCreateWithMask(convertToGrayScaleNoAlpha(), mask)!, scale: scale, orientation:imageOrientation)
    }

}
