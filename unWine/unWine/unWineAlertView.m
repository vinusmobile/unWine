//
//  unWineAlertView.m
//  unWine
//
//  Created by Bryce Boesen on 10/20/15.
//  Copyright Â© 2015 LION Mobile. All rights reserved.
//

#import "unWineAlertLoginView.h"
#import "unWineAlertView.h"
#import <Bolts/Bolts.h>

#define preferredViewBuffer 16
#define logoDimension 180
#define messageWidth 240
#define minimumMessageHeight 60
#define minimumDisposableHeight 18
#define minimumTitleHeight 30
#define buttonHeight 44
#define buttonWidth 100
#define buttonWidthCenter 130
#define preferredViewWidth 280
#define preferredViewHeight 310

@interface unWineAlertView ()

@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation unWineAlertView {
    UIView *_backView;
    UIView *_alertView;
    
    UIImageView *_logoView;
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UILabel *_orLabel;
    UIButton *_centerButton;
    UIButton *_leftButton;
    UIButton *_rightButton;
    
    UIColor *_backgroundColor;
    UIColor *_labelColor;
    
    UIColor *_leftButtonColor;
    UIColor *_rightButtonColor;
    UIColor *_leftButtonTitleColor;
    UIColor *_rightButtonTitleColor;
    UIColor *_leftButtonBorderColor;
    UIColor *_rightButtonBorderColor;
    
    NSTimer *dispose;
    BOOL isDisposable;
    
    BOOL hasPrepared;
}

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
    //return [[self alloc] init];
}

- (id)prepareWithMessage:(NSString *)message {
    _title = nil; //@"unWine";
    _message = message;
    _leftButtonTitle = nil;
    _centerButtonTitle = @"Ok";
    _rightButtonTitle = nil;
    
    self.tag = 0;
    self.disableDispatch = NO;
    self.emptySpaceDismisses = NO;
    [self shouldShowLogo:NO];
    [self shouldShowOrLabel:NO];
    [self setDefaultColors];
    
    [self prepareWindow];
    
    return self;
}

- (void)setDefaultColors {
    [self setTheme:unWineAlertThemeDefault];
}

- (void)setTheme:(unWineAlertTheme)theme {
    _theme = theme;
    if(theme == unWineAlertThemeDefault) {
        _backgroundColor = [UIColor whiteColor];
        _labelColor = [UIColor darkTextColor];
        _leftButtonColor = UNWINE_GRAY_LIGHT;
        _leftButtonTitleColor = [UIColor whiteColor];
        _leftButtonBorderColor = [UIColor whiteColor];
        _rightButtonColor = UNWINE_GRAY_LIGHT;
        _rightButtonTitleColor = [UIColor whiteColor];
        _rightButtonBorderColor = [UIColor whiteColor];
    } else if(theme == unWineAlertThemeGray) {
        _backgroundColor = UNWINE_GRAY_LIGHT;
        _labelColor = [UIColor whiteColor];
        _leftButtonColor = [UIColor whiteColor];
        _leftButtonTitleColor = UNWINE_RED;
        _leftButtonBorderColor = UNWINE_RED;
        _rightButtonColor = [UIColor whiteColor];
        _rightButtonTitleColor = UNWINE_RED;
        _rightButtonBorderColor = UNWINE_RED;
    } else if(theme == unWineAlertThemeSuccess) {
        _backgroundColor = UNWINE_GRAY_LIGHT;
        _labelColor = [UIColor whiteColor];
        _leftButtonColor = [UIColor whiteColor];
        _leftButtonTitleColor = UNWINE_GREEN;
        _leftButtonBorderColor = UNWINE_GREEN;
        _rightButtonColor = [UIColor whiteColor];
        _rightButtonTitleColor = UNWINE_GREEN;
        _rightButtonBorderColor = UNWINE_GREEN;
    } else if(theme == unWineAlertThemeError) {
        _backgroundColor = UNWINE_RED;
        _labelColor = [UIColor whiteColor];
        _leftButtonColor = [UIColor whiteColor];
        _leftButtonTitleColor = UNWINE_GRAY;
        _leftButtonBorderColor = UNWINE_GRAY;
        _rightButtonColor = [UIColor whiteColor];
        _rightButtonTitleColor = UNWINE_GRAY;
        _rightButtonBorderColor = UNWINE_GRAY;
    } else if(theme == unWineAlertThemeRed) {
        _backgroundColor = [UIColor whiteColor];
        _labelColor = UNWINE_RED;
        _leftButtonColor = UNWINE_RED;
        _leftButtonTitleColor = [UIColor whiteColor];
        _leftButtonBorderColor = [UIColor whiteColor];
        _rightButtonColor = UNWINE_RED;
        _rightButtonTitleColor = [UIColor whiteColor];
        _rightButtonBorderColor = [UIColor whiteColor];
    } else if(theme == unWineAlertThemeYesNo) {
        _backgroundColor = [UIColor whiteColor];
        _labelColor = [UIColor darkTextColor];
        _leftButtonColor = UNWINE_GRAY_LIGHT;
        _leftButtonTitleColor = UNWINE_RED;
        _leftButtonBorderColor = [UIColor whiteColor];
        _rightButtonColor = UNWINE_GRAY_LIGHT;
        _rightButtonTitleColor = UNWINE_GREEN;
        _rightButtonBorderColor = [UIColor whiteColor];
    }
}

