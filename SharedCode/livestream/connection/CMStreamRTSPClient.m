//
//  WowzaRTSPClient.m
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/5/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMStreamRTSPClient.h"
#import "CMStreamRTSPConnection.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import "CMAudioStream.h"
#import "CMVideoStream.h"

@interface CMStreamRTSPClient () <CMStreamRTSPConnectionDelegate> {
}

@property(nonatomic, strong) NSData *configData;
@property(nonatomic, strong) CMStreamRTSPConnection *rtspConnection;
@property(nonatomic, strong) CMVideoStream *videoStream;
@property(nonatomic, strong) CMAudioStream *audioStream;
@property(nonatomic, weak) CMRTSPConnectionModel *config;
@property(nonatomic, weak) id <CMStreamRTSPClientDelegate> delegate;
@property(nonatomic) uint64_t ntpBaseline;
@property(nonatomic) double ptsBaseline;
@property(nonatomic) BOOL connected;

@end

@implementation CMStreamRTSPClient

+ (CMStreamRTSPClient *)setupListener:(NSData*)configData andConfig:(CMRTSPConnectionModel *)config andDelegate:(id<CMStreamRTSPClientDelegate>)delegate {
    return [[CMStreamRTSPClient alloc] init:configData andConfig:config andDelegate:delegate];
}

- (CMStreamRTSPClient *)init:(NSData*)configData andConfig:(CMRTSPConnectionModel *)config andDelegate:(id<CMStreamRTSPClientDelegate>)delegate {
    _configData                                                     = configData;
    _config                                                         = config;
    self.delegate                                                   = delegate;
    
    _rtspConnection                                                 = [CMStreamRTSPConnection connectionWithConfigData:configData
                                                                                                             andConfig:_config
                                                                                                          withDelegate:self];
    return self;
}

- (void)reconnect {
    if (_rtspConnection) {
        [_rtspConnection reconnect];
    }
}

- (void)resumeRecording {
    if (_rtspConnection) {
        [_rtspConnection sendRecordRequest];
    }
}

- (void)pauseRecording {
    if (_rtspConnection) {
        [_rtspConnection sendPauseRequest];
    }
}

- (void)setVideoStandardVideoCutLength:(unsigned long)videoCutLength {
    if (_rtspConnection) {
        _rtspConnection.videoCutLength                              = videoCutLength;
    }
}

// establish a common baseline, and a corresponding NTP time
- (void) checkBaseline:(double) pts {
    @synchronized(self) {
        if (self.ntpBaseline == 0) {
            NSDate* now                                             = [NSDate date];
            // ntp is based on 1900. There's a known fixed offset from 1900 to 1970.
            NSDate* ref                                             = [NSDate dateWithTimeIntervalSince1970:-2208988800L];
            double interval                                         = [now timeIntervalSinceDate:ref];
            self.ntpBaseline                                        = (uint64_t)(interval * (1LL << 32));
            self.ptsBaseline                                        = pts;
            
            if (self.videoStream != nil) {
                self.videoStream.ntpBase                            = self.ntpBaseline;
                self.videoStream.ptsBase                            = pts;
            }
            if (self.audioStream != nil) {
                self.audioStream.ntpBase                            = self.ntpBaseline;
                self.audioStream.ptsBase                            = pts;
            }
        }
    }
}

- (void)onVideoData:(NSArray*)data time:(double)pts {
    if (self.connected == true) {
        [self checkBaseline:pts];
        if (self.videoStream != nil) {
            [self.videoStream onData:data time:pts - self.ptsBaseline];
        }
    }
}

- (void)onAudioData:(NSData *)data time:(double)pts {
    if (self.connected == true) {
        [self checkBaseline:pts];
        if (self.audioStream != nil) {
            [self.audioStream onData:data time:pts - self.ptsBaseline];
        }
    }
}

#pragma mark - WowzaRTSPConnectionDelegate
- (void)connectionSuccess {
    self.connected                                                  = true;
    [self.delegate rtspClient:self status:StreamConnectionStateConnected];
    [self.delegate connectionRegained:self];
}

- (void)connectionTerminated {
    NSLog(@"TERMINATED");
    self.connected                                                  = false;
    [self.delegate connectionLost:self];
}

- (void)connectionFailure {
    NSLog(@"FAILURE");
    self.connected                                                  = false;
    [self.delegate connectionLost:self];
}

- (void)connectionLost {
    self.connected                                                  = false;
    [self.delegate connectionLost:self];
}

- (void)reconnectionSuccess {
    self.connected                                                  = true;
    [self.delegate connectionRegained:self];
}

- (void)connection:(CMStreamRTSPConnection *)connection configureLocalPorts:(NSArray *)localPorts configureRemotePorts:(NSArray *)remotePorts isVideo:(BOOL)isVideo {
    if (isVideo) {
        _videoStream                                                = [[CMVideoStream alloc] initWithLocalPorts:localPorts andRemotePorts:remotePorts toHost:_config.host];
    } else {
        _audioStream                                                = [[CMAudioStream alloc] initWithLocalPorts:localPorts andRemotePorts:remotePorts toHost:_config.host];
    }
    
    
}

- (void)shutDown {
    _delegate                                                       = nil;
    [_rtspConnection shutDown];
    [_videoStream close];
    [_audioStream close];
    _videoStream                                                    = nil;
    _audioStream                                                    = nil;
}

@end

