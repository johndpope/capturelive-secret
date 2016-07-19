//
//  UIFont+CapturePresets.m
//  Capture
//
//  Created by Max Mikheyenko on 7/22/13.
//  Copyright (c) 2013 Capture. All rights reserved.
//

#import "UIFont+CM.h"
#import <CoreText/CoreText.h>

@implementation UIFont (CapturePresets)

+ (void)loadAssetFonts {
    [self loadAssetFontWithName:@"Comfortaa-Bold"];
    [self loadAssetFontWithName:@"Comfortaa-Light"];
    [self loadAssetFontWithName:@"Comfortaa-Regular"];
    [self loadAssetFontWithName:@"SourceSansPro-Black"];
    [self loadAssetFontWithName:@"SourceSansPro-BlackItalic"];
    [self loadAssetFontWithName:@"SourceSansPro-Bold"];
    [self loadAssetFontWithName:@"SourceSansPro-BoldItalic"];
    [self loadAssetFontWithName:@"SourceSansPro-ExtraLight"];
    [self loadAssetFontWithName:@"SourceSansPro-ExtraLightItalic"];
    [self loadAssetFontWithName:@"SourceSansPro-Italic"];
    [self loadAssetFontWithName:@"SourceSansPro-Light"];
    [self loadAssetFontWithName:@"SourceSansPro-LightItalic"];
    [self loadAssetFontWithName:@"SourceSansPro-Regular"];
    [self loadAssetFontWithName:@"SourceSansPro-Semibold"];
    [self loadAssetFontWithName:@"SourceSansPro-SemiboldItalic"];
}

+ (void)loadAssetFontWithName:(NSString *)name {
//    dumpAllFonts();
    NSString *fontPath                                          = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    NSData *inData                                              = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;
    CGDataProviderRef provider                                  = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
    CGFontRef font                                              = CGFontCreateWithDataProvider(provider);
    
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription                            = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

//static void dumpAllFonts() {
//    for (NSString *familyName in [UIFont familyNames]) {
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
//            NSLog(@"%@", fontName);
//        }
//    }
//}


@end
