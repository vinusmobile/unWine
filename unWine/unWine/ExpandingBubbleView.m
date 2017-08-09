//
//  BubbleView.m
//  unWine
//
//  Created by Bryce Boesen on 2/22/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "ExpandingBubbleView.h"
#import "LogoView.h"

#define EXPANSE_COLOR [UIColor colorWithRed:.98 green:.99 blue:.97 alpha:.9]

@interface ButtonData : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *image;
@property (nonatomic) id target;
@property (nonatomic) SEL action;

+ (ButtonData *)title:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;

@end

@interface BubbleView : UIView

@property (nonatomic) ExpandingBubbleView *parent;

@property (nonatomic) ButtonData *data;
@property (nonatomic) UIButton *button;
@property (nonatomic) UILabel *label;

- (instancetype)initWithFrame:(CGRect)frame data:(ButtonData *)data;
- (void)expand;
- (void)removeUnderLayer;

@end

@implementation ExpandingBubbleView {
    NSMutableArray<ButtonData *> *_buttonData;
    NSMutableArray<BubbleView *> *_floatingButtons;
    UIView *_delicateView;
    UIView *_constraintView;
    CGPoint _panCoord;
    CGRect logoViewFrame;
}

- (void)addBubble:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    if(!_buttonData)
        _buttonData = [[NSMutableArray alloc] init];
    
    [_buttonData addObject:[ButtonData title:title image:image target:target action:action]];
}

- (BFTask *)show {
    //LOGGER(@"bubbles");
    [self setup];
    
    CGFloat startX = SEMIWIDTH(self);
    CGFloat startY = HEIGHT(_constraintView) / 2 - FB_SIZE / 4;
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    logoViewFrame = [self getLogoView].frame;
    [UIView animateWithDuration:.2 animations:^{
        [self getLogoView].frame = CGRectMake(startX - FB_SIZE / 2, (startY - FB_SIZE / 2) + HEIGHT(_constraintView) + FB_OUTSET, FB_SIZE, FB_SIZE);
        /*for(BubbleView *bubble in _floatingButtons) {
            [bubble setFrame:CGRectMake(startX - FB_SIZE / 2, startY - FB_SIZE / 2, FB_SIZE, FB_SIZE)];
        }*/
    } completion:^(BOOL finished) {
        for(BubbleView *bubble in _floatingButtons) {
            [bubble setFrame:CGRectMake(startX - FB_SIZE / 2, startY - FB_SIZE / 2, FB_SIZE, FB_SIZE)];
            bubble.alpha = 1;
        }
        
        [UIView animateWithDuration:.2 animations:^{
            for(NSInteger i = 0; i < [_buttonData count]; i++) {
                BubbleView *bubble = [_floatingButtons objectAtIndex:i];
                CGRect rect = CGRectMake(
                                         startX + FB_OUTSET * cosf(2.f * M_PI / [_buttonData count] * i - M_PI / 2.f) - FB_SIZE / 2,
                                         startY + FB_OUTSET * sinf(2.f * M_PI / [_buttonData count] * i - M_PI / 2.f) - FB_SIZE / 2,
                                         FB_SIZE, FB_SIZE);
                [bubble setFrame:rect];
            }
            [self getLogoView].alpha = 0;
        } completion:^(BOOL finished) {
            for(NSInteger i = 0; i < [_buttonData count]; i++) {
                BubbleView *bubble = [_floatingButtons objectAtIndex:i];
                [bubble expand];
            }
            
            [source setResult:@(YES)];
        }];
    }];
    
    return source.task;
}

