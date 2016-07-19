//
//  CMMKViewController.swift
//  Current-Tools
//
//  Created by Scott Jones on 12/8/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//
import MapKit
import UIKit

public class CMMKSController:NSObject, MKMapViewDelegate {
    
    var userMarker:CMUserAnnotation?
    var eventMarker:CMAnnotation?
    
    var eventCoordinate:CLLocationCoordinate2D?
    var lastCoordinate:CLLocationCoordinate2D!
    var updateMap:UpdateClosure!
    weak var viewMap:MKMapView!
    private var avatarPathString:String!
    var mapGPS:CMGoogleRouteFetcher!
    private var animationDuration           = 3.0
    var edgePadding                         = UIEdgeInsets(top: 40, left: 40, bottom: 80, right: 40)
    public var zoomLevel:UInt               = 15
    var myRoute : MKRoute!
    
    public init(viewMap:MKMapView, avatarPathString:String) {
        self.viewMap                        = viewMap
        self.avatarPathString               = avatarPathString ?? ""
        self.mapGPS                         = CMGoogleRouteFetcher()
        super.init()
        self.userMarker                     = CMUserAnnotation(avatarPathString:self.avatarPathString, coordinate: CLLocationCoordinate2D())
        setup()
    }
    
    public func setEventLocation(eventCoordinate:CLLocationCoordinate2D) {
        self.eventCoordinate                = eventCoordinate
    }
    
    public func updateEventMarkerEnRoute() {
        if let em = self.eventMarker {
            self.viewMap?.removeAnnotation(em)
        }
        if let ec = self.eventCoordinate {
            self.eventMarker                = CMEnrouteAnnotation(coordinate:ec)
            self.viewMap?.addAnnotation(self.eventMarker!)
        }
    }
    
    public func updateEventMarkerArrived() {
        if let em = self.eventMarker {
            self.viewMap?.removeAnnotation(em)
        }
        if let ec = self.eventCoordinate {
            self.eventMarker                = CMArrivedAnnotation(coordinate:ec)
            self.viewMap?.addAnnotation(self.eventMarker!)
        }
    }

    deinit {
        self.viewMap                        = nil
    }
    
    func setup() {
        self.viewMap?.delegate              = self
        self.viewMap?.mapType               = .Standard
        self.viewMap?.addAnnotation(self.userMarker!)
//        self.viewMap?.setCenterCoordinate(self.userMarker!.coordinate, zoomLevel:self.zoomLevel, animated: true, completion: { (done:Bool) -> Void in
//            self.showUserCentered()
//        })
        showHired()
    }

    public func stop() {
        self.clearMarkers()
        self.viewMap?.hidden                = true
    }
    
    public func refreshAvatar(avatarPathString:String) {
        self.avatarPathString               = avatarPathString
        self.viewMap?.removeAnnotation(self.userMarker!)
        self.userMarker                     = nil
        let annot                           = CMUserAnnotation(avatarPathString:self.avatarPathString, coordinate: CLLocationCoordinate2D())
        self.userMarker                     = annot
        self.viewMap?.addAnnotation(self.userMarker!)
    }
//    
//    public func showUserCentered() {
//        self.edgePadding                    = UIEdgeInsetsZero
//        self.eventCoordinate                = nil
//        self.updateEventMarkerEnRoute()
//        if let um = self.userMarker {
//            self.viewMap?.addAnnotation(um)
//            self.eventMarker                = nil
//        }
//        self.updateMap                      = self.focusMapToShowUserCenter
//    }
//    
//    public func showEventCentered() {
//        self.edgePadding                    = UIEdgeInsetsZero
//        self.updateEventMarkerEnRoute()
//        if let em = self.eventMarker {
//            self.viewMap?.addAnnotation(em)
//        }
//        self.updateMap                      = self.focusMapToShowEventCenter
//    }
//    
//    public func showRequestClosed() {
//        self.edgePadding                    = UIEdgeInsets(top:40, left: 40, bottom:70, right: 40)
//        self.updateEventMarkerEnRoute()
//        if let um = self.userMarker {
//            self.viewMap?.addAnnotation(um)
//        }
//        self.updateMap                      = self.focusMapToShowBothMarkers
//    }
//
//    public func showRequestOpen() {
//        self.edgePadding                    = UIEdgeInsets(top:40, left: 40, bottom:70, right: 40)
//        self.updateEventMarkerEnRoute()
//        if let um = self.userMarker {
//            self.viewMap?.addAnnotation(um)
//        }
//        self.updateMap                      = self.focusMapToShowBothMarkers
//    }