- (void)prepareWindow {
    if(!hasPrepared) {
        _alertWindow = [[UIWindow alloc] initWithFrame:(GET_APP_DELEGATE).window.frame];
        _alertWindow.backgroundColor = [UIColor clearColor];
        _alertWindow.windowLevel = UIWindowLevelAlert;
        _alertWindow.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMeMaybe)];
        [_alertWindow addGestureRecognizer:dismiss];
        
        _backView = [[UIView alloc] initWithFrame:_alertWindow.frame];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        [_alertWindow addSubview:_backView];
        
        hasPrepared = YES;
    }
}

- (void)layout {
    UIView *alertView = [self alertView];
    if([alertView.subviews count] > 0)
        [alertView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_alertWindow addSubview:[self alertView]];
    
    NSInteger y = preferredViewBuffer;
    
    UIView *logoView = [self logoView];
    if(_showLogo) {
        [logoView setOrigin:CGPointMake((preferredViewWidth - logoDimension) / 2, y)];
        [alertView addSubview:logoView];
        y += HEIGHT(logoView);
    }
    
    UILabel *titleLabel = [self titleLabel];
    if(ISVALID(self.title)) {
        [titleLabel setOrigin:CGPointMake((preferredViewWidth - messageWidth) / 2, y)];
        [alertView addSubview:titleLabel];
        y += HEIGHT(titleLabel) + 6;
    }
    
    UILabel *messageLabel = [self messageLabel];
    NSInteger messageOutset = 8;
    if(ISVALID(self.message)) {
        [messageLabel setOrigin:CGPointMake((preferredViewWidth - messageWidth) / 2, y)];
        [alertView addSubview:messageLabel];
        y += HEIGHT(messageLabel) + 6;
    }
    
    [self checkButtons];
    
    UILabel *orLabel = [self orLabel];
    NSInteger orX = preferredViewWidth / 2 - 15;
    if(self.showOrLabel) {
        [orLabel setOrigin:CGPointMake(orX, y + messageOutset)];
        [alertView addSubview:orLabel];
    }
    
    NSInteger orOutset = self.showOrLabel ? 6 : 2;
    if(ISVALID(self.centerButtonTitle)) {
        UIButton *centerButton = [self centerButton];
        [centerButton setOrigin:CGPointMake((preferredViewWidth - WIDTH(centerButton)) / 2, y + messageOutset)];
        [alertView addSubview:centerButton];
        y += HEIGHT(centerButton);
    } else if(ISVALID(self.leftButtonTitle) && ISVALID(self.rightButtonTitle)) {
        UIButton *leftButton = [self leftButton];
        [leftButton setOrigin:CGPointMake(orX - buttonWidth - orOutset, y + messageOutset)];
        [alertView addSubview:leftButton];
        
        UIButton *rightButton = [self rightButton];
        [rightButton setOrigin:CGPointMake(orX + WIDTH(orLabel) + orOutset, y + messageOutset)];
        [alertView addSubview:rightButton];
        
        y += HEIGHT(leftButton);
    } else {
        y -= 16;
    }
    
    [alertView setFrame:CGRectMake(0, 0, preferredViewWidth, y + preferredViewBuffer + messageOutset)];
}

