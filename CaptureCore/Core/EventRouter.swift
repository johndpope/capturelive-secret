//
//  EventRouter.swift
//  Current
//
//  Created by Scott Jones on 3/26/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum EventRouter:URLRequestConvertible {
    
    case AllEvents(accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .AllEvents(let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken]
                return ("/mobile/v3/events.json", .GET, params)
            }
        }()
        let URL                       = NSURL(string:apiURL)!
        let URLRequest                = NSMutableURLRequest(URL:URL.URLByAppendingPathComponent(result.path))
        URLRequest.HTTPMethod         = result.method.rawValue
        URLRequest.timeoutInterval    = NSTimeInterval(10 * 1000)
        URLRequest.setValue("Accept-Encoding", forHTTPHeaderField:"gzip")
        URLRequest.setValue("Accept", forHTTPHeaderField:"application/json")
        
        let encoding                  = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
    
}