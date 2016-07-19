//
//  UIBundle+HockeyApp.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/2/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureCore


extension NSBundle {
    public static var AppBundle:NSBundle {
        return NSBundle(forClass:AppDelegate.self)
    }
}


public protocol HockeySDK {

    var hockeyAppId:String { get }

}

extension NSBundle:HockeySDK {
    
    public var hockeyAppId:String {
        return stringValue("HockeyAppId")
    }
    
}