- (void)checkButtons {
    if(_leftButtonTitle && _rightButtonTitle) {
        _centerButtonTitle = nil;
    } else if(_leftButtonTitle && !_centerButtonTitle) {
        _centerButtonTitle = _leftButtonTitle;
        _leftButtonTitle = nil;
    } else if(_rightButtonTitle && !_centerButtonTitle) {
        _centerButtonTitle = _rightButtonTitle;
        _rightButtonTitle = nil;
    }/* else if(!_centerButtonTitle) {
        _centerButtonTitle = @"Ok";
    }*/
    
    if(_centerButtonTitle)
        [self shouldShowOrLabel:NO];
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setCenterButtonTitle:(NSString *)centerButtonTitle {
    _centerButtonTitle = centerButtonTitle;
    _leftButtonTitle = nil;
    _rightButtonTitle = nil;
}

- (void)setRightButtonTitle:(NSString *)rightButtonTitle {
    _rightButtonTitle = rightButtonTitle;
    _centerButtonTitle = nil;
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle {
    _leftButtonTitle = leftButtonTitle;
    _centerButtonTitle = nil;
}

- (void)shouldShowOrLabel:(BOOL)hmm {
    _showOrLabel = hmm;
}

- (void)shouldShowLogo:(BOOL)hmm {
    _showLogo = hmm;
}

- (UIView *)alertView {
    UIView *alertView = _alertView;
    
    if(!alertView) {
        alertView = [UIView new];
        
        alertView.layer.borderColor = [[UIColor clearColor] CGColor];
        alertView.layer.cornerRadius = 16;
        alertView.userInteractionEnabled = YES;
        alertView.clipsToBounds = YES;
        alertView.exclusiveTouch = YES;
        
        UITapGestureRecognizer *nothing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
        [alertView addGestureRecognizer:nothing];
    }
    
    alertView.backgroundColor = _backgroundColor;
    
    return (_alertView = alertView);
}

- (UIImageView *)logoView {
    UIImageView *logoView = _logoView;
    
    if(!logoView) {
        logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoDimension, 120)];
        
        logoView.contentMode = UIViewContentModeScaleAspectFit;
        logoView.image = [UIImage imageNamed:@"unWineLogo"];
    }
    
    return (_logoView = logoView);
}

- (UILabel *)titleLabel {
    UILabel *titleLabel = _titleLabel;
    
    if(!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, messageWidth, minimumTitleHeight)];
        
        [titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.minimumScaleFactor = 1;
        titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    titleLabel.textColor = _labelColor;
    
    if(self.title) {
        [titleLabel setText:self.title];
        [titleLabel sizeToFit];
        if(HEIGHT(titleLabel) < minimumTitleHeight)
            [titleLabel setSize:CGSizeMake(messageWidth, minimumTitleHeight + 2)];
        else
            [titleLabel setSize:CGSizeMake(messageWidth, HEIGHT(titleLabel) + 6)];
        
        titleLabel.layer.sublayers = nil;
        
        if(self.message) {
            CALayer *border = [CALayer layer];
            border.backgroundColor = [_labelColor CGColor];
            border.frame = CGRectMake(24, titleLabel.frame.size.height - 1, titleLabel.frame.size.width - 48, .5);
            [titleLabel.layer addSublayer:border];
        }
    }
    
    return (_titleLabel = titleLabel);
}

- (UILabel *)messageLabel {
    UILabel *messageLabel = _messageLabel;
    
    if(!messageLabel) {
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, messageWidth, 90)];
        
        [messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        messageLabel.minimumScaleFactor = 1;
        messageLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    messageLabel.textColor = _labelColor;
    
    if(self.message) {
        [messageLabel setText:self.message];
        [messageLabel sizeToFit];
        
        NSInteger min = !isDisposable ? minimumMessageHeight : minimumDisposableHeight;
        if(HEIGHT(messageLabel) < min)
            [messageLabel setSize:CGSizeMake(messageWidth, min)];
        else
            [messageLabel setSize:CGSizeMake(messageWidth, HEIGHT(messageLabel))];
    }
    
    return (_messageLabel = messageLabel);
}

