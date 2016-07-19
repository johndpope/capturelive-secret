//
//  UIColor+CM.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

extension UIColor {
    
    public class func blackCurrent(percent:Float)->UIColor {
        return UIColor(red: 35.0 / 255.0, green: 32.0 / 255.0, blue: 30.0 / 255.0, alpha: CGFloat(percent))
    }
    
    public class func whiteCurrent()->UIColor {
        return UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    }
    
    public class func whiteCurrent(percent:Float)->UIColor {
        return UIColor(red:1.0, green:1.0, blue:1.0, alpha:CGFloat(percent))
    }
    
    public class func blueCurrent(percent:Float)->UIColor {
        return UIColor(red:0.156, green:0.294, blue:0.862, alpha:CGFloat(percent))
    }
    
    public class func blueLightCurrent()->UIColor {
        return UIColor(red:0.156, green:0.294, blue:0.862, alpha:0.5)
    }
    
    public class func greyCurrent()->UIColor {
        return UIColor(red:0.549, green:0.537, blue:0.529, alpha:1.0)
    }
    
    public class func greyDarkCurrent()->UIColor {
        return UIColor(red:0.549, green:0.537, blue:0.529, alpha:1.0)
    }
    
    public class func greyLightCurrent()->UIColor {
        return UIColor(red:0.749, green:0.737, blue:0.729, alpha:1.0)
    }
    
    public class func greyPinkishCurrent()->UIColor {
        return UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
    }

    public class func redCurrent()->UIColor {
        return UIColor(red:0.960, green:0.333, blue:0.294, alpha:1.0)
    }
    
    public class func redLightCurrent()->UIColor {
        return UIColor(red:0.960, green:0.333, blue:0.294, alpha:0.5)
    }
    
    public class func greenCurrent()->UIColor {
        return UIColor(red:0.0, green:0.772, blue:0.482, alpha:1.0)
    }
    
    public class func greenLightCurrent()->UIColor {
        return UIColor(red:0.0, green:0.772, blue:0.482, alpha:0.5)
    }

    public class func blueCurrent() -> UIColor {
        return UIColor(red: 40.0 / 255.0, green: 75.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
    }
    
    public class func greyAluminumCurrent() -> UIColor {
        return UIColor(white: 153.0 / 255.0, alpha: 1.0)
    }
    
    public class func greyIronCurrent() -> UIColor {
        return UIColor(white: 204.0 / 255.0, alpha: 1.0)
    }
    
    public class func blackCurrent() -> UIColor {
        return UIColor(red: 35.0 / 255.0, green: 32.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
    }
    
    public class func greyMineshaftCurrent() -> UIColor {
        return UIColor(white: 51.0 / 255.0, alpha: 1.0)
    }
    
    public class func greenConfirmCurrent() -> UIColor {
        return UIColor(red: 123.0 / 255.0, green: 194.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
    }
    
    public class func greyLightestCurrent() -> UIColor {
        return UIColor(white: 242.0 / 255.0, alpha: 1.0)
    }
    
    public class func greySteelCurrent() -> UIColor {
        return UIColor(white: 102.0 / 255.0, alpha: 1.0)
    }
    
    public class func yellowCurrent() -> UIColor {
        return UIColor(red: 255.0 / 255.0, green: 225.0 / 255.0, blue: 0.0, alpha: 1.0)
    }


}
