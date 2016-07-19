//
//  WowzaStream.m
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/10/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMStream.h"
@interface CMStream () <GCDAsyncUdpSocketDelegate>

@end

@implementation CMStream

void tonet_short(uint8_t* p, unsigned short s) {
    p[0] = (s >> 8) & 0xff;
    p[1] = s & 0xff;
}

void tonet_long(uint8_t* p, unsigned long l) {
    p[0] = (l >> 24) & 0xff;
    p[1] = (l >> 16) & 0xff;
    p[2] = (l >> 8) & 0xff;
    p[3] = l & 0xff;
}

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host andQueue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        @synchronized(self) {
            _host                                                       = host;
            _queue                                                      = queue;
            
            NSError *error = nil;
            _updRTPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_queue];
            if (![_updRTPSocket bindToPort:[localPorts[0] integerValue] error:&error]) {
                NSLog(@"portRTP Error binding: %@", error);
            }
            
            _updRTCPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_queue];
            if (![_updRTCPSocket bindToPort:[localPorts[1] integerValue]  error:&error]) {
                NSLog(@"portRTCP Error binding: %@", error);
            }
            
            _serverRTP = [remotePorts[0] integerValue];
            _serverRTCP = [remotePorts[1] integerValue];
            
            _ssrc = random();
            _packets = 0;
            _bytesSent = 0;
            _ntpBase = 0;
            _rtpBase = 0;
            
            _sentRTCP = nil;
            _packetsReported = 0;
            _bytesReported = 0;
        }
        
    }
    return self;
}

- (void)onData:(NSArray*)data time:(double)pts {}
- (void)close {
    [_updRTPSocket close];
    [_updRTCPSocket close];
}

@end

int max_packet_size = 1200;