- (UILabel *)orLabel {
    UILabel *orLabel = _orLabel;
    
    if(!orLabel) {
        orLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, buttonHeight)];
        
        [orLabel setText:@"or"];
        [orLabel setFont:[UIFont fontWithName:@"OpenSans" size:15]];
        orLabel.textAlignment = NSTextAlignmentCenter;
        orLabel.numberOfLines = 0;
    }
    
    orLabel.textColor = _labelColor;
    
    return (_orLabel = orLabel);
}

- (UIButton *)leftButton {
    UIButton *leftButton = _leftButton;
    
    if(!leftButton) {
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        
        leftButton.layer.borderWidth = 1.5f;
        leftButton.layer.cornerRadius = 8;
        leftButton.clipsToBounds = YES;
        
        leftButton.titleLabel.numberOfLines = 1;
        leftButton.titleLabel.minimumScaleFactor = 8;
        leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [leftButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        
        [leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [leftButton setTitleColor:_leftButtonTitleColor forState:UIControlStateNormal];
    leftButton.layer.borderColor = [_leftButtonBorderColor CGColor];
    leftButton.backgroundColor = _leftButtonColor;
    
    if(_leftButtonTitle != nil)
        [leftButton setTitle:_leftButtonTitle forState:UIControlStateNormal];
    
    return (_leftButton = leftButton);
}

- (UIButton *)centerButton {
    UIButton *centerButton = _centerButton;
    
    if(!centerButton) {
        centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [centerButton setFrame:CGRectMake(0, 0, buttonWidthCenter, buttonHeight)];
        
        centerButton.layer.borderWidth = 1.5f;
        centerButton.layer.cornerRadius = 8;
        centerButton.clipsToBounds = YES;
        
        centerButton.titleLabel.numberOfLines = 1;
        centerButton.titleLabel.minimumScaleFactor = 8;
        centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [centerButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        
        [centerButton addTarget:self action:@selector(centerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [centerButton setTitleColor:_rightButtonTitleColor forState:UIControlStateNormal];
    centerButton.layer.borderColor = [_rightButtonBorderColor CGColor];
    centerButton.backgroundColor = _rightButtonColor;
    
    if(_centerButtonTitle)
        [centerButton setTitle:_centerButtonTitle forState:UIControlStateNormal];
    
    return (_centerButton = centerButton);
}

- (UIButton *)rightButton {
    UIButton *rightButton = _rightButton;
    
    if(!rightButton) {
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        
        rightButton.layer.borderWidth = 1.5f;
        rightButton.layer.cornerRadius = 8;
        rightButton.clipsToBounds = YES;
        
        rightButton.titleLabel.numberOfLines = 1;
        rightButton.titleLabel.minimumScaleFactor = 8;
        rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [rightButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        
        [rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [rightButton setTitleColor:_rightButtonTitleColor forState:UIControlStateNormal];
    rightButton.layer.borderColor = [_rightButtonBorderColor CGColor];
    rightButton.backgroundColor = _rightButtonColor;
    
    if(_rightButtonTitle)
        [rightButton setTitle:_rightButtonTitle forState:UIControlStateNormal];
    
    return (_rightButton = rightButton);
}

- (void)showDisposable {
    if(dispose) {
        [dispose invalidate];
        dispose = nil;
    }
    
    isDisposable = YES;
    [self show];
    CGFloat time = ISVALID(self.message) ? self.message.length / 15.f : .8;
    dispose = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hideDisposable) userInfo:nil repeats:NO];
}

- (void)show {
    if(dispose) {
        [dispose invalidate];
        dispose = nil;
        isDisposable = NO;
    }
    
    if (self.disableDispatch) {
        [self showAlert];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert];
        });
    }
}

- (void)showAlert {
    [self layout];
    
    if([_alertWindow isHidden])
        [_alertWindow setHidden:NO];
    else
        [_alertWindow makeKeyAndVisible];
    _alertWindow.tintColor = [UIColor whiteColor];
    
    _alertView.center = (GET_APP_DELEGATE).window.center;
    _alertView.alpha = 0;
    _backView.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        _alertView.alpha = !isDisposable ? 1 : .75;
        _backView.alpha = .4;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideDisposable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (BFTask *)hide {
    BFTaskCompletionSource *successful = [BFTaskCompletionSource taskCompletionSource];
    
    [UIView animateWithDuration:.3 animations:^{
        _alertView.alpha = 0;
        _backView.alpha = 0;
    } completion:^(BOOL finished) {
        //[_alertView removeFromSuperview];
        [_alertWindow setHidden:YES];
        [successful setResult:@"The good result."];
    }];
    
    return successful.task;
}

- (void)dismissMeMaybe {
    if(self.emptySpaceDismisses) {
        [[self hide] continueWithSuccessBlock:^id(BFTask *task) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(dismissedByEmptySpace)])
                [self.delegate dismissedByEmptySpace];
            
            return nil;
        }];
    }
}

- (void)doNothing { }

- (void)leftButtonPressed {
    [[self hide] continueWithSuccessBlock:^id(BFTask *task) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(leftButtonPressed)])
            [self.delegate leftButtonPressed];
        
        return nil;
    }];
}

