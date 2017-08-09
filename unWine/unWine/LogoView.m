//
//  LogoView.m
//  unWine
//
//  Created by Bryce Boesen on 2/22/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "LogoView.h"
#import "ExpandingBubbleView.h"

@interface AnimateLogoView : UIImageView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIColor *color;

@end

@implementation LogoView {
    AnimateLogoView *animateFront;
    AnimateLogoView *animateBack;
    BOOL flipped;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 3.f;
        self.layer.cornerRadius = frame.size.width / 2;
        
        animateFront = [[AnimateLogoView alloc] initWithFrame:(CGRect){0, 0, {WIDTH(self), HEIGHT(self)}}];
        animateFront.layer.doubleSided = NO;
        [self addSubview:animateFront];
        
        animateBack = [[AnimateLogoView alloc] initWithFrame:(CGRect){0, 0, {WIDTH(self), HEIGHT(self)}}];
        animateBack.layer.doubleSided = NO;
        animateBack.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
        [self addSubview:animateBack];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressed)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    animateFront.backgroundColor = backgroundColor;
    animateBack.backgroundColor = backgroundColor;
}

- (BFTask *)showFront:(BOOL)animated {
    BFTaskCompletionSource *complete = [BFTaskCompletionSource taskCompletionSource];
    if(animated) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^(void) {
             animateBack.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
             animateFront.layer.transform = CATransform3DIdentity;
         } completion:^(BOOL finished) {
             [complete setResult:@(finished)];
         }];
    } else {
        animateBack.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
        animateFront.layer.transform = CATransform3DIdentity;
        [complete setResult:@(YES)];
    }
    
    return complete.task;
}

- (BFTask *)showBack:(BOOL)animated {
    BFTaskCompletionSource *complete = [BFTaskCompletionSource taskCompletionSource];
    if(animated) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^(void) {
             animateFront.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
             animateBack.layer.transform = CATransform3DIdentity;
         } completion:^(BOOL finished) {
             [complete setResult:@(finished)];
         }];
    } else {
        animateFront.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
        animateBack.layer.transform = CATransform3DIdentity;
        [complete setResult:@(YES)];
    }
    
    return complete.task;
}

- (void)flip {
    /*[UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^(void) {
         if(!flipped) {
             animateFront.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
             animateBack.layer.transform = CATransform3DIdentity;
         } else {
             animateBack.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
             animateFront.layer.transform = CATransform3DIdentity;
         }
         
         flipped = !flipped;
     } completion:^(BOOL finished) {
     }];*/
}

- (void)pressed {
    [self flip];
    
    if(self.delegate)
        [self.delegate didPressLogo:self];
}

@end

@implementation AnimateLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        //self.layer.cornerRadius = frame.size.width / 2;
        self.backgroundColor = UNWINE_RED; //[UIColor clearColor];
        
        self.image = [UIImage imageNamed:@"shrunkflatuw"];
        [self setContentMode:UIViewContentModeScaleAspectFit];
    }
    return self;
}

/*- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSInteger aSize = 44;
    CGFloat xCenter = aSize / 2;
    CGFloat yCenter = aSize / 2;
    CGFloat w = 38.0;
    CGFloat r = w / 2.0;
    CGFloat flip = -1.0;
    
    CGFloat theta = 2.0 * M_PI * (2.0 / 5.0); // 144 degrees
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, aSize);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    CGContextMoveToPoint(context, xCenter, r * flip + yCenter);
    for (NSUInteger k = 1; k < 5; k++) {
        CGFloat x = r * sin(k * theta);
        CGFloat y = r * cos(k * theta);
        CGContextAddLineToPoint(context, x + xCenter, y * flip + yCenter);
    }
    
    CGContextClosePath(context);
    CGContextFillPath(context);
}*/

@end
