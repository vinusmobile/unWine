//
//  ChevronView.m
//  unWine
//
//  Created by Bryce Boesen on 3/9/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "ChevronView.h"

@implementation ChevronView {
    UIColor *originalTintColor;
    BOOL isTouchDown;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setInverted:(BOOL)inverted {
    _inverted = inverted;
    
    //TODO rotate 180 degrees
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGPoint origin = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat outset = rect.size.height / 4;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(origin.x - outset, origin.y + outset / 2)];
    [path addLineToPoint:CGPointMake(origin.x, origin.y - outset + outset / 2)];
    [path addLineToPoint:CGPointMake(origin.x + outset, origin.y + outset / 2)];
    
    [self.tintColor set];
    [path setLineWidth:4];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    isTouchDown = YES;
    originalTintColor = self.tintColor;
    self.tintColor = [UIColor darkGrayColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isTouchDown) {
        self.tintColor = originalTintColor;
        isTouchDown = NO;
        
        if(self.delegate)
            [self.delegate chevronPressed:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isTouchDown) {
        self.tintColor = originalTintColor;
        isTouchDown = NO;
    }
}

@end