    public func showHired() {
        self.edgePadding                    = UIEdgeInsets(top:1000, left: 20, bottom:200, right: 20)
        self.updateEventMarkerEnRoute()
        if let um = self.userMarker {
            self.viewMap?.addAnnotation(um)
        }
        self.updateMap                      = self.focusMapToShowBothMarkers
    }
    
//    public func showApproaching() {
//        self.edgePadding                    = UIEdgeInsets(top:40, left: 40, bottom:70, right: 40)
//        self.updateEventMarkerEnRoute()
//        if let um = self.userMarker {
//            self.viewMap?.addAnnotation(um)
//        }
//        self.updateMap                      = self.focusMapToShowBothMarkers
//    }
//    
//    public func showArrived() {
//        self.edgePadding                    = UIEdgeInsets(top:40, left: 40, bottom:70, right: 40)
//        self.updateEventMarkerArrived()
//        if let um = self.userMarker {
//            self.viewMap?.addAnnotation(um)
//        }
//        self.updateMap                      = self.focusMapToShowBothMarkers
//    }
//    
//    public func forceEventZoom() {
//        if let ec = self.eventCoordinate {
//            self.viewMap?.setCenterCoordinate(ec, zoomLevel: 18, animated: true, completion: nil)
//        }
//    }

    public func updateMapStyle(style:CMGMStyle) {
//        switch style {
//        case .UserCentered:
//            self.showUserCentered()
//        case .EventCentered:
//            self.showEventCentered()
//        case .RequestClosed:
//            self.showRequestClosed()
//        case .RequestOpen:
//            self.showRequestOpen()
//        case .UserHired:
            self.showHired()
//        case .Approaching:
//            self.showApproaching()
//        case .Arrived:
//            self.showArrived()
//        }
    }

    public static func navigateToMapsApp(startCoordinate:CLLocationCoordinate2D, endCoordinate:CLLocationCoordinate2D, travelMode:String, address:String?) {
        if let add = address {
            let encodedAddress = add.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let url = "comgooglemaps://?origin=saddr=Current+Location&&daddr=\(encodedAddress)&directionsmode=\(travelMode)"
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string:url)!)) {
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            } else {
                let url = "http://maps.apple.com/?saddr=\(startCoordinate.latitude),\(startCoordinate.longitude)&daddr=\(encodedAddress)&dirflg=\(travelMode.characters.first!)"
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            }
        } else {
            let url = "comgooglemaps://?origin=saddr=Current+Location&&daddr=\(endCoordinate.latitude),\(endCoordinate.longitude)&directionsmode=\(travelMode)"
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string:url)!)) {
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            } else {
                    let url = "http://maps.apple.com/?saddr=\(startCoordinate.latitude),\(startCoordinate.longitude)&daddr=\(endCoordinate.latitude),\(endCoordinate.longitude)&dirflg=\(travelMode.characters.first!)"
                    UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            }
        }
    }
    
    public func update(originCoordinate: CLLocationCoordinate2D, travelMode:String, completionHandler:RouteClosure) {
        self.update(originCoordinate)
        getDistance(originCoordinate, travelMode:travelMode, completionHandler:completionHandler)
//        completionHandler?(routeStep:nil)
    }
    
    public func update(originCoordinate:CLLocationCoordinate2D) {
        self.updateMap(originCoordinate)
    }
    
    public func update() {
        self.updateMap(CLLocationCoordinate2D())
    }
    
    public func isNewCoordinate(originCoordinate: CLLocationCoordinate2D)->Bool {
        if let lc = self.lastCoordinate {
            return !(originCoordinate.latitude == lc.latitude && originCoordinate.longitude == lc.longitude)
        }
        return true
    }
    
    private func focusMapToShowBothMarkers(coordinate: CLLocationCoordinate2D) {
        self.viewMap?.removeAnnotation(self.userMarker!)
        self.userMarker?.coordinate     = coordinate
        self.viewMap?.addAnnotation(self.userMarker!)
        self.viewMap?.fitMapViewToAnnotationList(self.edgePadding)
    }

