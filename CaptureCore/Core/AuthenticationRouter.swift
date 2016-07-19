//
//  UrlRouter.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum AuthenticationRouter:URLRequestConvertible {
   
    case TempToken
    case RequestCode(number:String, accessCode:String)
    case Authorize(number:String, code:String)
    case Logout(accessCode:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .TempToken:
                let params:[String:AnyObject] = ["grant_type":"client_credentials"]
                return ("/oauth/token", .POST, params.union(credientals))
            case .RequestCode(let number, let accessCode):
                let params:[String:AnyObject] = ["phone_number":number, "access_token":accessCode]
                return ("/mobile/v3/phones", .POST, params)
            case .Authorize(let number, let code):
                let params:[String:AnyObject] = ["grant_type": "password", "phone_number":number, "phone_access_token":code]
                return ("/oauth/token", .POST, params.union(credientals))
            case .Logout(let accessCode):
                let params:[String:AnyObject] = ["access_token":accessCode]
                return ("/mobile/v3/logout", .POST, params)
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

extension URLRequestConvertible {

    var apiURL:String {
        return "https://" + NSBundle(forClass:CaptureLiveAlamoFireService.self).apiURL
    }
    var credientals:[String:AnyObject] {
        let bundle = NSBundle(forClass:CaptureLiveAlamoFireService.self)
        return ["client_id":bundle.clientID, "client_secret":bundle.clientSecret]
    }

}















