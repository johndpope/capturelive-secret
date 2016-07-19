//
//  Device.h
//  CaptureMedia-Library
//
//  Created by hatebyte on 3/18/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

static NSString *SIMULATOR                              = @"i386";      // on the simulator
static NSString *iPODTOUCH_1                            = @"iPod1,1";   // on iPod Touch
static NSString *iPODTOUCH_2                            = @"iPod2,1";   // on iPod Touch Second Generation
static NSString *iPODTOUCH_3                            = @"iPod3,1";   // on iPod Touch Third Generation
static NSString *iPODTOUCH_4                            = @"iPod4,1";   // on iPod Touch Fourth Generation
static NSString *iPODTOUCH_5                            = @"iPod5,1";   // on iPod Touch Fourth Generation
static NSString *iPAD_1                                 = @"iPad1,1";   // on iPad
static NSString *iPAD_2                                 = @"iPad2,1";   // on iPad 2
static NSString *iPAD_3                                 = @"iPad3,1";   // on 3rd Generation iPad
static NSString *IPHONE4                                = @"iPhone3,3"; // on iPhone 4
static NSString *IPHONE4S                               = @"iPhone4,1"; // on iPhone 4S
static NSString *IPHONE5_A1428                          = @"iPhone5,1"; // on iPhone 5 (model A1428, AT&T/Canada)
static NSString *IPHONE5_A1429                          = @"iPhone5,2"; // on iPhone 5 (model A1429, everything else)
static NSString *IPHONE5c_GSM                           = @"iPhone5,3"; // on iPhone 5c (model A1456, A1532 | GSM)
static NSString *IPHONE5c                               = @"iPhone5,4"; // on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
static NSString *iPAD_4                                 = @"iPad3,4";   // on 4th Generation iPad
static NSString *IPAD_MINI                              = @"iPad2,5";   // on iPad Mini
static NSString *IPHONE5S_GSM                           = @"iPhone6,1"; // on iPhone 5s (model A1433, A1533 | GSM)
static NSString *IPHONE5S                               = @"iPhone6,2"; // on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
static NSString *iPAD_AIR_WIFI                          = @"iPad4,1";   // on 5th Generation iPad (iPad Air) - Wifi
static NSString *iPAD_AIR_CELLULAR                      = @"iPad4,2";   // on 5th Generation iPad (iPad Air) - Cellular
static NSString *iPAD_MINI_2__WIFI                      = @"iPad4,4";   // on 2nd Generation iPad Mini - Wifi
static NSString *iPAD_AIR_2_CELLULAR                    = @"iPad4,5";   // on 2nd Generation iPad Mini - Cellular

@interface CMDevice : NSObject

+ (NSDictionary *)specs;
+ (NSString *)commonName:(NSString *)machineName;
+ (NSString *)carrier;
+ (NSString *)model;
+ (NSString *)systemVersion;
+ (NSString *)deviceUuid;
+ (BOOL)isUsingLTE;
+ (double)battery;
+ (BOOL)hasFlash:(AVCaptureDeviceInput *)input;
+ (BOOL)hasWhiteBalance:(AVCaptureDeviceInput *)input;
+ (BOOL)hasTorch:(AVCaptureDeviceInput *)input;
+ (BOOL)hasFocus:(AVCaptureDeviceInput *)input;
+ (BOOL)hasExposure:(AVCaptureDeviceInput *)input;
+ (BOOL)isLesserPhone;
+ (int)hdVideoWidth;
+ (int)hdVideoHeight;

@end
