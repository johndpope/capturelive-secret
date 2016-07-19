//
//  CMSampleTimeObjc.m
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/30/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

#import "CMSampleTimeObjc.h"
#import <Accelerate/Accelerate.h>

@implementation CMSampleTimeObjc

//  from Geraint Davies -
+ (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    // typedef of a long
    CMItemCount count;
    // populate number of CMSampleTimingInfo in the sample buffer
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    // prep some memory for the info via the count
    CMSampleTimingInfo  *pInfo                  = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    // adjust both timestamps by the offset
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp                = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp          = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    // recreate sample buffer with the new timing info for all the data inside
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

+ (unsigned char*)videoFrames:(CMSampleBufferRef)sampleBuffer {
    int cropHeight, cropWidth, outWidth, outHeight;
    
    CVImageBufferRef pixelBuffer    = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void *baseAddress               = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow              = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    vImage_Buffer inBuff;
    inBuff.height                   = cropHeight;
    inBuff.width                    = cropWidth;
    inBuff.rowBytes                 = bytesPerRow;
    
    unsigned long startpos          = bytesPerRow + 4;
    inBuff.data                     = baseAddress + startpos;
    
    unsigned char *outImg           = (unsigned char*)malloc(4 * outWidth * outHeight);
    vImage_Buffer outBuff           = {outImg, outHeight, outWidth, 4 * outWidth};
    
    vImage_Error err                = vImageScale_ARGB8888(&inBuff, &outBuff, NULL, 0);
    if (err != kvImageNoError) NSLog(@" error %ld", err);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return outImg;
}

@end
