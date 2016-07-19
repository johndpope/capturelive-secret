//
//  CMPingEffectView.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 8/9/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMPingEffectView.h"

@interface CMPingModel : NSObject

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) CGFloat borderWidth;
@property(nonatomic, assign) CGFloat borderMax;
@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, assign) CGFloat limit;
@property(nonatomic, assign) CGFloat velocity;

- (instancetype)initWithRadius:(CGFloat)radius withLimit:(CGFloat)limit;

@end

@implementation CMPingModel

- (instancetype)initWithRadius:(CGFloat)radius withLimit:(CGFloat)limit {
    if (self = [super init]) {
        _color                                              = [UIColor colorWithWhite:1.0 alpha:0.5];
        _radius                                             = radius;
        _limit                                              = limit;
        _borderMax                                          = limit * .08;
        _velocity                                           = .5;
    }
    return self;
}

- (void)update {
    _radius                                                 += _velocity;
    _borderWidth                                            = [self getBorderWidth];

    if ([self shouldReset]) {
        [self reset];
    }
}

- (BOOL)shouldReset {
    return _radius > ((_limit * .5) - (_borderMax * .5));
}

- (void)reset {
    _radius                                                 = 0;
    _borderWidth                                            = [self getBorderWidth];
}

- (CGFloat)getBorderWidth {
    return (_borderMax * .5) - ((_radius / _limit) * _borderMax);
}

@end


@interface CMPingEffectView ()

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) CMPingModel *pingModel1;
@property(nonatomic, strong) CMPingModel *pingModel2;
@property(nonatomic, strong) CMPingModel *pingModel3;

@end

@implementation CMPingEffectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _pingModel1                                         = [[CMPingModel alloc] initWithRadius:frame.size.width * .0 withLimit:frame.size.width];
        _pingModel2                                         = [[CMPingModel alloc] initWithRadius:frame.size.width * .06 withLimit:frame.size.width];
//        _pingModel3                                         = [[CMPingModel alloc] initWithRadius:frame.size.width * .12 withLimit:frame.size.width];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    if (!_displayLink) {
        _displayLink                                        = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePingers)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stop {
    if (_displayLink) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink                                        = nil;
    }
}

- (void)updatePingers {
    [_pingModel1 update];
    [_pingModel2 update];
//    [_pingModel3 update];
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context                                    = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, _pingModel1.color.CGColor);
    CGContextSetLineWidth(context, _pingModel1.borderWidth);
    CGContextSetShouldAntialias(context, YES);
    CGContextAddArc(context, self.frame.size.width * .5, self.frame.size.height * .5, _pingModel1.radius - (_pingModel1.borderWidth * .5), 0, M_PI * 2, 0);
    CGContextStrokePath(context);
  
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, _pingModel2.color.CGColor);
    CGContextSetLineWidth(context, _pingModel2.borderWidth);
    CGContextSetShouldAntialias(context, YES);
    CGContextAddArc(context, self.frame.size.width * .5, self.frame.size.height * .5, _pingModel2.radius - (_pingModel2.borderWidth * .5), 0, M_PI * 2, 0);
    CGContextStrokePath(context);

//    CGContextBeginPath(context);
//    CGContextSetStrokeColorWithColor(context, _pingModel3.color.CGColor);
//    CGContextSetLineWidth(context, _pingModel3.borderWidth);
//    CGContextSetShouldAntialias(context, YES);
//    CGContextAddArc(context, self.frame.size.width * .5, self.frame.size.height * .5, _pingModel3.radius - (_pingModel3.borderWidth * .5), 0, M_PI * 2, 0);
//    CGContextStrokePath(context);
}

@end
