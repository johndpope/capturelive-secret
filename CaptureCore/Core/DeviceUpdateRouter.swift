//
//  DeviceRouter.swift
//  Current
//
//  Created by Scott Jones on 3/25/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum DeviceUpdateRouter:URLRequestConvertible {
    
    case UpdateDevice(deviceUuid:String, params:[String:AnyObject], accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .UpdateDevice(let deviceUuid, let params, let accessCode):
                let deviceParams:[String:AnyObject] = ["device" : params, "access_token":accessCode]
                return ("/mobile/v3/devices/\(deviceUuid).json", .PUT, deviceParams)
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

