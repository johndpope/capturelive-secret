//
//  MapController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/14/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import MapKit
import CaptureUI

public class MapController: NSObject {

    private var myRoute : MKRoute!
    private weak var mapView:MKMapView!
    private var eventCoordinate:CLLocationCoordinate2D!
    private var userMarker:CMUserAnnotation!
    private var eventMarker:CMAnnotation!
    
    public init(mapView:MKMapView, currentCoordinate:CLLocationCoordinate2D, eventCoordinate:CLLocationCoordinate2D, avatarPathString:String) {
        self.mapView                        = mapView
        self.eventCoordinate                = eventCoordinate
        super.init()
        self.userMarker                     = CMUserAnnotation(avatarPathString:avatarPathString, coordinate:currentCoordinate)
        self.eventMarker                    = CMEnrouteAnnotation(coordinate:self.eventCoordinate)
    }
   
    private lazy var edgeInsets:UIEdgeInsets = {
        return UIEdgeInsetsMake((ScreenSize.SCREEN_HEIGHT * 0.327), 20, ScreenSize.SCREEN_HEIGHT * 0.195, 20)
    }()
    
    public func didLoad() {
        mapView.mapType                     = .Standard
//        userMarker.title      = "Taipei"
//        userMarker.subtitle   = "Taiwan"
//        eventMarker.title     = "Chungli"
//        eventMarker.subtitle  = "Taiwan"
        mapView.addAnnotation(eventMarker)
        mapView.delegate                    = self
        
        update(userMarker.coordinate)
    }
    
    public func update(originCoordinate:CLLocationCoordinate2D) {
        mapView.removeAnnotation(userMarker)
        userMarker.coordinate               = originCoordinate
        mapView.addAnnotation(userMarker)
        mapView.fitMapViewToAnnotationList(edgeInsets)
        
        let directionsRequest               = MKDirectionsRequest()
        let markTaipei                      = MKPlacemark(coordinate: CLLocationCoordinate2DMake(userMarker.coordinate.latitude, userMarker.coordinate.longitude), addressDictionary: nil)
        let markChungli                     = MKPlacemark(coordinate: CLLocationCoordinate2DMake(eventMarker.coordinate.latitude, eventMarker.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source            = MKMapItem(placemark: markChungli)
        directionsRequest.destination       = MKMapItem(placemark: markTaipei)
        
        directionsRequest.transportType     = MKDirectionsTransportType.Automobile
        let directions                      = MKDirections(request: directionsRequest)
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            directions.calculateDirectionsWithCompletionHandler({ [weak self] response, error in
                if error == nil {
                    guard let r = response else { return }
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.updateRoute(r)
                    }
                }
            })
        })
    }
    
    private func updateRoute(response: MKDirectionsResponse) {
        self.myRoute = response.routes[0] as MKRoute
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(self.myRoute.polyline)
    }
    
}

extension MapController : MKMapViewDelegate {

    public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let myLineRenderer                  = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor          = UIColor.mountainMeadow()
        myLineRenderer.lineWidth            = 4
        return myLineRenderer
    }
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(CMAnnotation.self) {
            let cman = annotation as! CMMKAnnotation
            var annotationView                  = mapView.dequeueReusableAnnotationViewWithIdentifier(cman.identifier())
            if annotationView == nil {
                annotationView                  = MKAnnotationView(annotation:cman, reuseIdentifier: cman.identifier())
            }
            annotationView?.enabled             = false
            annotationView?.image               = cman.image()
            annotationView!.annotation          = cman
            return annotationView
        }
        return nil
    }
    
    public func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            if view.annotation!.isKindOfClass(CMUserAnnotation.self) {
                view.superview?.bringSubviewToFront(view)
            } else {
                view.superview?.sendSubviewToBack(view)
            }
        }
        
    }

}
