//
//  LogInViewController.h
//  unWine
//
//  Created by Fabio Gomez on 3/4/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MainLogInViewController : UIViewController

@property (nonatomic) BOOL isGuestLoggingIn;
@property (nonatomic) BOOL isRegistering;
@property (nonatomic) BOOL selfDestruct;

- (void)showLogin;
- (void)facebookLogin;
- (void)signUp;
- (IBAction)forgotPassword:(id)sender;
@end
