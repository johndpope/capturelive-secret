//
//  AttachmentRouter.swift
//  Current
//
//  Created by Scott Jones on 4/4/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import Alamofire
import CaptureModel

public enum AttachmentRouter:URLRequestConvertible {
    
    case UpdateAttachment(uuid:String, contractUrlHash:String, attachmentJSON:[String:AnyObject], accessToken:String)
    case UpdateRemoteRemoteFile(uuid:String, remoteFileJSON:[String:AnyObject], accessToken:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .UpdateAttachment(let uuid, let contractUrlHash, let attachmentJSON, let accessToken):
                let contract            = ["attachment" : attachmentJSON]
                let params:[String:AnyObject] = ["access_token":accessToken, "contract":contract]
                return ("/mobile/v3/contracts/\(contractUrlHash)/attachments/\(uuid).json", .PUT, params)
            case .UpdateRemoteRemoteFile(let uuid, let remoteFileJSON, let accessToken):
                let attachment          = ["hd_chunk": remoteFileJSON]
                let params:[String:AnyObject] = ["access_token":accessToken, "attachment":attachment]
                return ("/mobile/v3/attachments/\(uuid)/hd_chunks.json", .POST, params)
            }
        }()
        let URL                         = NSURL(string:apiURL)!
        let URLRequest                  = NSMutableURLRequest(URL:URL.URLByAppendingPathComponent(result.path))
        URLRequest.HTTPMethod           = result.method.rawValue
        URLRequest.timeoutInterval      = NSTimeInterval(10 * 1000)
        URLRequest.setValue("Accept-Encoding", forHTTPHeaderField:"gzip")
        URLRequest.setValue("Accept", forHTTPHeaderField:"application/json")
        
        let encoding                    = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
    
}