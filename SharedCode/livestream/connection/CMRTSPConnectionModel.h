//
//  CMRTSPConnectionModel.h
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/28/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMRTSPConnectionModel : NSObject

@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *application;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, assign) NSUInteger port;
@property(nonatomic, assign) int rstp_audioChannel;
@property(nonatomic, assign) int rstp_audioProfile;
@property(nonatomic, assign) int rstp_audioFrequencyIndex;

@end