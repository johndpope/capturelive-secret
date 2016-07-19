//
//  UIImage+Extension.m
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

#import "UIImage+Extension.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CMImageCacheOperation.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (Extension)



+ (UIImage*)returnThumbnail:(UIImage*)image withSize:(CGFloat)size {
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGFloat sizeRatio;
    CGFloat height;
    CGFloat width;
    if (image.size.width >= image.size.height) {
        sizeRatio = (size / image.size.height);
        height = size;
        width = image.size.width * sizeRatio;
        [image drawInRect:CGRectMake((size - width) * .5, 0, width, height)];
    } else {
        sizeRatio = (size / image.size.width);
        height = image.size.height * sizeRatio;
        width = size;
        [image drawInRect:CGRectMake(0, (size - height) * .5, width, height)];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = nil;
    return newImage;
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)convertRectToGrayscale:(CGRect)rect {
    // Create image rectangle with current image width/height
    CGRect imageRect = rect;
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width * self.scale, self.size.height * self.scale, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self CGImage]);
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, self.size.width * self.scale, self.size.height * self.scale, 8, 0, nil, (CGBitmapInfo)kCGImageAlphaOnly);
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [self CGImage]);
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    // release graphics context
    CGContextRelease(context);
    // make UIImage from grayscale image with alpha mask
    CGImageRef cgImage = CGImageCreateWithMask(grayImage, mask);
    UIImage *grayScaleImage = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
    // release the CG images
    CGImageRelease(cgImage);
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    // return the new grayscale image
    return grayScaleImage;
}

- (CGFloat)widthForHeight:(CGFloat)height {
    if (self.size.height == 0 || self.size.width == 0) {
        return 1;
    }
    //611 × 48
    CGFloat ratio                           =  height / self.size.height;
    return self.size.width * ratio;
}

+ (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size)) {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

+ (UIImage*)imageWithUIImage:(UIImage*)image alpha:(double)alpha {
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)squareImageWithImage:(UIImage*)image {
    double dimension = MIN(image.size.width, image.size.height);
    UIGraphicsBeginImageContext(CGSizeMake(dimension, dimension));
    [image drawInRect:CGRectMake((dimension-image.size.width)/2, (dimension-image.size.height)/2, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithData:(NSData*)data orientation:(UIImageOrientation)orientation
{
    CGSize const previewSize = CGSizeMake(100, 100);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL); // data is your image file NSData
    if (source)
    {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil);
        if (cgImage)
        {
            CFRelease(source);
            
            //change orientation
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
            CFRelease(cgImage);
            
            CGSize imageSize = image.size;
            double modifier = MAX(previewSize.width/imageSize.width, previewSize.height/imageSize.height);
            imageSize = CGSizeMake(imageSize.width*modifier, imageSize.height*modifier);
            
            
            //shrink
            UIGraphicsBeginImageContext(CGSizeMake(previewSize.width, previewSize.height));
            [image drawInRect: CGRectMake((previewSize.width-imageSize.width)/2, (previewSize.height-imageSize.height)/2, imageSize.width, imageSize.height)];
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return smallImage;
        }
    }
    return nil;
}

+ (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)samplebuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(samplebuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef myImage = [context
                          createCGImage:ciImage
                          fromRect:CGRectMake(0, 0,
                                              CVPixelBufferGetWidth(pixelBuffer),
                                              CVPixelBufferGetHeight(pixelBuffer))];
    
    return [UIImage imageWithCGImage:myImage];
}

+ (void)saveThumbnailFromMp4:(NSString *)mp4Path withKey:(NSString *)key withComplete:(void(^)(NSString *path))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURL *fileUrl                                          = [NSURL fileURLWithPath:mp4Path];
        AVURLAsset *urlAsset                                    = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
        
        AVAssetImageGenerator *assetImageGenerator              = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
        assetImageGenerator.appliesPreferredTrackTransform      = YES;
        assetImageGenerator.apertureMode                        = AVAssetImageGeneratorApertureModeEncodedPixels;
        CGImageRef thumbnailImageRef                            = NULL;
        NSError *error                                          = nil;
        thumbnailImageRef                                       = [assetImageGenerator copyCGImageAtTime:CMTimeMake(2, 1)
                                                                                              actualTime:NULL
                                                                                                   error:&error];
        if (error) {
            complete(nil);
            NSLog(@"mp4Path : %@", mp4Path);
            NSLog(@"generateMetaDataWithComplete error : %@", error);
        }
        
        UIImage *imageWithData                                  = [UIImage imageWithCGImage:thumbnailImageRef];
        urlAsset                                                = nil;
        assetImageGenerator                                     = nil;
        thumbnailImageRef                                       = nil;
        
        NSString *path                                          = [NSString stringWithFormat:@"%@%@.jpg", [CMImageCacheOperation baseURL], key];
        NSURL *cacheURL                                         = [[CMImageCacheOperation baseURL] URLByAppendingPathComponent:[CMImageCacheOperation hashPath:path]];
        
        NSData *pictureData                                     = UIImageJPEGRepresentation(imageWithData, .5);
        NSLog(@"cacheURL : %@", cacheURL);
        [pictureData writeToURL:cacheURL options:NSDataWritingAtomic error:&error];
        if (error) {
            complete(nil);
            NSLog(@"generateMetaDataWithComplete error : %@", error);
        }
        
        pictureData                                             = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(cacheURL.path);
        });
        
    });
}

@end
