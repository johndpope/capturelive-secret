//
//  CMKeyboard.m
//  CaptureMedia-Acme
//
//  Created by hatebyte on 11/18/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

#import "CMKeyboard.h"

@implementation CMKeyboard

- (UIToolbar *)getToolbarWithPrevEnabled:(BOOL)prevEnabled nextEnabled:(BOOL)nextEnabled doneEnabled:(BOOL)doneEnabled {
    UIToolbar *toolbar                                      = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    NSMutableArray *toolbarItems                            = [[NSMutableArray alloc] init];
    NSString *previousString                                = NSLocalizedString(@"Previous", @"CMKeyboard : previous button");
    NSString *nextString                                    = NSLocalizedString(@"Next", @"CMKeyboard : next button");
    
    UISegmentedControl *leftItems                           = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:previousString, nextString, nil]];
    leftItems.momentary                                     = YES;
    [leftItems setEnabled:prevEnabled forSegmentAtIndex:0];
    [leftItems setEnabled:nextEnabled forSegmentAtIndex:1];
    [leftItems addTarget:self action:@selector(nextPrevHandlerDidChange:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *nextPrevControl                        = [[UIBarButtonItem alloc] initWithCustomView:leftItems];
    [toolbarItems addObject:nextPrevControl];
    
    UIBarButtonItem *flexSpace                              = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolbarItems addObject:flexSpace];
    
    UIBarButtonItem *doneButton                             = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDidClick:)];
    [toolbarItems addObject:doneButton];
    toolbar.items                                           = toolbarItems;
    
    return toolbar;
}

- (void)nextPrevHandlerDidChange:(id)sender {
    if (!self.delegate) return;
    
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
            [self.delegate previousDidTouchDown];
            break;
        case 1:
            [self.delegate nextDidTouchDown];
            break;
        default:
            break;
    }
}

- (void)doneDidClick:(id)sender {
    if (!self.delegate) return;
    
    [self.delegate doneDidTouchDown];
}

@end