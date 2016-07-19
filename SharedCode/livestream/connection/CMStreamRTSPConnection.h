//
//  WowzaRTSPConnection.h
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/5/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRTSPConnectionModel.h"

typedef enum {
    AuthorizationStateUnauthorize,
    AuthorizationStateAuthorize,
    AuthorizationStateRequestAudioSetup,
    AuthorizationStateRequestVideoSetup,
    AuthorizationStateRequestRecord,
    AuthorizationStateRequestPause,
    AuthorizationStateRequestOptions,
    AuthorizationStateRequestGetParameter,
    AuthorizationStateRequestTearDown,
} AuthorizationState;


@class CMStreamRTSPConnection;
@protocol CMStreamRTSPConnectionDelegate <NSObject>

- (void)connectionSuccess;
- (void)connectionFailure;
- (void)connectionTerminated;
- (void)connectionLost;
- (void)reconnectionSuccess;

@optional
- (void)connection:(CMStreamRTSPConnection *)connection configureLocalPorts:(NSArray *)localPorts configureRemotePorts:(NSArray *)remotePorts isVideo:(BOOL)isVideo;

@end


@interface CMStreamRTSPConnection : NSObject

@property(nonatomic, assign) unsigned long videoCutLength;

+ (CMStreamRTSPConnection *)connectionWithConfigData:(NSData *)configData
                                           andConfig:(CMRTSPConnectionModel *)config
                                        withDelegate:(id <CMStreamRTSPConnectionDelegate>)delegate;

- (void)shutDown;
- (void)sendRecordRequest;
- (void)sendPauseRequest;
- (void)reconnect;

//- (void)startRequestPingers;
//- (void)stopTimers;

@end
