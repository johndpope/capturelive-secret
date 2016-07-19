//
//  UIFont+CM.swift
//  Capture-Live
//
//  Created by hatebyte on 7/7/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

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

public enum CMFontProxima : String {
    case RegularItalic              = "ProximaNova-RegularIt"
    case Thin                       = "ProximaNova-Thin"
    case LightItalic                = "ProximaNova-LightIt"
    case Light                      = "ProximaNova-Light"
    case Regular                    = "ProximaNova-Regular"
    case Black                      = "ProximaNova-Black"
    case ExtraBlack                 = "ProximaNova-Extrabld"
    case Bold                       = "ProximaNova-Bold"
    case BoldItalic                 = "ProximaNova-BoldIt"
    case SemiBoldItalic             = "ProximaNova-SemiboldIt"
    case SemiBold                   = "ProximaNova-Semibold"
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

    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor()
            .fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(.TraitBold, .TraitCondensed)
    }

    public class func proxima(proxima: CMFontProxima, size fontSize: CMFontSize)->UIFont {
        return UIFont(name: proxima.rawValue, size: fontSize.rawValue)!
    }
    
    public class func comfortaa(comfortaa: CMFontComfortaa, size fontSize: CMFontSize)->UIFont {
        return UIFont(name: comfortaa.rawValue, size: fontSize.rawValue)!
    }
    
    public class func comfortaa(comfortaa: CMFontComfortaa, size fontSize: CMUIFontSize)->UIFont {
        return UIFont(name: comfortaa.rawValue, size: fontSize.rawValue)!
    }
    
    public class func sourceSansPro(sourceSansPro: CMFontSourceSansPro, size fontSize: CMFontSize)->UIFont {
        return UIFont(name: sourceSansPro.rawValue, size: fontSize.rawValue)!
    }
    
    public class func proxima(proxima: CMFontProxima, size fontSize: CGFloat)->UIFont {
        return UIFont(name: proxima.rawValue, size: fontSize)!
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

// MARK:- Fonts Sizes
public struct FontSizes {
    public static var s6 : CGFloat {
        return 6.0+self.delta
    }
    public static var s7 : CGFloat {
        return 7.0+self.delta
    }
    public static var s8 : CGFloat {
        return 8.0+self.delta
    }
    public static var s9 : CGFloat {
        return 9.0+self.delta
    }
    public static var s10 : CGFloat {
        return 10.0+self.delta
    }
    public static var s11 : CGFloat {
        return 11.0+self.delta
    }
    public static var s12 : CGFloat {
        return 12.0+self.delta
    }
    public static var s13 : CGFloat {
        return 13.0+self.delta
    }
    public static var s14 : CGFloat {
        return 14.0+self.delta
    }
    public static var s15 : CGFloat {
        return 16.0+self.delta
    }
    public static var s16 : CGFloat {
        return 16.0+self.delta
    }
    public static var s17 : CGFloat {
        return 17.0+self.delta
    }
    public static var s18 : CGFloat {
        return 18.0+self.delta
    }
    public static var s19 : CGFloat {
        return 19.0+self.delta
    }
    public static var s20 : CGFloat {
        return 20.0+self.delta
    }
    public static var s21 : CGFloat {
        return 21.0+self.delta
    }
    public static var s22 : CGFloat {
        return 22.0+self.delta
    }
    public static var s23 : CGFloat {
        return 23.0+self.delta
    }
    public static var s24 : CGFloat {
        return 24.0+self.delta
    }
    public static var s27 : CGFloat {
        return 27.0+self.delta
    }
    public static var s36 : CGFloat {
        return 36.0+self.delta
    }
    public static var s44 : CGFloat {
        return 44.0+self.delta
    }
    public static var delta : CGFloat {
        if UIDevice.isDeviceWithHeight480() {
            return 0;
        }else if UIDevice.isDeviceWithHeight568() {
            return 1;
        }else if UIDevice.isDeviceWithHeight667() {
            return 2;
        }else{
            return 3;
        }
    }
}



extension UIDevice {
    class func isDeviceWithWidth320 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.width == CGFloat(320.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithWidth375 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.width == CGFloat(375.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithWidth414 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.width == CGFloat(414.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithHeight480 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.height == CGFloat(480.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithHeight568 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.height == CGFloat(568.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithHeight667 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.height == CGFloat(667.0) {
                return true;
            }
        }
        return false;
    }
    
    class func isDeviceWithHeight736 () -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.height == CGFloat(736.0) {
                return true;
            }
        }
        return false;
    }
}
