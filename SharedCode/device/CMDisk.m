//
//  CMDisk.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 6/2/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMDisk.h"
#include <sys/param.h>
#include <sys/mount.h>

#define MB (1024*1024)
#define GB (MB*1024)

@implementation CMDisk

#pragma mark - Formatter

+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes                                            = 1.0 * diskSpace;
    double megabytes                                        = bytes / MB;
    double gigabytes                                        = bytes / GB;
    if (gigabytes >= 1.0)
        formatted                                           = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted                                           = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted                                           = [NSString stringWithFormat:@"%.2f bytes", bytes];
    
    return formatted;
}

#pragma mark - Methods

+ (NSString *)totalDiskSpace {
    long long space                                         = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace                                     = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return [self memoryFormatter:freeSpace];
}

+ (long long)freeDiskSpaceMB {
    long long freeSpace                                     = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace / (1024*1024);
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space                                         = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace                                     = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace                                     = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

+ (long long) diskSpaceLeft {
    NSArray* thePath                                        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    const char *path                                        = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[thePath lastObject]];
    statfs(path, &tStats);
    long long availableSpace                                = (long long)(tStats.f_bavail * tStats.f_bsize);
     
    return availableSpace;
}

+ (BOOL)hasMinEnoughDiskSpace {
    return ([CMDisk freeDiskSpaceInBytes] > MINDISK_SPACE_THRESHOLD);
}

+ (BOOL)hasNoDiskSpace {
   return ([CMDisk freeDiskSpaceInBytes] < DISK_SPACE_THRESHOLD);
}


@end
