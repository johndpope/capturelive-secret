//
//  VideoEncoder.m
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "VideoEncoder.h"

@implementation VideoEncoder

@synthesize path = _path;

+ (VideoEncoder*) encoderForPath:(NSString*)path Height:(int) height andWidth:(int) width {
    VideoEncoder* enc = [VideoEncoder alloc];
    [enc initPath:path Height:height andWidth:width];
    return enc;
}

- (void)initPath:(NSString*)path Height:(int) height andWidth:(int) width {
    self.path                                                       = path;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url                                                      = [NSURL fileURLWithPath:self.path];
    
    _writer                                                         = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    
    int newW                                                        = width * 0.5;
    int newH                                                        = height * 0.5;
    int64_t bitRate                                                 = [VideoEncoder getBitrate];// * bitsPerPixel;
   
//    int64_t bitRate                                                 = [VideoEncoder getBitrate];
//    float change = ((float)bitRate / (float)300000) * 0.5;
//    int newW                                                        = width * change;
//    int newH                                                        = height * change;
//    bitRate = 300000;
   
//    NSLog(@"bitRate     : %lld", bitRate);
//    NSLog(@"newW     : %d", newW); // 640
//    NSLog(@"newH     : %d", newH); // 360
    NSDictionary* settings                                          = @{
                            AVVideoCodecKey                         : AVVideoCodecH264,
                            AVVideoWidthKey                         : [NSNumber numberWithInt           :newW],
                            AVVideoHeightKey                        : [NSNumber numberWithInt           :newH],
                            AVVideoCompressionPropertiesKey         :
                                @{
                                    AVVideoAverageBitRateKey        : [NSNumber numberWithLongLong      :bitRate],
                                    AVVideoMaxKeyFrameIntervalKey   : [NSNumber numberWithInt           :20],
                                    AVVideoAllowFrameReorderingKey  : [NSNumber numberWithBool          :NO],
                                }
                            };
   
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_videoInput];

}

- (void)finishWithCompletionHandler:(void (^)(void))handler {
    if (_writer.status == AVAssetWriterStatusUnknown) {
        handler();
    } else {
        [_videoInput markAsFinished];
        [_writer finishWritingWithCompletionHandler:handler];
    }
}

- (BOOL)encodeFrame:(CMSampleBufferRef)sampleBuffer {
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        if (_writer.status == AVAssetWriterStatusUnknown) {
            CMTime startTime                                        = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed) {
            return NO;
        }
        if (_videoInput.readyForMoreMediaData == YES) {
            [_videoInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
    }
    return NO;
}

+ (int64_t)getBitrate {
    int64_t b                                                      = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:BITRATE] longLongValue];
    if (b) {
        return b;
    } else {
        return (int64_t)75000;
    }
}

+ (CGFloat)getResolution {
    float b                                                         = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:RESOLUTION] floatValue];
    if (b) {
        return b / 100.f;
    } else {
        return (float)0.69f;
    }
}


@end

NSString *BITRATE           = @"BITRATE";
NSString *RESOLUTION        = @"RESOLUTION";
uint16_t FRAMERATE          = 30;
