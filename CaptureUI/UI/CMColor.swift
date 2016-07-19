//
//  KCColor.swift
//  KropCircleII
//
//  Created by hatebyte on 8/26/14.
//  Copyright (c) 2014 cynicalcocoa. All rights reserved.
//

import UIKit
import Foundation
import CoreImage

extension UIColor {
  
//    public class func greenColorAC()->UIColor {
//        return UIColor(red:0.11, green:0.73, blue:0.57, alpha:1.0);
//    }
//    
//    public class func greenDarkColorAC()->UIColor {
//        return UIColor(red:0.08, green:0.53, blue:0.42, alpha:1.0);
//    }
//    
//    public class func grayColorAC()->UIColor {
//        return UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0);
//    }
//    
//    public class func grayDarkColorAC()->UIColor {
//        return UIColor(red:0.4, green:0.4, blue:0.4, alpha:1.0);
//    }
//    
//    public class func grayDarkestColorAC()->UIColor {
//        return UIColor(red:0.2, green:0.2, blue:0.2, alpha:1.0);
//    }
//    
//    public class func grayLightColorAC()->UIColor {
//        return UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0);
//    }
//   
//    public class func creamAC()->UIColor {
//        return UIColor(red:0.96, green:0.95, blue:0.93, alpha:1.0);
//    }
//
//    public class func twitterColorAC()->UIColor {
//        return UIColor(red: 0.31372, green: 0.6705, blue: 0.945, alpha: 1)
//    }
//    
//    
//    
//    //MARK - WHITE
//    public class func whiteColorCapture()->UIColor {
//        return UIColor(red:0.95, green:0.95, blue:0.95, alpha:1);
//    }
//
//    public class func creamColorCapture()->UIColor {
//        return UIColor(red:0.964706, green:0.952941, blue:0.933, alpha:1);
//    }
//
//    public class func creamDarkColorCapture()->UIColor {
//        return UIColor(red:0.9137, green:0.90196, blue:0.8823, alpha:1);
//    }
//    
//    //MARK - GREEN
//    public class func greenDarkColorCapture()->UIColor {
//        return UIColor(red:0.356, green:0.549, blue:0.176, alpha:1);
//    }
//    
//    public class func greenColorCapture()->UIColor {
//        return UIColor(red:0.11, green:0.73, blue:0.57, alpha:1);
//    }
//
//    //MARK - GREY
//    public class func greyLightExtraColorCapture()->UIColor {
//        return UIColor(red:0.9, green:0.9, blue:0.9, alpha:1);
//    }
//    
//    public class func greyLightColorCapture()->UIColor {
//        return UIColor(red:0.768, green:0.760, blue:0.745, alpha:1);
//    }
//
//    public class func greyColorCapture()->UIColor {
//        return UIColor(red:0.6, green:0.6, blue:0.6, alpha:1);
//    }
//    
//    public class func greyDarkColorCapture()->UIColor {
//        return UIColor(red:0.4, green:0.4, blue:0.4, alpha:1);
//    }
//    
//    public class func greyDarkestColorCapture()->UIColor {
//        return UIColor(red:0.2, green:0.2, blue:0.2, alpha:1);
//    }
//
//
//    //MARK - BLUE
//    public class func blueColorCapture()->UIColor {
//        return UIColor(red:0, green:0.831, blue:0.941, alpha:1);
//    }
//    
//    public class func blueDarkColorCapture()->UIColor {
//        return UIColor(red:0, green:0.247, blue:0.278, alpha:1);
//    }
//
//    public class func blueDarkestColorCapture()->UIColor {
//        return UIColor(red:0, green:0.160, blue:0.180, alpha:1);
//    }
//
//    public class func blueColorTwitter()->UIColor {
//        return UIColor(red:0.31372, green:0.6705, blue:0.945, alpha:1);
//    }
//
//
//    //MARK - BLACK
//    public class func blackColorCapture()->UIColor {
//        return UIColor(red:0.098039, green:0.113725, blue:0.121569, alpha:1);
//    }
//    
//
//    //MARK - PINK
//    public class func pinkColorCapture()->UIColor {
//        return UIColor(red:1.000000, green:0.015686, blue:0.482353, alpha:1);
//    }
//    
//
//
//    //MARK - OTHERS
//    public class func mediaPlaceholderColor()->UIColor {
//        return UIColor(red:0.968627, green:0.968627, blue:0.968627, alpha:1);
//    }
//    
//    public class func tableBackgroundColor()->UIColor {
//        return UIColor(red:0.898039, green:0.898039, blue:0.898039, alpha:1);
//    }
//    
//    public class func navbarDisabledBackgroundColor()->UIColor {
//        return UIColor(red:0.239216, green:0.266667, blue:0.278431, alpha:1);
//    }
//    
//    public class func CMBackgroundColor()->UIColor {
//        return UIColor(red:1, green:1, blue:1, alpha:1);
//    }

    public class func colorWithGreyRGB(rgb:Int, alpha:Float)->UIColor {
        let white = Float(rgb) / 255.0
        return UIColor(white:CGFloat(white), alpha:CGFloat(alpha));
    }
    
    public class func colorWithGreyRGB(rgb:Int)->UIColor {
        return UIColor.colorWithGreyRGB(rgb, alpha:1)
    }

    public class func fromHexString(hex:String)->UIColor {
        return UIColor.fromHexString(hex, alpha:1)
    }
    
    public class func fromHexString(hex:String, alpha:Float)->UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString

        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }

        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }

        var range = NSMakeRange(0, 2)
        let rString = (cString as NSString).substringWithRange(range)

        range.location = 2;
        let gString = (cString as NSString).substringWithRange(range)

        range.location = 4;
        let bString = (cString as NSString).substringWithRange(range)

        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string:rString).scanHexInt(&r)
        NSScanner(string:gString).scanHexInt(&g)
        NSScanner(string:bString).scanHexInt(&b)

        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
    }
  
    func toString()->NSString {
        return self.CIColor.stringRepresentation
    }
    
    func toHexString()->NSString {
        let components = CGColorGetComponents(self.CGColor)
        
        let r:Int = Int(255.0 * components[0]);
        let g:Int = Int(255.0 * components[1]);
        let b:Int = Int(255.0 * components[2]);
        let a:Int = Int(255.0 * components[3]);
        
        return NSString(format:"%02x%02x%02x%02x", r, g, b, a)
    }
    
}



