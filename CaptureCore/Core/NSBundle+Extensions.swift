//
//  CoreBundle.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

extension NSBundle {
    
    public static var CoreBundle:NSBundle {
        return NSBundle(forClass:CaptureLiveAlamoFireService.self)
    }
    
    public func stringValue(key:String)->String {
        guard let cid = objectForInfoDictionaryKey(key) as? String else { fatalError("There is no value for key : \(key)") }
        return cid
    }
    
}

extension NSBundle {
    
    public var appVersion:String {
        return self.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    public var appIdentifier:String {
        return self.bundleIdentifier!
    }
    
    public var appName:String {
        return self.objectForInfoDictionaryKey("CFBundleDisplayName") as! String
    }
 
    public var appBuild:String {
        return self.objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
}
