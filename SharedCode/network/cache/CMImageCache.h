//
//  ImageCache.h
//  Capture-SharedLibrary
//
//  Created by hatebyte on 12/9/13.
//  Copyright (c) 2013 capture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMImageCacheOperation.h"

@interface CMImageCache : NSObject

+ (instancetype)defaultCache;
- (CMImageCacheOperation *)imageForPath:(NSString *)path complete:(void(^)(NSError *error, UIImage *image))complete;
- (void)cancelAllOperations;
- (BOOL)isImageCached:(NSString *)path;
- (void)removeCachedFile:(NSString *)path;

@end
