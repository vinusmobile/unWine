//
//  CascadingLabelView.m
//  unWine
//
//  Created by Bryce Boesen on 8/27/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "CascadingLabelView.h"

#define defaultBuffer 6

@implementation CascadingLabelView {
    NSInteger lastWidth, lastHeight, lastSize;
    NSMutableArray *queue;
    BOOL hasSetup, swap;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame cellBuffer:defaultBuffer];
}

- (id)initWithFrame:(CGRect)frame cellBuffer:(NSInteger)buffer {
    return [self initWithFrame:frame viewPadding:PaddingMake(0, 0, 0, 0) cellBuffer:buffer];
}

- (id)initWithFrame:(CGRect)frame viewPadding:(Padding)padding cellBuffer:(NSInteger)buffer {
    return [self initWithFrame:frame viewPadding:padding cellBuffer:buffer animationStyle:NADA];
}

- (id)initWithFrame:(CGRect)frame viewPadding:(Padding)padding cellBuffer:(NSInteger)buffer animationStyle:(AnimationStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setup];
        _padding = padding;
        _animationStyle = style;
        _cellBuffer = buffer;
        if(_animationStyle != NADA)
            queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setup {
    hasSetup = YES;
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    _padding = PaddingMake(0, 0, 0, 0);
    _animationStyle = NADA;
    _cellBuffer = defaultBuffer;
    _globalFont = nil;
    _isDynamic = NO;
    lastSize = HEIGHT(self);
    lastWidth = self.padding.leftPadding;
    lastHeight = self.padding.topPadding;
}

- (void)setPadding:(Padding)padding {
    if(!hasSetup)
        [self setup];
    
    _padding = padding;
    if([[self subviews] count] > 0)
        [self update];
}

- (void)setDynamic:(BOOL)dynamic {
    if(!hasSetup)
        [self setup];
    
    _isDynamic = dynamic;
    if([[self subviews] count] > 0)
        [self update];
}

- (void)setBuffer:(NSInteger)spacing {
    if(!hasSetup)
        [self setup];
    
    _cellBuffer = spacing;
    if([[self subviews] count] > 0)
        [self update];
}

- (void)setFont:(UIFont *)font {
    if(!hasSetup)
        [self setup];
    
    _globalFont = font;
    if([[self subviews] count] > 0)
        [self update];
}

- (void)addSubview:(UIView *)view {
    if(!hasSetup)
        [self setup];
    
    if([view class] == [UILabel class]) {
        UILabel *label = (UILabel *)view;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        
        [super addSubview:label];
    } else if([view class] == [UIButton class]) {
        UIButton *button = (UIButton *)view;
        [button.titleLabel sizeToFit];
        [button setFrame:button.titleLabel.frame];
        
        [super addSubview:button];
    } else {
        [super addSubview:view];
    }
}