- (void)centerButtonPressed {
    [[self hide] continueWithSuccessBlock:^id(BFTask *task) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(centerButtonPressed)])
            [self.delegate centerButtonPressed];
        
        return nil;
    }];
}

- (void)rightButtonPressed {
    [[self hide] continueWithSuccessBlock:^id(BFTask *task) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(rightButtonPressed)])
            [self.delegate rightButtonPressed];
        
        return nil;
    }];
}

+ (void)showAlertViewWithBasicSuccess:(NSString *)message {
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = unWineAlertThemeSuccess;
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                   yesNoTitles:(NSArray *)buttons {
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = unWineAlertThemeYesNo;
    alertView.title = title;
    alertView.leftButtonTitle = [buttons count] > 0 ? [buttons objectAtIndex:0] : @"";
    alertView.rightButtonTitle = [buttons count] > 1 ? [buttons objectAtIndex:1] : @"";
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title error:(NSError *)error {
    NSString *message = [error localizedDescription];
    if (!message)
        message = error.userInfo[@"error"];
    
    if (!message)
        message = [error.userInfo[@"originalError"] localizedDescription];
    
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = unWineAlertThemeError;
    alertView.title = title;
    alertView.centerButtonTitle = NSLocalizedString(@"Ok", @"Ok");
    [alertView show];
}

+ (void)showAlertViewWithoutDispatchWithTitle:(NSString *)title error:(NSError *)error {
    NSString *message = error.userInfo[@"error"];
    if (!message)
        message = [error.userInfo[@"originalError"] localizedDescription];
    
    if (!message)
        message = [error localizedDescription];
    
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = unWineAlertThemeError;
    alertView.title = title;
    alertView.centerButtonTitle = NSLocalizedString(@"Ok", @"Ok");
    alertView.disableDispatch = YES;
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message theme:(unWineAlertTheme)theme {
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = theme;
    alertView.title = title;
    alertView.centerButtonTitle = NSLocalizedString(@"Ok", @"Ok");
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertViewWithTitle:title
                         message:message
               cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")];
}

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle {
    
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = unWineAlertThemeDefault;
    alertView.title = title;
    alertView.centerButtonTitle = cancelButtonTitle;
    [alertView show];
}

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle
                         theme:(unWineAlertTheme)theme{
    
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = theme;
    alertView.title = title;
    alertView.centerButtonTitle = cancelButtonTitle;
    [alertView show];
}

+ (void)showDisposableAlertView:(NSString *)message
                          theme:(unWineAlertTheme)theme {
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alertView.theme = theme;
    alertView.title = nil;
    alertView.emptySpaceDismisses = YES;
    alertView.centerButtonTitle = nil;
    alertView.rightButtonTitle = nil;
    alertView.leftButtonTitle = nil;
    alertView.disableDispatch = YES;
    [alertView showDisposable];
}

@end

@implementation UIView (Origin)

- (void)setOrigin:(CGPoint)origin {
    CGRect temp = self.frame;
    temp.origin.x = origin.x;
    temp.origin.y = origin.y;
    self.frame = temp;
}

- (void)setSize:(CGSize)size {
    CGRect temp = self.frame;
    temp.size.width = size.width;
    temp.size.height = size.height;
    self.frame = temp;
}

@end
