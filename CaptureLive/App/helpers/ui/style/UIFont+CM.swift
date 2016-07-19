//
//  UIFont+CM.swift
//  Capture-Live
//
//  Created by hatebyte on 7/7/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public enum CMFont : String {
    case Thin                       = "ProximaNova-Thin"
    case Light                      = "ProximaNova-Light"
    case Regular                    = "ProximaNova-Regular"
    case Bold                       = "ProximaNova-Bold"
}

public enum CMFontSize : CGFloat {
    case XSmall                     = 10
    case Small                      = 12
    case Medium                     = 15
    case Large                      = 18
    case XLarge                     = 22
    case XLarge28                   = 28
    case XXLarge                    = 32
}

public enum CMUIFontSize : CGFloat {
    case NavigationTitle            = 16
}

public enum CMFontComfortaa : String {
    case Light                      = "Comfortaa-Light"
    case Regular                    = "Comfortaa-Regular"
    case Bold                       = "Comfortaa-Bold"
}

public enum CMFontSourceSansPro : String {
    case Bold                       = "SourceSansPro-Bold"
    case BoldItalic                 = "Source-Sans-Pro-BoldItalic"
    case ExtraLight                 = "SourceSansPro-ExtraLight"
    case ExtraLightItalic           = "SourceSansPro-ExtraLightIt"
    case Italic                     = "SourceSansPro-It"
    case Light                      = "SourceSansPro-Light"
    case LightItalic                = "SourceSansPro-LightIt"
    case Regular                    = "SourceSansPro-Regular"
    case SemiBold                   = "SourceSansPro-Semibold"
    case SemiBoldItalic             = "SourceSansPro-SemiboldIt"
}

extension UIFont {

    public class func comfortaa(comfortaa: CMFontComfortaa, size fontSize: CMFontSize)->UIFont {
        return UIFont(name: comfortaa.rawValue, size: fontSize.rawValue)!
    }
    
    public class func comfortaa(comfortaa: CMFontComfortaa, size fontSize: CMUIFontSize)->UIFont {
        return UIFont(name: comfortaa.rawValue, size: fontSize.rawValue)!
    }
    
    public class func sourceSansPro(sourceSansPro: CMFontSourceSansPro, size fontSize: CMFontSize)->UIFont {
        return UIFont(name: sourceSansPro.rawValue, size: fontSize.rawValue)!
    }
    
    public class func comfortaa(comfortaa: CMFontComfortaa, size fontSize: CGFloat)->UIFont {
        return UIFont(name: comfortaa.rawValue, size: fontSize)!
    }
    
    public class func sourceSansPro(sourceSansPro: CMFontSourceSansPro, size fontSize: CGFloat)->UIFont {
        return UIFont(name: sourceSansPro.rawValue, size: fontSize)!
    }

    public func sizeOfString(string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
    
}