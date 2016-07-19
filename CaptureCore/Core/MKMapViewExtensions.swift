//
//  MKMapViewExtensions.swift
//  Current-Tools
//
//  Created by Scott Jones on 12/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {

    func fitMapViewToAnnotationList(edgePadding:UIEdgeInsets) -> Void {
        var zoomRect:MKMapRect          = MKMapRectNull
        for annotation in NSArray(array: self.annotations) {
            let ano                     = annotation as! CMAnnotation
            let aPoint:MKMapPoint       = MKMapPointForCoordinate(ano.coordinate)
            let rect:MKMapRect          = MKMapRectMake(aPoint.x, aPoint.y, 0.0, 0.0)
            if MKMapRectIsNull(zoomRect) {
                zoomRect                = rect
            } else {
                zoomRect                = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        UIView.animateWithDuration(1.0, delay: 0.0, options:[.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
            self.setVisibleMapRect(zoomRect, edgePadding:edgePadding, animated:true)
            }) { (fin:Bool) -> Void in
        }
    }

}
