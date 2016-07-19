//
//  ImageCache.m
//  Capture-SharedLibrary
//
//  Created by hatebyte on 12/9/13.
//  Copyright (c) 2013 capture. All rights reserved.
//

#import "CMImageCache.h"
#include <sys/sysctl.h>


@interface CMImageCache () {
    NSOperationQueue *_queue;
}

unsigned int countOfCores(void);

@end

@implementation CMImageCache


unsigned int countOfCores() {
    unsigned int ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    return ncpu;
}

+ (instancetype)defaultCache {
    static CMImageCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CMImageCache alloc] init];
    });
    return cache;
}

- (id)init {
    if (self = [super init]) {
        _queue                                  = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount      = countOfCores();
    }
    return self;
}

- (BOOL)isImageCached:(NSString *)path {
    if (!path) {
        return NO;
    }
    NSURL *cacheURL                             = [CMImageCacheOperation cacheURLForExternalPath:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path];
}

- (void)removeCachedFile:(NSString *)path {
    if ([self isImageCached:path]) {
        NSError *e = nil;
        NSURL *cacheURL                         = [CMImageCacheOperation cacheURLForExternalPath:path];
        [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:&e];
    }
}

- (CMImageCacheOperation *)imageForPath:(NSString *)path complete:(void(^)(NSError *error, UIImage *image))complete {
    NSURL *cacheURL                                             = [CMImageCacheOperation cacheURLForExternalPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path]) {
        complete(nil, [UIImage imageWithContentsOfFile:cacheURL.path]);
        return nil;
    }
    
    CMImageCacheOperation *operation            = [[CMImageCacheOperation alloc] initWithPath:path];
    operation.queuePriority                                     = NSOperationQueuePriorityVeryHigh;
    __weak CMImageCacheOperation *weakOp                        = operation;
    operation.retrievedBlock = ^{
        if (!weakOp.isCancelled) {
            CMImageCacheOperation *strongOp                       = weakOp;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (strongOp.image) {
                    complete(nil, strongOp.image);
                } else {
                    complete(strongOp.error, nil);
                }
            }];
        }
    };
    [_queue addOperation:operation];

    return operation;
}

- (void)cancelAllOperations {
    [_queue cancelAllOperations];
}

@end