- (void)update {
    NSArray *views = [self subviews];
    NSInteger c = [views count];
    
    if(_animationStyle != NADA) {
    } else {
        if(_padding.topPadding == 0 && _padding.bottomPadding == 0) {
            NSInteger size = 0;
            NSInteger left = _padding.leftPadding, right = _padding.rightPadding;
            
            for(NSUInteger i = 0; i < c; i++) {
                UIView *view = (UIView *)[views objectAtIndex:i];
                if(view.alpha == 0)
                    continue;
                
                if([[views objectAtIndex:i] class] == [UILabel class]) {
                    UILabel *label = (UILabel *)view;
                    
                    if(_globalFont != nil)
                        [label setFont:_globalFont];
                } else if([[views objectAtIndex:i] class] == [UIButton class]) {
                    UIButton *button = (UIButton *)view;
                    
                    if(_globalFont != nil)
                        [button.titleLabel setFont:_globalFont];
                } else if([[views objectAtIndex:i] class] == [UITextView class]) {
                    UITextView *textView = (UITextView *)view;
                    
                    if(_globalFont != nil)
                        [textView setFont:_globalFont];
                }
                
                [view setFrame:CGRectMake(left, _cellBuffer, WIDTH(self) - left - right, HEIGHT(view))];
                [view sizeToFit];
                
                size += HEIGHT(view) + _cellBuffer;
            }
            
            NSInteger top = (int)(HEIGHT(self) - size - _cellBuffer) / 2;
            for(NSUInteger i = 0; i < c; i++) {
                UIView *view = [views objectAtIndex:i];
                if(view.alpha == 0)
                    continue;
                
                [view setFrame:CGRectMake(left, top + _cellBuffer, WIDTH(self) - left - right, HEIGHT(view))];
                top += HEIGHT(view) + _cellBuffer;
            }
            
            lastSize = HEIGHT(self) - size;
            if(lastSize <= 0 && !_isDynamic) {
                c = [views count];
                if(!swap)
                    for(NSUInteger i = 0; i < c; i++) {
                        if([[views objectAtIndex:i] class] == [UILabel class]) {
                            UILabel *label = (UILabel *)[views objectAtIndex:i];
                            if(label.alpha == 0)
                                continue;
                            
                            label.font = [UIFont fontWithName:label.font.fontName size:(label.font.pointSize - 1)];
                        } else if([[views objectAtIndex:i] class] == [UIButton class]) {
                            UIButton *button = (UIButton *)[views objectAtIndex:i];
                            if(button.alpha == 0)
                                continue;
                            
                            button.titleLabel.font = [UIFont fontWithName:button.titleLabel.font.fontName size:(button.titleLabel.font.pointSize - 1)];
                        } else if([[views objectAtIndex:i] class] == [UITextView class]) {
                            UITextView *textView = (UITextView *)[views objectAtIndex:i];
                            if(textView.alpha == 0)
                                continue;
                            
                            textView.font = [UIFont fontWithName:textView.font.fontName size:(textView.font.pointSize - 1)];
                        }
                    }
                else
                    _cellBuffer--;
                swap = !swap;
                
                [self update];
            } else if(lastSize <= 0 && _isDynamic) {
                self.frame = CGRectMake(X3(self.bounds), Y3(self.bounds), WIDTH(self), lastSize + _padding.topPadding + _padding.bottomPadding);
            }
        } else {
            NSInteger top = _padding.topPadding; //, bottom = _padding.bottomPadding;
            NSInteger left = _padding.leftPadding, right = _padding.rightPadding;
            
            for(NSUInteger i = 0; i < c; i++) {
                UIView *view = (UIView *)[views objectAtIndex:i];
                if(view.alpha == 0)
                    continue;
                
                if([[views objectAtIndex:i] class] == [UILabel class]) {
                    UILabel *label = (UILabel *)view;
                    
                    if(_globalFont != nil)
                        [label setFont:_globalFont];
                } else if([[views objectAtIndex:i] class] == [UIButton class]) {
                    UIButton *button = (UIButton *)view;
                    
                    if(_globalFont != nil)
                        [button.titleLabel setFont:_globalFont];
                } else if([[views objectAtIndex:i] class] == [UITextView class]) {
                    UITextView *textView = (UITextView *)view;
                    
                    if(_globalFont != nil)
                        [textView setFont:_globalFont];
                }
                
                [view setFrame:CGRectMake(left, top, WIDTH(self) - left - right, HEIGHT(view))];
                [view sizeToFit];
                
                top += HEIGHT(view) + _cellBuffer;
            }
            
            if(top > HEIGHT(self) && !_isDynamic) {
                _cellBuffer--;
                [self update];
            } else if(top > HEIGHT(self) && _isDynamic) {
                self.frame = CGRectMake(X3(self.bounds), Y3(self.bounds), WIDTH(self), top + _padding.topPadding + _padding.bottomPadding);
            }
        }
    }
}

- (void)checkAnimationQueue {
    
}

@end