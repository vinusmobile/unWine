//
//  LoginController4.m
//  ADVFlatUI
//
//  Created by Tope on 30/05/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "LoginController.h"
#import "UIImage-JTColor.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

UIColor* mainColor;
UIColor* darkColor;
NSString* fontName;
NSString* boldFontName;
float screenOffset; // This is used to manipulate the view's layout based on the device's screen size


@interface LoginController ()
@end

@implementation LoginController



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    if (IS_IPHONE_4) {
        screenOffset = 100;
    }
    else{
        screenOffset = 0;
    }
    
    
    mainColor = [UIColor colorWithRed:249.0/255 green:223.0/255 blue:244.0/255 alpha:1.0f];
    darkColor = [UIColor colorWithRed:62.0/255 green:28.0/255 blue:55.0/255 alpha:1.0f];
    fontName = @"Avenir-Book";
    boldFontName = @"Avenir-Black";
    
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];//mainColor;
    
    // Going to have to create and add the rest of stuff programmatically
    
    // Cont View is the top view with the image and the label
    
    // contView
    //  - headerImageView
    //  - overlayView
    //      - titleLabel
    
    UIView *contView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 165 - screenOffset)];
    
    // This view has the wine-cork image
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 165 - screenOffset)];
    headerImageView.image = [UIImage imageNamed:@"wine-cork.jpg"];
    //[headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    // This view goes over the headerImageView to display the "unWine" titleLabel
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 165 - screenOffset)];
    overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 234) / 2, 97 - screenOffset, 234, 60)];
    titleLabel.textColor =  [UIColor whiteColor];
    titleLabel.font =  [UIFont fontWithName:boldFontName size:24.0f];
    titleLabel.text = @"unWine";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [overlayView addSubview:titleLabel];
    
    [contView addSubview:headerImageView];
    [contView addSubview:overlayView];
    
    
    // Info View
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 165 - screenOffset, SCREEN_WIDTH, 55)];
    infoView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 234) / 2, 20, 234, 21)];
    infoLabel.textColor =  [UIColor darkGrayColor];
    infoLabel.font =  [UIFont fontWithName:boldFontName size:14.0f];
    infoLabel.text = @"Welcome back, please login below";
    
    [infoView addSubview:infoLabel];
    
    [self.logInView addSubview:infoView];
    [self.logInView addSubview:contView];
    
    
    /*
    NSLog(@"facebook Button Frame");
    NSLog(@"x = %f, y = %f, width = %f, height = %f", self.logInView.facebookButton.frame.origin.x, self.logInView.facebookButton.frame.origin.y, self.logInView.facebookButton.frame.size.width, self.logInView.facebookButton.frame.size.height);
    */
    /*
    self.titleLabel.textColor =  [UIColor whiteColor];
    self.titleLabel.font =  [UIFont fontWithName:boldFontName size:24.0f];
    self.titleLabel.text = @"GOOD TO SEE YOU";
    */
    /*
    self.infoLabel.textColor =  [UIColor darkGrayColor];
    self.infoLabel.font =  [UIFont fontWithName:boldFontName size:14.0f];
    self.infoLabel.text = @"Welcome back, please login below";
    
    self.infoView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    */
    //self.headerImageView.image = [UIImage imageNamed:@"running.jpg"];
    //self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    
    
    
    
     
}

