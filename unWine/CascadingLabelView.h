//
//  CascadingLabelView.h
//  unWine
//
//  Created by Bryce Boesen on 8/27/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

@interface CascadingLabelView : UIView

struct Padding {
    NSInteger topPadding;
    NSInteger leftPadding;
    NSInteger bottomPadding;
    NSInteger rightPadding;
};
typedef struct Padding Padding;

enum AnimationStyle {
    FLOATUP = 0,
    FLOATDOWN,
    FLOATRIGHT,
    FLOATLEFT,
    FADEIN,
    NADA
};
typedef enum AnimationStyle AnimationStyle;

@property (readonly, nonatomic) BOOL isDynamic;
@property (readonly, nonatomic) NSTimeInterval animationSpeed;
@property (readonly, nonatomic) Padding padding;
@property (readonly, nonatomic) AnimationStyle animationStyle;
@property (readonly, nonatomic) NSInteger cellBuffer;
@property (readonly, nonatomic) UIFont* globalFont;

- (void)setDynamic:(BOOL)dynamic;
- (void)setPadding:(Padding)padding;
- (void)setBuffer:(NSInteger)spacing;
- (void)setFont:(UIFont *)font;
- (void)update;
- (void)setup;

@end

CG_INLINE Padding PaddingMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    Padding padding;
    padding.topPadding = top; padding.leftPadding = left;
    padding.bottomPadding = bottom; padding.rightPadding = right;
    return padding;
}
