//
//  WowzaVideoStream.h
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/7/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//


#import "CMStream.h"

extern char *VideoQueue;

@interface CMVideoStream : CMStream

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host;

@end
