//
//  CMKeyboard.h
//  CaptureMedia-Acme
//
//  Created by hatebyte on 11/18/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMKeyboardDelegate

- (void)nextDidTouchDown;
- (void)previousDidTouchDown;
- (void)doneDidTouchDown;

@end


@interface CMKeyboard : NSObject

@property (nonatomic, strong) id <CMKeyboardDelegate> delegate;

- (UIToolbar *)getToolbarWithPrevEnabled:(BOOL)prevEnabled nextEnabled:(BOOL)nextEnabled doneEnabled:(BOOL)doneEnabled;

@end
