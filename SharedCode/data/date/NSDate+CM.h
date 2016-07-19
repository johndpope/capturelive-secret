//
//  NSDate+CM.h
//  CaptureMedia-Library
//
//  Created by hatebyte on 5/1/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CM)

- (NSString*)timeAgoWithDate;
+ (NSDate *)dateFromString:(NSString *)string;
- (NSString *)dateTimeString;
+ (NSDate *)dateForUnixString:(NSString *)timestamp;
+ (NSDate *)microSecondsStringToDate:(NSString *)timestamp;
- (long double)inMicroSeconds;
- (NSString *)inMicroSecondsString;
- (NSString *)inUnixSecondsString;
- (NSString *)timeStamp;
- (NSString *)timeString;
- (NSString *)clockString;
//- (NSString *)folderNameFormat;
//- (NSString *)s3NameFormat;

@end
