//
//  ImageCacheOperation.m
//  Capture-SharedLibrary
//
//  Created by hatebyte on 12/9/13.
//  Copyright (c) 2013 capture. All rights reserved.
//

#import "CMImageCacheOperation.h"
#import "NSString+MKNetworkKitAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CMImageCacheOperation ()

@property(nonatomic, strong, readwrite) NSString *externalPath;

@end

@implementation CMImageCacheOperation

- (id)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _externalPath                                               = path;
    }
    return self;
}

- (void)main {

    if (_externalPath && !self.isCancelled) {
        NSURL *cacheURL                                             = [CMImageCacheOperation cacheURLForExternalPath:_externalPath];
        NSURL *externalURL                                          = [NSURL URLWithString:_externalPath];

        if ([externalURL.absoluteString hasPrefix:@"assets-library"]) {
            __weak typeof(self) weakSelf                            = self;
            ALAssetsLibrary *library                                = [[ALAssetsLibrary alloc] init];
            if (!self.isCancelled) {
                [library assetForURL:externalURL resultBlock:^(ALAsset *asset) {
                    ALAssetRepresentation *rep                      = [asset defaultRepresentation];
                    Byte *buffer                                    = (Byte*)malloc((unsigned long)rep.size);
                    NSUInteger buffered                             = [rep getBytes:buffer fromOffset:0.0 length:(unsigned int)rep.size error:nil];
                    NSData *imageData                               = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    if (!weakSelf.isCancelled) {
                        [weakSelf saveImageData:imageData toCacheURL:cacheURL];
                    }
                } failureBlock:^(NSError *error) {
                    weakSelf.error                                  = [NSError errorWithDomain:ImageCacheOperationErrorDomain code:ImageCacheAssetLibraryRetrevialError userInfo:nil];
                    weakSelf.retrievedBlock();
               }];
            }
        } else {
            if (!self.isCancelled) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                NSData *imageData                                   = [NSData dataWithContentsOfURL:externalURL];
                if (imageData) {
                    [self saveImageData:imageData toCacheURL:cacheURL];
                } else {
                    NSURL *cacheDirectory                           = [[CMImageCacheOperation baseURL] URLByAppendingPathComponent:externalURL.lastPathComponent];
                    imageData                                       = [NSData dataWithContentsOfURL:cacheDirectory];
                    [self saveImageData:imageData toCacheURL:cacheURL];
                }
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }
            
    } else {
        self.error                                                  = [NSError errorWithDomain:ImageCacheOperationErrorDomain code:ImageCacheNotFoundError userInfo:nil];
        self.retrievedBlock();
   }
}

- (void)saveImageData:(NSData *)imageData toCacheURL:(NSURL *)cacheURL {
    if (!imageData) {
        self.error                                                  = [NSError errorWithDomain:ImageCacheOperationErrorDomain code:ImageCacheNotFoundError userInfo:nil];
        self.retrievedBlock();
        return;
    }
    if (!self.isCancelled) {
        if (![imageData writeToURL:cacheURL atomically:YES]) {
            self.error                                              = [NSError errorWithDomain:ImageCacheOperationErrorDomain code:ImageCacheWriteToDiskError userInfo:nil];
            self.retrievedBlock();
            return;
        }
        self.image                                                  = [UIImage imageWithContentsOfFile:cacheURL.path];
        self.retrievedBlock();
    }
}

+ (NSURL *)cacheURLForExternalPath:(NSString *)path {
    if (!path) return nil;
    NSRange s3Range                                                 = [path rangeOfString:@".s3.amazonaws.com"];
    if (s3Range.location != NSNotFound) {
        NSArray *comp1                                              = [path componentsSeparatedByString:@"?"];
        if ([comp1 count]) {
            path                                                    = [comp1 objectAtIndex:0];
        }
    }

    return [[self baseURL] URLByAppendingPathComponent:[self hashPath:path]];
}

+ (NSString *)hashPath:(NSString *)path {
    if (!path) return nil;
    NSString *hash                                                  = [path md5];
    if (path.pathExtension) {
        return [hash stringByAppendingPathExtension:path.pathExtension];
    }
    return hash;
}

+ (NSURL *)baseURL {
    NSFileManager *manager                                          = [NSFileManager defaultManager];
    NSURL *cacheDirectory                                           = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    cacheDirectory                                                  = [cacheDirectory URLByAppendingPathComponent:@"capturelive.image.cache"];
    if ([manager createDirectoryAtURL:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
        return cacheDirectory;
    }
    return nil;
}

@end

NSString *ImageCacheOperationErrorDomain                            = @"ImageCacheOperationErrorDomain";

