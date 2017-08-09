//
//  LoginVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/27/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "ParseSubclasses.h"
#import "MainVC.h"

typedef enum LoginState {
    LoginStateLogin,
    LoginStateChecking,
    LoginStateRegister
} LoginState;

@class MainVC;
@interface LoginVC : UIViewController <StateControl, unWineAlertViewDelegate>

@property (nonatomic) LoginState state;
@property (nonatomic) BOOL isGuestLoggingIn;

@end
