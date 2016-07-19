//
//  CMDisk.h
//  CaptureMedia-Library
//
//  Created by hatebyte on 6/2/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

static unsigned long long MINDISK_SPACE_THRESHOLD           = 104857600;
static unsigned long long DISK_SPACE_THRESHOLD              = 52428800;

@interface CMDisk : NSObject

+ (NSString *)memoryFormatter:(long long)diskSpace;
+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;
+ (long long)freeDiskSpaceMB;
+ (NSString *)usedDiskSpace;
+ (CGFloat)totalDiskSpaceInBytes;
+ (CGFloat)freeDiskSpaceInBytes;
+ (CGFloat)usedDiskSpaceInBytes;
+ (BOOL)hasMinEnoughDiskSpace;
+ (BOOL)hasNoDiskSpace;

@end
