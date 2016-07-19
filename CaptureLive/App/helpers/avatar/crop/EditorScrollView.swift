//
//  EditorScrollView.swift
//  Capture-Live
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import Foundation
import UIKit

class EditorScrollView:UIScrollView, UIScrollViewDelegate {
    
    var zoomView                                                :UIImageView!
    var maxScale                                                :CGFloat!
    var imageSize                                               :CGSize!
    var pointToCenterAfterResize                                :CGPoint!
    var scaleToRestoreAfterResize                               :CGFloat!
    var isAlreadyZoomed                                         :Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator                     = false;
        self.showsVerticalScrollIndicator                       = false;
        self.bouncesZoom                                        = true;
        self.clipsToBounds                                      = false;
        self.decelerationRate                                   = UIScrollViewDecelerationRateNormal;
        self.delegate                                           = self;
        self.zoomScale                                          = 1.0;
        self.maxScale                                           = 3.0;
    }
    
    var image                                                   :UIImage! {
        get{
            return zoomView.image
        }
        set {
            zoomView                                            = UIImageView(image:newValue)
            self.reconfigureForImage()
        }
    }
    
    override var frame                                          :CGRect {
        get {
            return super.frame
        }
        set {
            let sizeChanging                                    = !CGSizeEqualToSize(newValue.size, self.frame.size);
            
            if sizeChanging {
                self.prepareForResize();
            }
            
            super.frame                                         = newValue;
            
            if sizeChanging {
                self.recoverFromResize();
            }
        }
    }
    
    override func layoutSubviews()  {
        super.layoutSubviews();
        
        // center _imageView as it goes smaller than the screen
        let boundSize:CGSize                                    = self.bounds.size;
        var frameToCenter:CGRect                                = zoomView.frame;
        
        // center for horizontal
        if frameToCenter.size.width < boundSize.width {
            frameToCenter.origin.x                              = (boundSize.width - frameToCenter.size.width) * 0.5
        } else {
            frameToCenter.origin.x                              = 0;
        }
        
        // center for vertical
        if frameToCenter.size.height < boundSize.height {
            frameToCenter.origin.y                              = (boundSize.height - frameToCenter.size.height) * 0.5
        } else {
            frameToCenter.origin.y                              = 0;
        }
        
        zoomView.frame                                          = frameToCenter;
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return true
    }
    
//    func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView!? {
//        for subview:AnyObject in self.subviews {
//            if CGRectContainsPoint(subview.frame, point) {
//                return subview as! UIView;
//            }
//        }
//        
//        return super.hitTest(point, withEvent: event);
//    }
    
    func reconfigureForImage() {
        self.addSubview(zoomView);
        imageSize                                               = zoomView.frame.size;
        self.contentSize                                        = zoomView.frame.size;
        
        self.setMaxMinZoomScaleForCurrentBounds();
        self.layoutSubviews();
        
        var ratio                                               = UIScreen.mainScreen().bounds.size.width / self.image.size.width;
        if self.minimumZoomScale > ratio {
            ratio                                               = self.minimumZoomScale
        }
        
        self.zoomScale                                          = ratio;
        let x                                                   = ((self.image.size.width * ratio) - self.frame.size.width) * 0.5
        let y                                                   = ((self.image.size.height * ratio) - self.frame.size.height) * 0.5
        self.contentOffset                                      = CGPointMake(x, y);
    }
    
    func prepareForResize() {
        let boundsCenter                                        = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        pointToCenterAfterResize                                = self.convertPoint(boundsCenter, fromView: zoomView)
        
        scaleToRestoreAfterResize                               = zoomScale;
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
//        if scaleToRestoreAfterResize <= self.minimumZoomScale + CGFloat(FLT_EPSILON) {
//            scaleToRestoreAfterResize                           = 0;
//        }
        
    }
    
    func recoverFromResize() {
        self.setMaxMinZoomScaleForCurrentBounds();
        
        // RESTORE SCALE
        // restore zoom scale first, make sure its in allowable range
        let maxZoomScale:CGFloat                                = max(self.minimumZoomScale, scaleToRestoreAfterResize)
        self.zoomScale                                          = min(self.maximumZoomScale, maxZoomScale)
        
        
        // RESTORE CENTER POINT
        // first convert it from what the view thinks it is to out coordinate system
        let boundsCenter:CGPoint                                = self.convertPoint(pointToCenterAfterResize, fromView:zoomView)
        
        // second calculate content offset that would yield the center point
        var offset                                              = CGPointMake(boundsCenter.x - self.bounds.size.width * 0.5, boundsCenter.y - self.bounds.size.height * 0.5);
        
        // put back in offset position
        let maxOffset:CGPoint                                   = self.maximumContentOffset();
        let minOffset:CGPoint                                   = self.minimumContentOffset();
        
        // take max from center or offset
        var realMaxOffset                                       = min(maxOffset.x, offset.x);
        offset.x                                                = max(minOffset.x, realMaxOffset);
        
        // take max from center or offset
        realMaxOffset                                           = min(maxOffset.y, offset.y);
        offset.y                                                = max(minOffset.y, realMaxOffset);
        
        self.contentOffset                                      = offset;
    }
    
    func maximumContentOffset()->CGPoint {
        let contentSize                                          = self.contentSize;
        let boundsSize                                           = self.bounds.size;
        return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
    }
    
    func minimumContentOffset()->CGPoint {
        return CGPointZero;
    }
    
    func setMaxMinZoomScaleForCurrentBounds() {
        // calucalate min/max zoom
        let xScale                                              = (self.frame.size.width / imageSize.width)
        let yScale                                              = (self.frame.size.height / imageSize.height)
        
        // find biggest for each orientation or take smaller scale
        var minScale                                            = max(xScale, yScale)
        
        // find scale resolution of screen
        let maxScale                                            = self.maxScale / UIScreen.mainScreen().scale
        
        if (minScale > maxScale) {
            minScale                                            = maxScale
        }
        
        self.maximumZoomScale                                   = maxScale
        self.minimumZoomScale                                   = minScale
    }
    
    func kroppedImage()->(UIImage!) {
        // the image scale
        let scale                                               = self.image.size.width / self.contentSize.width
        let containerWidth                                      = self.frame.size.width
        // the image scale
        let width                                               = containerWidth * scale
        
        let xFromCenter                                         = ((self.contentOffset.x) + (self.frame.size.width * 0.5))
        let yFromCenter                                         = ((self.contentOffset.y) + (self.frame.size.height * 0.5))
        let x                                                   = (containerWidth * 0.5)  - xFromCenter
        let y                                                   = (containerWidth * 0.5)  - yFromCenter
        
        let captureRect                                         = CGRectMake(x * scale, y * scale, self.image.size.width, self.image.size.height)
        
        var newImage:UIImage!
        UIGraphicsBeginImageContext(CGSizeMake(width, width))
        self.image.drawInRect(captureRect)
        newImage                                                = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        newImage                                                = newImage.getCenterSquareAtPercent(0.5)
        return newImage
    }
    
    // uiscrollview delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return zoomView;
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
        zoomView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
    
}
