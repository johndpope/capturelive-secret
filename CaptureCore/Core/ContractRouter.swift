//
//  ContractRouter.swift
//  Current
//
//  Created by Scott Jones on 3/27/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum ContractRouter:URLRequestConvertible {
   
    public enum HistoryFilter:String {
        case All                = "all"
        case Completed          = "completed"
        case PublisherCanceled  = "publisher_canceled"
        case UserCanceled       = "user_canceled"
    }
    
    case FetchContract(contractUrlHash:String, accessToken:String)
    case CreateContract(eventUrlHash:String, accessToken:String)
    case DeleteContract(urlHash:String, accessToken:String)
    case UpdateContract(urlHash:String, contract:[String:AnyObject], accessToken:String)
    case JobHistory(filter:HistoryFilter, accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .FetchContract(let contractUrlHash, let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken]
                return ("/mobile/v3/contracts/\(contractUrlHash)", .GET, params)
            case .CreateContract(let eventUrlHash, let accessToken):
                let contract          = ["event_url_hash" : eventUrlHash]
                let params:[String:AnyObject] = ["access_token":accessToken, "contract":contract]
                return ("/mobile/v3/contracts.json", .POST, params)
            case .DeleteContract(let urlHash, let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken]
                return ("mobile/v3/contracts/\(urlHash).json", .DELETE, params)
            case .UpdateContract(let urlHash, let contract, let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken, "contract":contract]
                return ("mobile/v3/contracts/\(urlHash).json", .PUT, params)
            case .JobHistory(let filter, let accessToken):
                let params:[String:AnyObject] = ["access_token":accessToken, "filter":filter.rawValue, "per_page":50]
                return ("/mobile/v3/job_history", .GET, params)
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