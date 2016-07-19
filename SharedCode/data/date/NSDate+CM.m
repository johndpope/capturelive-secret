//
//  NSDate+CM.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 5/1/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "NSDate+CM.h"

@implementation NSDate (CM)

- (NSString*)timeAgoWithDate {
    NSDictionary *timeScale                         = @{@"second"   :@1,
                                                        @"minute"   :@60,
                                                        @"hour"     :@3600,
                                                        @"day"      :@86400,
                                                        @"week"     :@605800,
                                                        @"month"    :@2629743,
                                                        @"year"     :@31556926};
    NSString *scale;
    int timeAgo                                     = 0-(int)[self timeIntervalSinceNow];
    if (timeAgo < 60) {
        scale                                       = @"second";
    } else if (timeAgo < 3600) {
        scale                                       = @"minute";
    } else if (timeAgo < 86400) {
        scale                                       = @"hour";
    } else if (timeAgo < 605800) {
        scale                                       = @"day";
    } else if (timeAgo < 2629743) {
        scale                                       = @"week";
    } else if (timeAgo < 31556926) {
        scale                                       = @"month";
    } else {
        scale                                       = @"year";
    }
    timeAgo                                         = timeAgo/[[timeScale objectForKey:scale] integerValue];
    NSString *s                                     = @"";
    if (timeAgo > 1) {
        s                                           = @"s";
    }
    return [NSString stringWithFormat:@"%d %@%@ ago", timeAgo, scale, s];
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter                  = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone                          = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat                        = @"yyyy-MM-dd'T'H:mm:ss'Z'";
    return [dateFormatter dateFromString:string];
}

//- (NSString *)folderNameFormat {
//    NSDateFormatter *dateFormat                     = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
////    [dateFormat setDateFormat:@"yyyy-MM-dd"];
//    [dateFormat setDateFormat:@"yyyy-MM-dd-h.mm.ssa"];
//
//    return [dateFormat stringFromDate:self];
//}
//
//- (NSString *)s3NameFormat {
//    NSDateFormatter *dateFormat                     = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormat setDateFormat:@"yyyy-MM-dd-h.mm.ssa"];
//    return [dateFormat stringFromDate:self];
//}

- (NSString *)dateTimeString {
    NSDateFormatter *dateFormatter                  = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone                          = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat                        = @"EEEE MM/dd/yy h:mma";
    NSString *dateString                            = [dateFormatter stringFromDate:self];
    NSString *firstCapChar                          = [[dateString capitalizedString] substringToIndex:1];
    return [[dateString lowercaseString] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
}

- (NSString *)timeString {
    NSDateFormatter *dateFormatter                  = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone                          = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat                        = @"h:mm: a";
    return [[dateFormatter stringFromDate:self] lowercaseString];
}

- (NSString *)clockString {
    NSDateFormatter *dateFormatter                  = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone                          = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat                        = @"h:mm:ss a";
    return [[dateFormatter stringFromDate:self] lowercaseString];
}

+ (NSDate *)dateForUnixString:(NSString *)timestamp {
//    NSLog(@"[timestamp doubleValue] : %ld", (long)[timestamp integerValue]);
    return [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
}

+ (NSDate *)microSecondsStringToDate:(NSString *)timestamp {
    long double microsecondsDouble                  = floorl([timestamp doubleValue]);
    long double secondsDouble                       = microsecondsDouble / (double)100000;
    return [NSDate dateWithTimeIntervalSince1970:secondsDouble];
}

- (long double)inMicroSeconds {
    long double secondsDouble                       = (long double)[self timeIntervalSince1970];
    return secondsDouble * 100000;
}

- (NSString *)inMicroSecondsString {
    return [NSString stringWithFormat:@"%.Lf", [self inMicroSeconds]];
}

- (NSString *)inUnixSecondsString {
    return [NSString stringWithFormat:@"%.f", [self timeIntervalSince1970]];
}

- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%d",(int)[self timeIntervalSince1970] * 1000];
}


@end
