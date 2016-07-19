//
//  WowzaAudioStream.h
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/10/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMStream.h"

extern char *AudioQueue;

@interface CMAudioStream : CMStream

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host;
- (void)onData:(NSData*)data time:(double)pts;

@end
