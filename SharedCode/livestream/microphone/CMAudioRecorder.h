//
//  CMAudioRecorder.h
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/17/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreMedia/CoreMedia.h>




@protocol CMAudioRecoredSampleBufferDelegate <NSObject>

- (void)didRenderAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@protocol CMAudioRecorderAACAudioDelegate <NSObject>

- (void)didConvertAACData:(NSData *)data time:(double)time;

@end


@interface CMAudioRecorder : NSObject

@property(nonatomic, weak) id <CMAudioRecoredSampleBufferDelegate> sampleBufferDelegate;
@property(nonatomic, weak) id <CMAudioRecorderAACAudioDelegate> aacDelegate;

+ (int)Channel;
+ (int)Profile;
+ (int)FrequencyIndex;
+ (void)shouldTryToAccessMicrophone:(void (^)(BOOL granted))handler;

- (void)configure;
- (BOOL)isConfigured;
- (void)startRecordering;
- (void)stopRecordering;

@end
