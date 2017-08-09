//
//  unWineActionView.m
//  unWine
//
//  Created by Bryce Boesen on 9/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "unWineAlertLoginView.h"
#import "MainLogInViewController.h"
#import "RegistrationTVC.h"
#import "LoginVC.h"

@implementation unWineAlertLoginView {
    UIViewController *_controller;
}

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)showFromViewController:(UIViewController *)controller {
    if(!controller) {
        LOGGER(@"internal fail whale");
        return;
    }
    
    _controller = controller;
    while(_controller.presentedViewController)
        _controller = _controller.presentedViewController;
    NSLog(@"_controller %@", _controller);
    
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:self.message];
    alert.delegate = self;
    alert.theme = unWineAlertThemeGray;
    alert.emptySpaceDismisses = YES;
    alert.centerButtonTitle = @"Sign Up";
    [alert shouldShowLogo:YES];
    [alert shouldShowOrLabel:YES];
    [alert show];
}

- (void)centerButtonPressed {
    /*UIStoryboard *main = [UIStoryboard storyboardWithName:@"MainNew" bundle:nil];
    _loginNav = [main instantiateInitialViewController];
    
    MainLogInViewController *login = (MainLogInViewController *)[[_loginNav viewControllers] objectAtIndex:0];
    login.isGuestLoggingIn = YES;
    
    [_ctbc presentViewController:_loginNav animated:YES completion:nil];*/
    
    //[unWineAlertView showAlertViewWithTitle:@"Beta" message:@"Pending Update" cancelButtonTitle:@"Ok"];
    
    LoginVC<StateControl> *login = [[LoginVC alloc] init];
    login.isGuestLoggingIn = YES;
    if(_controller.tabBarController && _controller.tabBarController.view.window)
        [_controller.tabBarController presentViewController:login animated:YES completion:nil];
    else
        [_controller.navigationController presentViewController:login animated:YES completion:nil];
}

/*- (void)leftButtonPressed {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"MainNew" bundle:nil];
    
    RegistrationTVC *rtvc = [main instantiateViewControllerWithIdentifier:@"registration"];
    rtvc.mode = SIGN_UP_MODE;
    
    _signupNav = [[UINavigationController alloc] initWithRootViewController:rtvc];
    [_ctbc presentViewController:_signupNav animated:YES completion:nil];
}*/

@end
