//
//  CMMKAnnotation.swift
//  Current-Tools
//
//  Created by Scott Jones on 12/8/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import MapKit
import UIKit
import CaptureUI

public protocol CMMKAnnotation: MKAnnotation {

    func identifier()->String
    func image()->UIImage?

}

public class CMAnnotation: NSObject, CMMKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate                     = coordinate
    }
    
    public func image()->UIImage? {
        return nil
    }
    
    public func identifier()->String {
        return "CMAnnotation"
    }
    
}

public class CMEnrouteAnnotation: CMAnnotation {
    
    public override func image()->UIImage? {
        return UIImage(named:"event_pin")!
    }

    public override func identifier()->String {
        return "CMEnrouteAnnotation"
    }

}

public class CMArrivedAnnotation: CMAnnotation {
    
    public override func image()->UIImage? {
        return UIImage(named:"event_pin_large_onLocation")!
    }
    
    public override func identifier()->String {
        return "CMArrivedAnnotation"
    }

}


public class CMUserAnnotation: CMAnnotation {
    
    let avatarPathString:String!
    var userIcon:UIImage?

    public init(avatarPathString:String, coordinate: CLLocationCoordinate2D) {
        self.avatarPathString           = avatarPathString
        super.init(coordinate: coordinate)
        CMImageCache.defaultCache().imageForPath(self.avatarPathString, complete: { (error:NSError!, image:UIImage!) -> Void in
            if error == nil {
                self.userIcon           = CMUserMarker.circleImage(image)
            }
        })
    }

    public override func image()->UIImage? {
        return self.userIcon
    }

    public override func identifier()->String {
        return "CMUserAnnotation"
    }

}
