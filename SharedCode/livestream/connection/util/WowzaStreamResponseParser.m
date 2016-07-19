//
//  StreamResponseParser.m
//  CaptureMedia-Data
//
//  Created by hatebyte on 3/3/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "WowzaStreamResponseParser.h"

@implementation WowzaStreamResponseParser

+ (NSString *)response:(NSString *)responseString valueForPrefix:(NSString *)pattern {
    NSError* error                                                  = nil;
    NSRegularExpression *regex                                      = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                                                options:NSRegularExpressionUseUnixLineSeparators
                                                                                                                  error:&error];
    if (error) { NSLog(@"%@", [error description]); }
    NSTextCheckingResult *match = [regex firstMatchInString:responseString options:0 range:NSMakeRange(0, [responseString length])];
    if (match) {
        return [responseString substringWithRange:match.range];
    }
    
    return nil;
}

@end

