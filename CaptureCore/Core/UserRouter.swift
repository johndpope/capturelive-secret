//
//  UserRouter.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum UserRouter:URLRequestConvertible {
    
    case GetUser(accessToken:String)
    case UpdateUser(user:[String:AnyObject], accessToken:String)
    case LogOutUser(accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .GetUser(let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken]
                return ("/mobile/v3/users/me.json", .GET, params)
            case .UpdateUser(let user, let accessToken):
                let params:[String:AnyObject] = ["user":user, "access_token":accessToken]
                return ("/mobile/v3/users/me.json", .PUT, params.union(credientals))
            case .LogOutUser(let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken]
                return ("/mobile/v3/logout", .DELETE, params.union(credientals))
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
