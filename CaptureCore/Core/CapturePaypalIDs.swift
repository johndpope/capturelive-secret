//
//  File.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public protocol CurrentPaypalTokens {
    var sandboxClientId:String { get }
    var clientId:String { get }
}

extension NSBundle: CurrentPaypalTokens {
    
    public var sandboxClientId:String {
        return stringValue("PaypalClientSandboxId")
    }
    
    public var clientId:String {
        return stringValue("PaypalClientId")
    }
    
}