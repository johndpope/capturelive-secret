//
//  CaptureLiveColor.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

import Foundation
import CoreImage
//
//extension UIColor {
//    
//    public class func greenPrimary()->UIColor {
//        return UIColor(red:0.109, green:0.725, blue:0.568, alpha:1.0)
//    }
//    
//    public class func greenSelected()->UIColor {
//        return UIColor(red:0.098, green:0.639, blue:0.501, alpha:1.0)
//    }
//    
//    public class func greenNav()->UIColor {
//        return UIColor(red:0.082, green:0.580, blue:0.454, alpha:1.0)
//    }
//    
//    public class func blueSky()->UIColor {
//        return UIColor(red:0.0, green:0.568627450980392, blue:0.796078431372549, alpha:1.0)
//    }
//    
//    public class func liveStreamRed()->UIColor {
//        return UIColor(red:0.941, green:0.0, blue:0.231, alpha:1.0)
//    }
//
//    public class func whiteMyProfile()->UIColor {
//        return UIColor(red:0.945, green:0.933, blue:0.913, alpha:1.0)
//    }
//
//    public class func whiteAccordianBar()->UIColor {
//        return UIColor(red:0.913, green:0.901, blue:0.882, alpha:1.0)
//    }
//    
//    public class func white()->UIColor {
//        return UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
//    }
//    
//    public class func greyBackground()->UIColor {
//        return UIColor(red:0.972, green:0.972, blue:0.972, alpha:1.0)
//    }
//    
//    public class func inactiveText()->UIColor {
//        return UIColor(red:0.768, green:0.760, blue:0.745, alpha:1.0)
//    }
//    
//    public class func tertiaryTextColor()->UIColor {
//        return UIColor(red:0.576, green:0.568, blue:0.556, alpha:1.0)
//    }
//    
//    public class func secondaryTextColor()->UIColor {
//        return UIColor(red:0.384, green:0.380, blue:0.372, alpha:1.0)
//    }
//    
//    public class func primaryTextColor()->UIColor {
//        return UIColor(red:0.192, green:0.188, blue:0.184, alpha:1.0)
//    }
//    
//}


extension UIColor {
   
    public class func bistre()->UIColor {
        return UIColor(red:49.0 / 255.0, green:48.0 / 255.0, blue:47.0 / 255.0, alpha:1.0)
    }
    
    public class func carmineRed()->UIColor {
        return UIColor(red:240/255.0, green:0/255.0, blue:59/255.0,  alpha:1)
    }
    
    public class func dimGray()->UIColor {
        return UIColor(red:102.0 / 255.0, green:102.0 / 255.0, blue:102.0 / 255.0, alpha:1.0)
    }
   
    public class func dimGrayDark()->UIColor {
        return UIColor(red:98.0 / 255.0, green:97.0 / 255.0, blue:95.0 / 255.0, alpha:1.0)
    }
    
    public class func lapisLazuli()->UIColor {
        return UIColor(red:59/255.0, green:89/255.0, blue:152/255.0,  alpha:1)
    }
    
    public class func richBlueElectric()->UIColor {
        return UIColor(red:0/255.0, green:145/255.0, blue:200/255.0,  alpha:1)
    }
   
    public class func jade()->UIColor {
        return UIColor(red:21/255.0, green:148/255.0, blue:116/255.0,  alpha:1)
    }

    public class func jungleGreen()->UIColor {
        return UIColor(red:25/255.0, green:163/255.0, blue:128/255.0,  alpha:1)
    }

    public class func mountainMeadow()->UIColor {
        return UIColor(red:28.0 / 255.0, green:185.0 / 255.0, blue:145.0 / 255.0, alpha:1.0)
    }
    
    public class func munsell()->UIColor {
        return UIColor(red:241/255.0, green:242/255.0, blue:246/255.0,  alpha:1)
    }
 
    public class func oldLavender()->UIColor {
        return UIColor(red:116/255.0, green:116/255.0, blue:116/255.0, alpha:1.0)
    }

    public class func taupeGray()->UIColor {
        return UIColor(red:147.0 / 255.0, green:145.0 / 255.0, blue:142.0 / 255.0, alpha:1.0)
    }
   
    public class func taupe()->UIColor {
        return UIColor(red:51.0 / 255.0, green:51.0 / 255.0, blue:51.0 / 255.0, alpha:1.0)
    }
    
    public class func silver()->UIColor {
        return UIColor(red:196.0 / 255.0, green:194.0 / 255.0, blue:190.0 / 255.0, alpha:1.0)
    }
 
    public class func platinum()->UIColor {
        return UIColor(red:233.0 / 255.0, green:230.0 / 255.0, blue:225.0 / 255.0, alpha:1.0)
    }
 
    public class func isabelline()->UIColor {
        return UIColor(red:246.0 / 255.0, green:243.0 / 255.0, blue:238.0 / 255.0, alpha:1.0)
    }

    public class func pastelGray()->UIColor {
        return UIColor(red:204.0 / 255.0, green:204.0 / 255.0, blue:204.0 / 255.0, alpha:1.0)
    }
    
    public class func whiteSmoke()->UIColor {
        return UIColor(red:248/255.0, green:248/255.0, blue:248/255.0,  alpha:1)
    }

    
}


/*
 GreenPrimary
 UIColor(red:0.109, green:0.725, blue:0.568, alpha:1.0)
 
 GreenPrimary Selected
 UIColor(red:0.0980392156862745, green:0.63921568627451, blue:0.501960784313725, alpha:1.0)
 
 GreenPrimary Nav
 UIColor(red:0.0823529411764706, green:0.580392156862745, blue:0.454901960784314, alpha:1.0)
 
 Blue Sky
 UIColor(red:0.0, green:0.568627450980392, blue:0.796078431372549, alpha:1.0)
 
 Live Stream Red
 UIColor(red:0.941176470588235, green:0.0, blue:0.231372549019608, alpha:1.0)
 
 White My Profile
 UIColor(red:0.945098039215686, green:0.933333333333333, blue:0.913725490196078, alpha:1.0)
 
 White Accordian Bars
 UIColor(red:0.913725490196078, green:0.901960784313726, blue:0.882352941176471, alpha:1.0)
 
 White
 UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
 
 Gray BG
 UIColor(red:0.972549019607843, green:0.972549019607843, blue:0.972549019607843, alpha:1.0)
 
 Inactive text color
 UIColor(red:0.768627450980392, green:0.76078431372549, blue:0.745098039215686, alpha:1.0)
 
 Tertiary text color
 UIColor(red:0.576470588235294, green:0.568627450980392, blue:0.556862745098039, alpha:1.0)
 
 Secondary text color
 UIColor(red:0.384313725490196, green:0.380392156862745, blue:0.372549019607843, alpha:1.0)
 
 Primary text color
 UIColor(red:0.192156862745098, green:0.188235294117647, blue:0.184313725490196, alpha:1.0)
 
 */