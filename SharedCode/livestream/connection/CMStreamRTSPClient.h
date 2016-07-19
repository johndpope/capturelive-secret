//
//  WowzaRTSPClient.h
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/5/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CMRTSPConnectionModel.h"

typedef enum {
    RTSPClientRequestAuthorize,
    RTSPClientAuthorized,           // (recording)
    RTSPClientRequestTermination,
    RTSPClientTerminationed,
    RTSPClientInAccessibleNetworkConditions
} RTSPClientStatus;

typedef enum {
    StreamConnectionStateConnected,
    StreamConnectionStateDisconnected,
    StreamConnectionStateError,
    StreamConnectionStateInAccessibleNetworkConditions
} StreamConnectionState;

@class CMStreamRTSPClient;
@protocol CMStreamRTSPClientDelegate <NSObject>

- (void)rtspClient:(CMStreamRTSPClient *)client status:(StreamConnectionState)state;
@optional
- (void)connectionLost:(CMStreamRTSPClient *)client;
- (void)connectionRegained:(CMStreamRTSPClient *)client;

@end

@interface CMStreamRTSPClient : NSObject

+ (CMStreamRTSPClient*)setupListener:(NSData*)configData andConfig:(CMRTSPConnectionModel *)config andDelegate:(id<CMStreamRTSPClientDelegate>)delegate;

- (void)onVideoData:(NSArray*)data time:(double)pts;
- (void)onAudioData:(NSData *)data time:(double)pts;
- (void)shutDown;
- (void)resumeRecording;
- (void)pauseRecording;
- (void)reconnect;
- (void)setVideoStandardVideoCutLength:(unsigned long)videoCutLength;

@end