// Parse Stuff

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Some Frames change based on the size of the screen of the device
    printf("\n\n");
    NSLog(@"viewDidLayoutSubviews\n\n");
    
    CGFloat change = 0;
    
    // Username
    [self.logInView.usernameField setFrame:CGRectMake(0.0f + change/2, 220.0f - screenOffset, SCREEN_WIDTH - change, 41.0f)];
    self.logInView.usernameField.backgroundColor = [UIColor whiteColor];
    self.logInView.usernameField.placeholder = @"Username";
    self.logInView.usernameField.font = [UIFont fontWithName:fontName size:16.0f];
    self.logInView.usernameField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.logInView.usernameField.layer.borderWidth = 1.0f;
    self.logInView.usernameField.textAlignment = NSTextAlignmentLeft;
    self.logInView.usernameField.textColor = [UIColor grayColor];
    
    //self.logInView.usernameField.leftView = leftView;
    
    // Password
    [self.logInView.passwordField setFrame:CGRectMake(0.0f + change/2, 260.0f - screenOffset, SCREEN_WIDTH - change, 41.0f)];//(0.0f, 260.0f - screenOffset, 320.0f, 41.0f)];
    self.logInView.passwordField.backgroundColor = [UIColor whiteColor];
    self.logInView.passwordField.placeholder = @"Password";
    self.logInView.passwordField.font = [UIFont fontWithName:fontName size:16.0f];
    self.logInView.passwordField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.logInView.passwordField.layer.borderWidth = 1.0f;
    self.logInView.passwordField.textAlignment = NSTextAlignmentLeft;
    self.logInView.passwordField.textColor = [UIColor grayColor];
    
    
    //UIView* leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 41, 20)];
    //self.logInView.passwordField.leftViewMode = UITextFieldViewModeAlways;
    //self.logInView.passwordField.leftView = leftView2;
    
    // Login Button
    //self.logInView.logInButton.hidden = YES;
    [self.logInView.logInButton setFrame:CGRectMake(0.0f/*161.0f*/, 301.0f - screenOffset, SCREEN_WIDTH, 62.0f)];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.logInView.logInButton.backgroundColor = [UIColor colorWithRed:129.0/255 green:2.0/255 blue:32.0/255 alpha:1.0]; //darkcolor;
    self.logInView.logInButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"LOG IN" forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.logInButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    
    
    
    
    // Sign Up Button
    [self.logInView.signUpButton setFrame:CGRectMake(0.0f, 464.0f/*400.0f*/ - screenOffset, SCREEN_WIDTH, 62.0f)]; //0.0f, 464.0f/*400.0f*/ - screenOffset, 320.0f, 62.0f
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.logInView.signUpButton.backgroundColor = [UIColor colorWithRed:129.0/255 green:2.0/255 blue:32.0/255 alpha:1.0]; //darkcolor;
    self.logInView.signUpButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.logInView.signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
   
   
    // External Login Label (Facebook)
    //self.logInView.externalLogInLabel.text = @"OR";//@"You can also log in or sign up with:";
    //[self.logInView.externalLogInLabel setFrame:CGRectMake(37.0f, 438.0f/*374.0f*/ - screenOffset, 245.0f, 15.0f)];
    
    // Facebook Button
    [self.logInView.facebookButton setFrame:CGRectMake(0.0f, 365.0f/*301.0f*/ - screenOffset, SCREEN_WIDTH, 62.0f)]; //0.0f, 365.0f/*301.0f*/ - screenOffset, 320.0f, 62.0f
    
    
    //self.logInView.passwordForgottenButton.hidden = YES;
    [self setUpPasswordForgottenButton];
    
    self.logInView.dismissButton.hidden = YES;
    self.logInView.logo.hidden = YES;
    
}

- (void)setUpPasswordForgottenButton{
    //[self.logInView.passwordForgottenButton setFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)];
    NSLog(@"self.logInView.passwordForgottenButton frame");
    NSLog(@"x       = %f", self.logInView.passwordForgottenButton.frame.origin.x);
    NSLog(@"y       = %f", self.logInView.passwordForgottenButton.frame.origin.y);
    NSLog(@"width   = %f", self.logInView.passwordForgottenButton.frame.size.width);
    NSLog(@"height  = %f", self.logInView.passwordForgottenButton.frame.size.height);
    
    printf("\n\n");
    
    NSLog(@"title label = %@", self.logInView.passwordForgottenButton);
    
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(0.0f, 536.0f - screenOffset, SCREEN_WIDTH, 20.0f)];
    
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.logInView.passwordForgottenButton.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:129.0/255 green:2.0/255 blue:32.0/255 alpha:1.0]; //darkcolor;
    self.logInView.passwordForgottenButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.logInView.passwordForgottenButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor colorWithRed:129.0/255 green:2.0/255 blue:32.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor colorWithRed:0.872 green:0.010 blue:0.216 alpha:1.000] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
