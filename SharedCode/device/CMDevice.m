//
//  Device.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 3/18/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#include <sys/sysctl.h>
#import "CMDevice.h"
#import "CMDisk.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation CMDevice

//device_token, device_model, device_disk_space, device_battery, app_version, app_name, app_build
+ (NSDictionary *)specs {
    return @{
             @"model"               : [self model],
             @"carrier"             : [self carrier],
             @"disk_space"          : [NSNumber numberWithLongLong:[CMDisk freeDiskSpaceMB]],
             @"battery_percentage"  : [NSNumber numberWithInt:(int)[self battery]],
             @"uuid"                : [self deviceUuid],
             @"hd_video_width"      : [NSNumber numberWithInt:[self hdVideoWidth]],
             @"hd_video_height"     : [NSNumber numberWithInt:[self hdVideoHeight]]
             };
}

+ (int)hdVideoWidth {
    if ([self isLesserPhone]) {
        return -1280;
    } else {
        return 1280;
    }
}

+ (int)hdVideoHeight {
    if ([self isLesserPhone]) {
        return -720;
    } else {
        return 720;
    }
}

+ (NSString *)commonName:(NSString *)machineName {
    NSArray *device = [[CMDevice deviceModelDataForMachineIDs] objectForKey:machineName];
    if (device) {
         return [device componentsJoinedByString:@" "];
    }
    return  @"";
}

+ (NSString *)carrier {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    if ([carrier isEqual:@""] || carrierName == nil) {
        return @"none";
    }
    return carrierName;
}

- (NSDictionary *)deviceSpecs {
    NSMutableDictionary *mutableSpecs                       = [[CMDevice specs] mutableCopy];
    [mutableSpecs removeObjectForKey:@"model"];
    [mutableSpecs removeObjectForKey:@"uudd"];
    NSString *network                                       =([CMDevice isUsingLTE]) ? @"LTE" : @"Wifi";
    [mutableSpecs setObject:network forKey:@"network"];
    return mutableSpecs;
}

+ (BOOL)isUsingLTE {
    CTTelephonyNetworkInfo *networkInfo         = [CTTelephonyNetworkInfo new];
    return [networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE];
}

+ (NSString *)deviceUuid {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)model {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
}

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (double)battery {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    
    [myDevice setBatteryMonitoringEnabled:YES];
    float batLeft = fabsf((float)[myDevice batteryLevel] * 100);

    return batLeft;
}

+ (BOOL)hasFlash:(AVCaptureDeviceInput *)input {
    return [[input device] hasFlash];
}

