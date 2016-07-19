//
//  PaymentClockModel.h
//  CaptureMedia-Library
//
//  Created by hatebyte on 5/19/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClockFormatter : NSObject

@property(nonatomic, assign) double time;
@property(nonatomic, strong) NSString *timeString;
@property(nonatomic, strong) NSString *clockString;

- (void)reset;
- (NSString *)timeString;
- (NSString *)clockString;

@end
