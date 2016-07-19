//
//  CaptureCore.h
//  CaptureCore
//
//  Created by Scott Jones on 4/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for CaptureCore.
FOUNDATION_EXPORT double CaptureCoreVersionNumber;

//! Project version string for CaptureCore.
FOUNDATION_EXPORT const unsigned char CaptureCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CaptureCore/PublicHeader.h>

#import <CaptureCore/NSData+MKBase64.h>
#import <CaptureCore/NSDate+CM.h>
#import <CaptureCore/NSString+MKNetworkKitAdditions.h>
#import <CaptureCore/CMFileManager.h>
#import <CaptureCore/MKMapView+ZoomLevel.h>
#import <CaptureCore/CMDevice.h>
#import <CaptureCore/CMDisk.h>
#import <CaptureCore/ClockFormatter.h>
#import <CaptureCore/CMStream.h>
#import <CaptureCore/WowzaStreamResponseParser.h>
#import <CaptureCore/CMSampleTimeObjc.h>
#import <CaptureCore/CMAudioRecorder.h>
#import <CaptureCore/CMVideoStream.h>
#import <CaptureCore/CMRTSPConnectionModel.h>
#import <CaptureCore/CMStreamRTSPConnection.h>
#import <CaptureCore/CMAudioStream.h>
#import <CaptureCore/CMStreamRTSPClient.h>
#import <CaptureCore/AVEncoder.h>
