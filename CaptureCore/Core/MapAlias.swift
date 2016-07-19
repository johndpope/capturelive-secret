//
//  MapAlias.swift
//  Current
//
//  Created by Scott Jones on 12/15/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import CoreLocation

public typealias RouteStep = (directions:String, distance:String, duration:String)
public typealias UpdateClosure = (CLLocationCoordinate2D)->()
public typealias EventPin = ()->UIImage
public typealias RouteClosure = (routeStep:RouteStep?)->()
public typealias UpdateMap = (style:CMGMStyle)->()

public enum CMGMStyle : Int {
    case UserCentered
    case EventCentered
    case RequestOpen
    case RequestClosed
    case UserHired
    case Approaching
    case Arrived
}

public class CMGoogleRouteFetcher {
    
    var selectedRoute:Dictionary<NSObject, AnyObject>?
    var overviewPolyline:Dictionary<NSObject, AnyObject>?
    var totalDuration:String!
    var totalDistance:String!
    var originAddress:String!
    
    let baseURLDirections                   = "https://maps.googleapis.com/maps/api/directions/json?"
    var totalDistanceInMeters:UInt          = 0
    var totalDurationInSeconds:UInt         = 0
    var direction:String                    = "Unknown"
    
    public func getDirections(originCoordinate: CLLocationCoordinate2D, eventCoordinate: CLLocationCoordinate2D, travelMode:String = "driving", completionHandler: ((status: String, success: Bool) -> Void)) {
        let directionsURLString             = self.baseURLDirections + "origin=\(originCoordinate.latitude),\(originCoordinate.longitude)&destination=\(eventCoordinate.latitude),\(eventCoordinate.longitude)&mode=\(travelMode)"
        let directionsURL                   = NSURL(string: directionsURLString)!
       
        print(directionsURL.absoluteString)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            if let dictionary = self.returnContentsOfURL(directionsURL) {
                let status = dictionary["status"] as! String
                if status == "OK" {
                    self.totalDuration      = ""
                    self.totalDistance      = ""
                    self.direction          = ""
                    self.overviewPolyline   = nil
                    
                    if let routes = dictionary["routes"] {
                        self.selectedRoute      = (routes as! Array<Dictionary<NSObject, AnyObject>>)[0]
                        if let ovp = self.selectedRoute?["overview_polyline"] {
                            self.overviewPolyline   = ovp as? Dictionary<NSObject, AnyObject>
                        }
                        
                        if let ls = self.selectedRoute?["legs"] {
                            print(ls)

                            let legs                = ls as? Array<Dictionary<NSObject, AnyObject>>
                            self.originAddress      = legs?[0]["start_address"] as? String
                            
                            if let s = legs?[0]["steps"] {
                                let steps               = s as! Array<Dictionary<NSObject, AnyObject>>
                                self.calculateTotalDistanceAndDuration()
                                
                                if let dir = steps[0]["html_instructions"] {
                                    let dHtml           = dir as! String
                                    self.direction      = dHtml.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                                }
                            }
                        }
                        
                    }
                    
                    if self.totalDuration != "" && self.totalDistance != "" && self.overviewPolyline != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completionHandler(status:status, success: true)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completionHandler(status: "Request.FAILED", success: false)
                        })
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(status: "Request.FAILED", success: false)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(status: "Request.FAILED", success: false)
                })
            }
        })
    }
    
    internal func returnContentsOfURL(url:NSURL)->NSDictionary? {
        do {
            // Try parsing some valid JSON
            if let directionsData = NSData(contentsOfURL: url) {
                let dictionary              = try NSJSONSerialization.JSONObjectWithData(directionsData, options: [] ) as! NSDictionary
                return dictionary
            }
        }
        catch let error as NSError {
            // Catch fires here, with an NSError being thrown from the JSONObjectWithData method
            print("A JSON parsing error occurred, here are the details:\n \(error)")
        }
        return nil
    }
    
    private func calculateTotalDistanceAndDuration() {
        let legs                            = self.selectedRoute?["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        totalDistanceInMeters               = 0
        totalDurationInSeconds              = 0
        
        for leg in legs {
            totalDistanceInMeters           += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds          += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        let distanceInMiles: Double         = Double(Double(totalDistanceInMeters) * 0.000621371)
        totalDistance                       = "\(distanceInMiles)"//"Total Distance: \(distanceInMiles) miles"
        
        let mins                            = totalDurationInSeconds / 60
        let hours                           = mins / 60
        let days                            = hours / 24
        let remainingHours                  = hours % 24
        let remainingMins                   = mins % 60
        let remainingSecs                   = totalDurationInSeconds % 60
        
        //        var str = ""
        //        if days > 0 {
        //            str += "\(days) d"
        //        }
        //        if remainingHours > 0 {
        //            if str.characters.count > 0 { str += ", " }
        //            str += "\(remainingHours) hrs"
        //        }
        //        if remainingMins > 0 {
        //            if str.characters.count > 0 { str += ", " }
        //            str += "\(remainingMins) mins"
        //        }
        //        if remainingSecs > 0 {
        //            if str.characters.count > 0 { str += ", " }
        //            str += "\(remainingSecs) secs"
        //        }
        //        totalDuration                       = str
        if days > 0 {
            let s = (days == 0) ? "" : "s"
            totalDuration = "You're \(days) day\(s) away"
            return
        }
        if remainingHours > 0 {
            let s = (remainingHours == 0) ? "" : "s"
            totalDuration  = "You're \(remainingHours) hour\(s) away"
            return
        }
        if remainingMins > 0 {
            let s = (remainingMins == 0) ? "" : "s"
            totalDuration  = "You're \(remainingMins) min\(s) away"
            return
        }
        if remainingSecs > 0 {
            let s = (remainingSecs == 0) ? "" : "s"
            totalDuration  =  "You're \(remainingSecs) sec\(s) away"
            return
        }
    }
    

}
