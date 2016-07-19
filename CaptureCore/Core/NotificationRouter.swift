//
//  NotificationRouter.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum NotificationRouter:URLRequestConvertible {
    
    case UnreadNotifications(accessToken:String)
    case UpdateRemoteNotification(notificationHash:String, readDate:NSDate, accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .UnreadNotifications(let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken, "read":false]
                return ("/mobile/v3/push_notifications/", .GET, params)
            case .UpdateRemoteNotification(let notificationHash, let readDate, let accessToken):
                let notification = ["unix_read_at": readDate.timeIntervalSince1970]
                let params:[String:AnyObject] = ["access_token":accessToken, "push_notification":notification]
                return ("/mobile/v3/push_notifications/\(notificationHash).json", .PUT, params)
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