- (BFTask *)hide {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    if(_floatingButtons) {
        CGFloat startX = SEMIWIDTH(self);
        CGFloat startY = HEIGHT(_constraintView) / 2 - FB_SIZE / 4;
        //_constraintView.backgroundColor = EXPANSE_COLOR;
        for(BubbleView *bubble in _floatingButtons)
            [bubble removeUnderLayer];
        
        [UIView animateWithDuration:.15 animations:^{
            [_delicateView removeFromSuperview];
            _constraintView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            __block BOOL /*hasRun1 = NO, */hasRun2 = NO;
            for(BubbleView *bubble in _floatingButtons) {
                [UIView animateWithDuration:.2 animations:^{
                    bubble.label.alpha = 0;
                    [bubble setFrame:CGRectMake(startX - FB_SIZE / 2, startY - FB_SIZE / 2, 1, 1)];
                    /*if(!hasRun1) {
                        hasRun1 = YES;
                        [self getLogoView].alpha = 1;
                    }*/
                } completion:^(BOOL finished) {
                    [bubble removeFromSuperview];
                    
                    [_delicateView removeFromSuperview];
                    _floatingButtons = nil;
                    
                    if(!hasRun2) {
                        hasRun2 = YES;
                        [self getLogoView].alpha = 1;
                        [UIView animateWithDuration:.15 animations:^{
                            [self getLogoView].frame = logoViewFrame;
                        } completion:^(BOOL finished) {
                            [source setResult:@(YES)];
                        }];
                    }
                }];
                
                CGFloat estimateCorner = .5;
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                animation.fromValue = @(bubble.layer.cornerRadius);
                animation.toValue = @(estimateCorner);
                animation.duration = .15;
                [bubble.layer setCornerRadius:estimateCorner];
                [bubble.layer addAnimation:animation forKey:@"cornerRadius"];
            }
            
            if([_floatingButtons count] == 0) {
                [UIView animateWithDuration:.15 animations:^{
                    [self getLogoView].frame = logoViewFrame;
                } completion:^(BOOL finished) {
                    [source setResult:@(NO)];
                }];
            }
        }];
    } else {
        [UIView animateWithDuration:.15 animations:^{
            [self getLogoView].frame = logoViewFrame;
        } completion:^(BOOL finished) {
            [source setResult:@(NO)];
        }];
    }
    
    return [source.task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self removeFromSuperview];
        //[[(GET_APP_DELEGATE).ctbc logoView] flip];
        return task;
    }];
}

- (void)setup { /*Bubbles*/
    if(!_buttonData)
        _buttonData = [[NSMutableArray alloc] init];
    
    CGFloat startX = SEMIWIDTH(self);
    
    if(_floatingButtons == nil) {
        _floatingButtons = [[NSMutableArray alloc] init];
        
        _delicateView = [[UIView alloc] initWithFrame:self.frame];
        _delicateView.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.6];
        _delicateView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_delicateView addGestureRecognizer:dismiss];
        
        [self addSubview:_delicateView];
        
        _constraintView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT * .55, SCREEN_WIDTH, SCREENHEIGHT * .45)];
        _constraintView.clipsToBounds = NO;
        _constraintView.backgroundColor = [UIColor clearColor];
        
        unWineAppDelegate *delegate = (GET_APP_DELEGATE);
        if(delegate.environment == DEVELOPMENT) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT(_constraintView) - 20, 150, 20)];
            label.backgroundColor = UNWINE_RED;
            label.textColor = [UIColor whiteColor];
            label.text = @"Development";
            [label sizeToFit];
            [_constraintView addSubview:label];
        } else if(delegate.environment == LOCAL) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT(_constraintView) - 20, 150, 20)];
            label.backgroundColor = UNWINE_RED;
            label.textColor = [UIColor whiteColor];
            label.text = @"Local";
            [label sizeToFit];
            [_constraintView addSubview:label];
        }
        
        UITapGestureRecognizer *dismiss2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_constraintView addGestureRecognizer:dismiss2];
        
        [self addSubview:_constraintView];
        
        for(NSInteger i = 0; i < [_buttonData count]; i++) {
            ButtonData *data = [_buttonData objectAtIndex:i];
            BubbleView *button = [[BubbleView alloc] initWithFrame:CGRectMake(startX - FB_SIZE / 2, Y2([self getLogoView]) - HEIGHT(_constraintView), FB_SIZE, FB_SIZE) data:data];
            button.alpha = 0;
            button.parent = self;
            
            //UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
            //[button addGestureRecognizer:gesture];
            
            [_floatingButtons addObject:button];
            [_constraintView addSubview:button];
        }
    }
}