//    private func focusMapToShowUserCenter(coordinate: CLLocationCoordinate2D) {
//        self.viewMap?.removeAnnotation(self.userMarker!)
//        self.userMarker?.coordinate     = coordinate
//        self.viewMap?.addAnnotation(self.userMarker!)
//        let region = MKCoordinateRegion(center:coordinate, span: self.viewMap!.region.span)
//        
//        UIView.animateWithDuration(1.0, delay: 0.0, options:[.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
//            self.viewMap?.setRegion(region, animated: true)
//            }, completion: { (fin:Bool) -> Void in
//        })
//        
//    }
//    
//    private func focusMapToShowEventCenter(coordinate: CLLocationCoordinate2D) {
//        if let em = self.eventMarker {
//            self.viewMap?.removeAnnotation(self.userMarker!)
//            self.userMarker?.coordinate = coordinate
//            self.viewMap?.addAnnotation(self.userMarker!)
//            let region = MKCoordinateRegion(center: em.coordinate, span: self.viewMap!.region.span)
//            UIView.animateWithDuration(1.0, delay:0.0, options:[.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
//                self.viewMap?.setRegion(region, animated:true)
//                }) { (fin:Bool) -> Void in
//            }
//        }
//    }
    
    private func clearMarkers() {
        if let em = self.eventMarker {
            self.viewMap?.removeAnnotation(em)
        }
        self.viewMap?.removeAnnotation(self.userMarker!)
    }
    
    public func getDistance(originCoordinate: CLLocationCoordinate2D, travelMode:String, completionHandler: ((routeStep:RouteStep?) -> Void)) {
        if let eventC = self.eventCoordinate {
            
            let directionsRequest = MKDirectionsRequest()
            let markTaipei = MKPlacemark(coordinate: originCoordinate, addressDictionary: nil)
            let markChungli = MKPlacemark(coordinate: eventC, addressDictionary: nil)
            directionsRequest.source = MKMapItem(placemark: markChungli)
            directionsRequest.destination = MKMapItem(placemark: markTaipei)
            directionsRequest.transportType = MKDirectionsTransportType.Automobile
            let directions = MKDirections(request: directionsRequest)
            
            directions.calculateDirectionsWithCompletionHandler({
                response, error in
                
                if error == nil {
                    self.myRoute = response!.routes[0] as MKRoute
                    self.viewMap.addOverlay(self.myRoute.polyline)
                }
                
            })

            
//            self.mapGPS.getDirections(originCoordinate, eventCoordinate:eventC, travelMode:travelMode) { (status, success) -> Void in
//                if status == "OK" {
//                    self.lastCoordinate         = originCoordinate
//                    let rs                      = RouteStep(directions:self.mapGPS.direction, distance:self.mapGPS.totalDistance, duration:self.mapGPS.totalDuration)
//                    completionHandler(routeStep:rs)
//                } else {
//                    completionHandler(routeStep:nil)
//                }
//            }
        } else {
            completionHandler(routeStep:nil)
        }
    }
    
    //MARK: Mapkit delegate
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
    
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.zoomLevel                          = mapView.zoomLevel()
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.zoomLevel                          = mapView.zoomLevel()
    }

}

