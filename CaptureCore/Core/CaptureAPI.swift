//
//  CaptureAPI.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public protocol CaptureAPITokens {
    var clientID:String { get }
    var clientSecret:String { get }
    var apiURL:String { get }
}

extension NSBundle:CaptureAPITokens {
    
    public var clientID:String {
        return stringValue("ClientId")
    }
    
    public var clientSecret:String {
        return stringValue("ClientSecret")
    }
    
    public var apiURL:String {
        return stringValue("ApiUrl")
    }
    
    
    public var wwwURL:String {
        return stringValue("WWWUrl")
    }
    
}