- (void)dragging:(UIPanGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan)
        _panCoord = [gesture locationInView:gesture.view];
    
    CGPoint newCoord = [gesture locationInView:gesture.view];
    float dX = newCoord.x - _panCoord.x;
    float dY = newCoord.y - _panCoord.y;
    
    gesture.view.frame = CGRectMake(gesture.view.frame.origin.x + dX, gesture.view.frame.origin.y + dY, gesture.view.frame.size.width, gesture.view.frame.size.height);
}

- (LogoView *)getLogoView {
    return [[LogoView alloc] init];
    //return (GET_APP_DELEGATE).ctbc.logoView;
}

@end

@implementation BubbleView {
    UIView *underLayer;
}

- (instancetype)initWithFrame:(CGRect)frame data:(ButtonData *)data {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.layer.zPosition = 2;
        self.backgroundColor = [UIColor clearColor];
        self.data = data;
        
        [self setupBubble];
        [self setupLabel];
    }
    return self;
}

- (void)setupBubble {
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setFrame:CGRectMake(0, 0, WIDTH(self), HEIGHT(self))];
    [_button setImage:_data.image forState:UIControlStateNormal];
    [_button setContentMode:UIViewContentModeScaleAspectFit];
    [_button addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    _button.backgroundColor = UNWINE_RED;
    _button.tintColor = [UIColor whiteColor];
    _button.layer.borderColor = [[UIColor whiteColor] CGColor];
    _button.layer.borderWidth = 3.f;
    _button.layer.cornerRadius = FB_SIZE / 2;
    _button.layer.zPosition = 5;
    _button.userInteractionEnabled = YES;
    [self addSubview:_button];
}

- (void)setupLabel {
    CGRect frame = _button.frame;
    frame.origin.x -= 20;
    frame.origin.y = frame.size.height;
    frame.size.height = 18;
    frame.size.width += 40;
    
    _label = [[UILabel alloc] initWithFrame:frame];
    [_label setFont:[UIFont fontWithName:[ThemeHandler getFontNameBold] size:12]];
    [_label setTextColor:[UIColor blackColor]];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setText:_data.title];
    [self addSubview:_label];
}

- (void)expand {
    underLayer = [[UIView alloc] initWithFrame:self.frame];
    underLayer.clipsToBounds = YES;
    underLayer.backgroundColor = EXPANSE_COLOR;
    underLayer.layer.cornerRadius = self.layer.cornerRadius;
    underLayer.layer.zPosition = 0;
    underLayer.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self.parent action:@selector(hide)];
    [underLayer addGestureRecognizer:dismiss];
    
    [self.superview addSubview:underLayer];
    [self.superview sendSubviewToBack:underLayer];
    float duration = .35;
    
    CGFloat dim = WIDTH(self) * 2;
    underLayer.layer.cornerRadius = WIDTH(self) / 2;
    [UIView animateWithDuration:duration animations:^{
        underLayer.frame = CGRectMake(0, 0, dim, dim);
        underLayer.center = self.center;
    } completion:^(BOOL finished) {
        //underLayer.superview.backgroundColor = underLayer.backgroundColor;
    }];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = @(underLayer.layer.cornerRadius);
    animation.toValue = @(dim / 2);
    animation.duration = duration;
    [underLayer.layer setCornerRadius:dim / 2];
    [underLayer.layer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)removeUnderLayer {
    [underLayer removeFromSuperview];
}

- (void)tapped {
    NSLog(@"tapped - %@", _data.title);
    NSString *event = [NSString stringWithFormat:@"UserTapped%@TabFromHUB", _data.title];
    ANALYTICS_TRACK_EVENT(event);
    [[_parent hide] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        if(_data.target && _data.action)
            ((void (*)(id, SEL))[_data.target methodForSelector:_data.action])(_data.target, _data.action);
        
        return nil;
    }];
}


@end

@implementation ButtonData

+ (ButtonData *)title:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    ButtonData *data = [[ButtonData alloc] init];
    data.title = title;
    data.target = target;
    data.action = action;
    data.image = image;
    return data;
}

@end
