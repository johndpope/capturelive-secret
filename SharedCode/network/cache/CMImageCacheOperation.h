//
//  ImageCacheOperation.h
//  Capture-SharedLibrary
//
//  Created by hatebyte on 12/9/13.
//  Copyright (c) 2013 capture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *ImageCacheOperationErrorDomain;

typedef enum {
    ImageCacheAssetLibraryRetrevialError,
    ImageCacheWriteToDiskError,
    ImageCacheNotFoundError
} ImageCacheErrorCode;

typedef void (^FinishedBlock)(void);

@interface CMImageCacheOperation : NSOperation

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSError *error;
@property(readwrite, copy) FinishedBlock retrievedBlock;

+ (NSURL *)cacheURLForExternalPath:(NSString *)path;
+ (NSString *)hashPath:(NSString *)path;
+ (NSURL *)baseURL;

- (id)initWithPath:(NSString *)path;

@end
