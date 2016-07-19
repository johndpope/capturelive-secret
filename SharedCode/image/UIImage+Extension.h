//
//  UIImage+Extension.h
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (Extension)

+ (UIImage*)returnThumbnail:(UIImage*)image withSize:(CGFloat)size;
- (UIImage *)convertRectToGrayscale:(CGRect)rect;

+ (UIImage*)imageWithUIImage:(UIImage*)image alpha:(double)alpha;
+ (UIImage*)squareImageWithImage:(UIImage*)image;
+ (UIImage*)imageWithData:(NSData*)data orientation:(UIImageOrientation)orientation;

+ (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size;
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;
- (CGFloat)widthForHeight:(CGFloat)height;
+ (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)samplebuffer;

+ (void)saveThumbnailFromMp4:(NSString *)mp4Path withKey:(NSString *)key withComplete:(void(^)(NSString *path))completed;

@end
