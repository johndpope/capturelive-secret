//
//  PaymentClockModel.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 5/19/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "ClockFormatter.h"

@interface ClockFormatter ()

@end

@implementation ClockFormatter

- (NSString *)configure:(NSInteger)number forSeconds:(BOOL)forSeconds {
    if (forSeconds && (number < 10 && number > 0)) {
        return [NSString stringWithFormat:@"0%ld", (long)number];
    }
    return [NSString stringWithFormat:@"%ld", (long)number];
}

- (NSString *)timeString {
//    if (self.time < 4) {
//        return @"00:00:00";
//    }
    return [NSString stringWithFormat:@"%@:%@:%@", [self configure:self.minutes forSeconds:NO], [self configure:self.seconds forSeconds:YES], [self milliseconds]];
}

- (NSString *)clockString {
    return [NSString stringWithFormat:@"%@:%@", [self configure:self.minutes forSeconds:NO], [self configure:self.seconds forSeconds:YES]];
}


- (NSString *)milliseconds {
    return [[NSString stringWithFormat:@"%.2f", fmod(self.time, 1)] substringFromIndex:2];
}

- (NSInteger)seconds {
//    double adjustTime = self.time - 4.0;
    double adjustTime = self.time;
    if (adjustTime < 60) {
        return adjustTime;
    }
    return (NSInteger)(adjustTime) % 60;
}

- (NSInteger)minutes {
//    double adjustTime = self.time - 4.0;
    double adjustTime = self.time;
    return (NSInteger)(adjustTime) / 60;
}

- (void)reset {
    self.time = 0;
}

@end
