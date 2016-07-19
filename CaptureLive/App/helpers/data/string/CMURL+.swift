//
//  ACStrings.swift
//  CaptureMedia-Acme
//
//  Created by hatebyte on 9/25/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

import UIKit

enum CaptureAppNotification : String {
    case Login                      = "com.capturemedia.app.notification.login"
    case Logout                     = "com.capturemedia.app.notification.logout"
    case OnboardingDone             = "com.capturemedia.app.notification.onboarding.done"
}

enum UrlParam : String {
    case Event                      = "event"
    case NilParam                   = "nil_param"
}

enum ParamValues {
    case KeyFound(value:String)
    case NoKey
}

typealias ParamFor = (key:UrlParam)->ParamValues

extension NSURL {
   
    var paramFor:ParamFor {
        get {
//            if #available(iOS 8, *) {
                return self.paramForIOS8
//            } else {
//                return self.paramForIOS7
//            }
        }
    }
   
    func deepLinkHash()->String? {
        let absString               =  (absoluteString as NSString)
        if absString.pathComponents.count > 2 {
            let c                   = absString.pathComponents.count
            let r                   = absString.pathComponents[c - 2]
            if r == "r" {
                return absString.pathComponents.last
            }
        }
        return nil
    }
    
    func safariHash()->String? {
        let absString               =  (absoluteString as NSString)
        if absString.pathComponents.count > 2 {
            let c                   = absString.pathComponents.count
            let r                   = absString.pathComponents[c - 2]
            if r == "contracts" {
                return absString.pathComponents.last
            }
        }
        return nil
    }
 
    func eventParam()->UInt64 {
        let e = self.paramFor(key:.Event)
        switch e {
        case ParamValues.KeyFound(let value):
            if let v = Int(value) {
                return UInt64(v)
            } else {
                return 0
            }
        case ParamValues.NoKey:
            return 0
        }
    }
    
    @available(iOS 8, *)
    func paramForIOS8(key:UrlParam)->ParamValues {
        if let urlComponents        = NSURLComponents(URL:self, resolvingAgainstBaseURL:true) {
            if let items = urlComponents.queryItems {
                for item in items {
                    if item.name == key.rawValue {
                        return .KeyFound(value:item.value!)
                    }
                }
            }
        }
        return .NoKey
    }

    @available(iOS 7, *)
    func paramForIOS7(key:UrlParam)->ParamValues {
        if let paramString = self.query {
            let pairs = paramString.componentsSeparatedByString("&") as [String]
            for pair in pairs  {
                let pairComp = pair.componentsSeparatedByString("=") as [String]
                let k = pairComp.first?.stringByRemovingPercentEncoding
                if k == key.rawValue {
                    let value = pairComp.last?.stringByRemovingPercentEncoding
                    return .KeyFound(value:value!)
                }
            }
        }
        return .NoKey
    }
   
}