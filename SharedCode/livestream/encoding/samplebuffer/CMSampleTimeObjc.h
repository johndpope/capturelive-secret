//
//  CMSampleTimeObjc.h
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/30/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CMSampleTimeObjc : NSObject

+ (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset;

@end