+ (BOOL)hasWhiteBalance:(AVCaptureDeviceInput *)input {
    AVCaptureDevice *device = [input device];
    return  [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
    [device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance];
}

+ (BOOL)hasTorch:(AVCaptureDeviceInput *)input {
    return [[input device] hasTorch];
}

+ (BOOL)hasFocus:(AVCaptureDeviceInput *)input {
    AVCaptureDevice *device = [input device];
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
    [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
    [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

+ (BOOL)hasExposure:(AVCaptureDeviceInput *)input {
    AVCaptureDevice *device = [input device];
   return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
    [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
    [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

+ (BOOL)isLesserPhone {
    NSString *deviceModel                                                       = [self model];
    return ([deviceModel isEqualToString:IPHONE4] || [deviceModel isEqualToString:IPHONE4S]);
}

+ (NSDictionary*)deviceModelDataForMachineIDs {
    return @{
             
             //iPad.
             @"iPad1,1" : @[ @"iPad 1G", @"Wi-Fi / GSM", @"A1219 / A1337" ],
             @"iPad2,1" : @[ @"iPad 2", @"Wi-Fi", @"A1395" ],
             @"iPad2,2" : @[ @"iPad 2", @"GSM", @"A1396" ],
             @"iPad2,3" : @[ @"iPad 2", @"CDMA", @"A1397" ],
             @"iPad2,4" : @[ @"iPad 2", @"Wi-Fi Rev A", @"A1395" ],
             @"iPad3,1" : @[ @"iPad 3", @"Wi-Fi", @"A1416" ],
             @"iPad3,2" : @[ @"iPad 3", @"GSM+CDMA", @"A1403" ],
             @"iPad3,3" : @[ @"iPad 3", @"GSM", @"A1430" ],
             @"iPad3,4" : @[ @"iPad 4", @"Wi-Fi", @"A1458" ],
             @"iPad3,5" : @[ @"iPad 4", @"GSM", @"A1459" ],
             @"iPad3,6" : @[ @"iPad 4", @"GSM+CDMA", @"A1460" ],
             @"iPad4,1" : @[ @"iPad Air", @"Wi‑Fi", @"A1474" ],
             @"iPad4,2" : @[ @"iPad Air", @"Cellular", @"A1475" ],
             @"iPad5,3" : @[ @"iPad Air 2 ", @"WiFi"],
             @"iPad5,4" : @[ @"iPad Air 2 ", @"GSM+CDMA"],

             //iPadmini
             @"iPad2,5" : @[ @"iPad mini 1G", @"Wi-Fi", @"A1432" ],
             @"iPad2,6" : @[ @"iPad mini 1G", @"GSM", @"A1454" ],
             @"iPad2,7" : @[ @"iPad mini 1G", @"GSM+CDMA", @"A1455" ],
             @"iPad4,4" : @[ @"iPad mini 2G", @"Wi‑Fi", @"A1489" ],
             @"iPad4,5" : @[ @"iPad mini 2G", @"Cellular", @"A1517" ],
             @"iPad4,6" : @[ @"iPad mini 2G", @"China" ],
             @"iPad4,7" : @[ @"iPad mini 3G", @"WiFi" ],
             @"iPad4,8" : @[ @"iPad mini 3G", @"GSM+CDMA" ],
 
             //iPhone.
             @"iPhone1,1" : @[ @"iPhone 2G", @"GSM", @"A1203" ],
             @"iPhone1,2" : @[ @"iPhone 3G", @"GSM", @"A1241 / A13241" ],
             @"iPhone2,1" : @[ @"iPhone 3GS", @"GSM", @"A1303 / A13251" ],
             @"iPhone3,1" : @[ @"iPhone 4", @"GSM", @"A1332" ],
             @"iPhone3,2" : @[ @"iPhone 4", @"GSM Rev A", @"-" ],
             @"iPhone3,3" : @[ @"iPhone 4", @"CDMA", @"A1349" ],
             @"iPhone4,1" : @[ @"iPhone 4S", @"GSM+CDMA", @"A1387 / A14311" ],
             @"iPhone5,1" : @[ @"iPhone 5", @"GSM", @"A1428" ],
             @"iPhone5,2" : @[ @"iPhone 5", @"GSM+CDMA", @"A1429 / A14421" ],
             @"iPhone5,3" : @[ @"iPhone 5C", @"GSM", @"A1456 / A1532" ],
             @"iPhone5,4" : @[ @"iPhone 5C", @"Global", @"A1507 / A1516 / A1526 / A1529" ],
             @"iPhone6,1" : @[ @"iPhone 5S", @"GSM", @"A1433 / A1533" ],
             @"iPhone6,2" : @[ @"iPhone 5S", @"Global", @"A1457 / A1518 / A1528 / A1530" ],
             @"iPhone7,1" : @[ @"iPhone 6", @"Plus" ],
             @"iPhone7,2" : @[ @"iPhone 6" ],
             @"iPhone8,1" : @[ @"iPhone 6S" ],
             @"iPhone8,2" : @[ @"iPhone 6S", @"Plus" ],
             @"iPhone8,4" : @[ @"iPhone 6SE" ],
            
             //iPod.
             @"iPod1,1" : @[ @"iPod touch 1G", @"-", @"A1213" ],
             @"iPod2,1" : @[ @"iPod touch 2G", @"-", @"A1288" ],
             @"iPod3,1" : @[ @"iPod touch 3G", @"-", @"A1318" ],
             @"iPod4,1" : @[ @"iPod touch 4G", @"-", @"A1367" ],
             @"iPod5,1" : @[ @"iPod touch 5G", @"-", @"A1421 / A1509" ]
             
             };
}

@end
