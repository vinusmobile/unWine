//
//  FacebookButtonView.m
//  unWine
//
//  Created by Fabio Gomez on 3/5/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "LoginGenericButtonView.h"
#import "MainLogInViewController.h"
#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>

// These tags are setup on the Interface Builder on the MainNew Storyboard
#define LOGIN_BUTTON_TAG    0
#define FACEBOOK_BUTTON_TAG 1
#define SIGN_UP_BUTTON_TAG  2
#define LOGIN_METHOD_TAG    3

#define FACEBOOK_BUTTON_ICON [UIImage imageNamed:@"fbButtonIcon.png"]
#define LOGIN_BUTTON_ICON [UIImage imageNamed:@"loginButtonIcon.png"]

#define LOGIN_BUTTON_COLOR [UIColor colorWithRed:0.278 green:0.29 blue:0.298 alpha:1]

@implementation LoginGenericButtonView
@synthesize parentController, iconView, titleLabel;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)layoutSubviews {
    if (self.iconView) {
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.titleLabel.font = UNWINE_FONT_TEXT_SMALL;
    } else{
        self.titleLabel.font = UNWINE_FONT_TEXT;
    }
    
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

- (void)doFacebookSetup {
    self.backgroundColor = FACEBOOK_COLOR;
    self.titleLabel.text = @"Log in with Facebook";
    self.iconView.image = FACEBOOK_BUTTON_ICON;
    self.tag = FACEBOOK_BUTTON_TAG;
    
    //CGFloat y = SCREENHEIGHT/2 + HEIGHT(self);

    //self.frame = CGRectMake(X2(self), y, WIDTH(self), HEIGHT(self));
    
}

- (void)doRegularSetup {
    self.backgroundColor = LOGIN_BUTTON_COLOR;
    self.titleLabel.text = @"Log in";
    self.iconView.image = LOGIN_BUTTON_ICON;
    self.tag = LOGIN_BUTTON_TAG;
}

- (void)doSignUpSetup {
    self.backgroundColor = UNWINE_ORANGE_COLOR;
    self.titleLabel.text = @"Sign Up";
    self.tag = SIGN_UP_BUTTON_TAG;
}

- (void)doLoginSetup{
    self.backgroundColor = UNWINE_RED;
    self.titleLabel.text = @"Log In";
    self.tag = LOGIN_METHOD_TAG;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s - Hey", __PRETTY_FUNCTION__);
    //self.alpha = .4;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.alpha = 1;
    
    switch (self.tag) {
        case LOGIN_BUTTON_TAG:
            [(MainLogInViewController *)self.parentController showLogin];
            break;
        case FACEBOOK_BUTTON_TAG:
            [(MainLogInViewController *)self.parentController facebookLogin];
            break;
        case SIGN_UP_BUTTON_TAG:
            [(MainLogInViewController *)self.parentController signUp];
            break;
        case LOGIN_METHOD_TAG:
            [(LogInViewController *)self.parentController logIn];
        default:
            break;
    }
    
}

@end
