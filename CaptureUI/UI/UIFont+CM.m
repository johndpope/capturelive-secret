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
    [self loadAssetFontWithName:@"Comfortaa-Bold" ofType:@"ttf"];
    [self loadAssetFontWithName:@"Comfortaa-Light" ofType:@"ttf"];
    [self loadAssetFontWithName:@"Comfortaa-Regular" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Black" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-BlackItalic" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Bold" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-BoldItalic" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-ExtraLight" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-ExtraLightItalic" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Italic" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Light" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-LightItalic" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Regular" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-Semibold" ofType:@"ttf"];
    [self loadAssetFontWithName:@"SourceSansPro-SemiboldItalic" ofType:@"ttf"];
    
    
    [self loadAssetFontWithName:@"Proxima Nova Black" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Bold" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Light" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Reg" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Sbold" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Thin" ofType:@"otf"];
    [self loadAssetFontWithName:@"Proxima Nova Xbold" ofType:@"otf"];
    [self loadAssetFontWithName:@"ProximaNova-BoldIt" ofType:@"otf"];
    [self loadAssetFontWithName:@"ProximaNova-LightItalic" ofType:@"otf"];
    [self loadAssetFontWithName:@"ProximaNova-RegItalic" ofType:@"otf"];
    [self loadAssetFontWithName:@"ProximaNova-SemiboldItalic" ofType:@"otf"];
//    dumpAllFonts();
}

+ (void)loadAssetFontWithName:(NSString *)name ofType:(NSString *)type {
    NSString *fontPath                                          = [[NSBundle mainBundle] pathForResource:name ofType:type];
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
