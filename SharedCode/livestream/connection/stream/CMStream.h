//
//  WowzaStream.h
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/10/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

extern int max_packet_size;

@interface CMStream : NSObject
void tonet_short(uint8_t* p, unsigned short s);
void tonet_long(uint8_t* p, unsigned long l);

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host andQueue:(dispatch_queue_t)queue;
- (void)onData:(NSArray*)data time:(double)pts;
- (void)close;

@property(nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, strong) GCDAsyncUdpSocket *updRTPSocket;
@property(nonatomic, strong) GCDAsyncUdpSocket *updRTCPSocket;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, assign) UInt16 serverRTP;
@property(nonatomic, assign) UInt16 serverRTCP;

@property(nonatomic, assign) long packets;
@property(nonatomic, assign) long bytesSent;
@property(nonatomic, assign) long ssrc;
@property(nonatomic, assign) BOOL bFirst;
@property(nonatomic, assign) uint64_t ntpBase;
@property(nonatomic, assign) uint64_t rtpBase;
@property(nonatomic, assign) double ptsBase;
@property(nonatomic, assign) long tag;

// RTCP stats
@property(nonatomic, assign) long packetsReported;
@property(nonatomic, assign) long bytesReported;
@property(nonatomic, strong) NSDate *sentRTCP;

@end

