//
//  LogInViewController.m
//  unWine
//
//  Created by Fabio Gomez on 3/4/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MainLogInViewController.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import "LoginGenericButtonView.h"
#import "customTabBarController.h"
#import "RegistrationTVC.h"
#import "FBSDKLoginManager.h"
#import "FBSDKLoginManagerLoginResult.h"
#import "CastProfileVC.h"
#import "ProfileTVC.h"

#define FACEBOOK_ALERT  0
#define SIGN_UP_ALERT   1
#define PASSWORD_ALERT  2
#define ERROR_ALERT     3
#define GUEST_ALERT     4


@interface MainLogInViewController () <UIAlertViewDelegate, unWineAlertViewDelegate>
@property (strong, nonatomic) UIButton                 *logOutButton;
@property (strong, nonatomic) IBOutlet UIImageView              *logoImageView;
@property (strong, nonatomic) IBOutlet LoginGenericButtonView   *facebookButton;
@property (strong, nonatomic) IBOutlet LoginGenericButtonView   *logInButton;
@property (strong, nonatomic) IBOutlet UIButton                 *forgotPasswordButton;
@property (strong, nonatomic) IBOutlet LoginGenericButtonView   *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *guestButton;

@end

@implementation MainLogInViewController {
    UIView *shadeView;
}

@synthesize logOutButton, logInButton, facebookButton, signUpButton, forgotPasswordButton, logoImageView, guestButton, isGuestLoggingIn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logInButton.parentController    = self;
    self.facebookButton.parentController = self;
    self.signUpButton.parentController   = self;
    self.logoImageView.image = UNWINE_LOGO_IMAGE;
    
    [self.facebookButton    doFacebookSetup];
    [self.logInButton       doRegularSetup];
    [self.signUpButton      doSignUpSetup];
    
    self.forgotPasswordButton.tintColor = [UIColor whiteColor];
    self.guestButton.tintColor = [UIColor whiteColor];
    
    // Background Image
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    backgroundImage.frame = self.view.frame;
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if (IS_IPHONE_4) {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_4.png"];
    } else if (IS_IPHONE_5) {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_5.png"];
    } else {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_6Plus.png"];
    }
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
        
    MAKE_STATUS_BAR_WHITE;
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self addUnWineTitleView];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user = [User currentUser];
    if(user && !user.isAnonymous) {
        [self showShadeView];
    } else if(user && [user isAnonymous] && self.isGuestLoggingIn) {
        [self hideShadeView];
    }
    
    if(self.isGuestLoggingIn) {
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(close)];
        [[self navigationItem] setBackBarButtonItem:back];
        self.navigationItem.leftBarButtonItem = back;
    }
    
    if(self.navigationController)
        [self.navigationController setNavigationBarHidden:!self.isGuestLoggingIn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    User *user = [User currentUser];
    if(user)
        [self showShadeView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)close {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    User *user = [User currentUser];
    //NSLog(@"login page user(anon %@) - %@", [user isAnonymous] ? @"YES" : @"NO", user);
    if(user && [user isAnonymous]) {
        if(!self.isGuestLoggingIn) {
            //LOGGER(@"anonymous(not logging in? isGuestLoggingIn=NO)");
            [self initStuffWithUser:user];
        } else {
            [self hideShadeView];
        }
    } else if (user && !user.acceptedTerms/*user.isNew && [user hasFacebook]*/) {
        // Show registration
        [user updateInstallation];
        [self signUp];
    } else if (user) {
        //LOGGER(@"default user interaction");
        [self initStuffWithUser:user];
    } else
        [self hideShadeView];
}

- (void)initStuffWithUser:(User *)user {
    [GET_APP_DELEGATE initThirdPartyWithUser];
    [user updateInstallation];
    
    if(self.isGuestLoggingIn) {
        CastProfileVC *profile = [[GET_APP_DELEGATE ctbc] getProfileVC];
        [profile setProfileUser:user];
        profile.shouldRefresh = YES;
        [self close];
    } else {
        [self showMainTabBar];
    }
}

- (void)continueAsGuest {
    /*SHOW_HUD;

    
    //[PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        HIDE_HUD;
        if (error) {
            [self createAlertWithTitle:@"Sometimes wine gets the best of us"
                               message:[error localizedDescription]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles: nil];
        } else {
            [User initWithTwitterUser];
        }
    }];
    
    */
    
    SHOW_HUD;
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        HIDE_HUD;
        if (error) {
            [self createAlertWithTitle:@"Sometimes wine gets the best of us"
                               message:[error localizedDescription]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles: nil];
        } else {
            LOGGER(@"Logged in anonymous user");
            
            ANALYTICS_TRACK_EVENT(EVENT_USER_CONTINUED_AS_GUEST);
            
            User *aUser = (User *)user;
            aUser.canonicalName = @"Guest";
            [aUser saveInBackground];
            
            [self initStuffWithUser:aUser];
        }
    }];
}





- (void)showShadeView {
    if(shadeView == nil)
        shadeView = [[UIView alloc] initWithFrame:[GET_APP_DELEGATE window].frame];
    shadeView.backgroundColor = [UIColor blackColor];
    shadeView.userInteractionEnabled = YES;
    [self.view addSubview:shadeView];
    [self.view bringSubviewToFront:shadeView];
}

- (void)hideShadeView {
    if(shadeView)
        [shadeView removeFromSuperview];
    guestButton.alpha = !self.isGuestLoggingIn ? 1 : 0;
}

- (void)createAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(NSString *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alert.title = title;
    alert.delegate = self;
    alert.leftButtonTitle = cancelButtonTitle;
    alert.rightButtonTitle = otherButtonTitles;
    [alert show];
}

#pragma mark - Button Methods

- (IBAction)logOut:(id)sender {
    
    if ([User currentUser]) {
        [User logOut];
        [self createAlertWithTitle:@"Success!"
                           message:@"User was logged out!"
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles: nil];
        
    } else {
        [self createAlertWithTitle:@"Alert!"
                           message:@"User is already logged out!"
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles: nil];
    }
    
}



// Facebook Login Stuff

- (void)facebookLogin {
    User *cUser = [User currentUser];

    if(!cUser) {
        SHOW_HUD;
        [[PFFacebookUtils logInInBackgroundWithReadPermissions:FACEBOOK_PERMISSIONS] continueWithBlock:[self handleFacebookLogin]];
    } else {
        SHOW_HUD;
        
        [[[User deleteAndLogoutGuest] continueWithBlock:^id(BFTask *task) {
            HIDE_HUD;
            if (task.error) {
                LOGGER(@"Error logging out guest user");
                LOGGER(task.error);
            } else {
                LOGGER(@"Logged out and Deleted guest user");
            }
            return [PFFacebookUtils logInInBackgroundWithReadPermissions:FACEBOOK_PERMISSIONS];
        }] continueWithBlock:[self handleFacebookLogin]];
    
    }
}

- (id)handleFacebookLogin {
    id (^resultsBlock)(BFTask<PFUser *> *task) = ^id(BFTask<PFUser *> *task) {
        HIDE_HUD;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            User *user = (User *)task.result;
            NSError *error = task.error;
            
            if(!user) {
                if ([[error userInfo][@"error"] objectForKey:@"type"] && [[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"]) {
                    NSLog(@"The facebook session was invalidated");
                    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
                }
                NSLog(@"fb error - %@", error);
                LOGGER(@"Uh oh. The user cancelled the Facebook login.");
                
                
                [unWineAlertView showAlertViewWithTitle:@"Facebook Error" error:error];
            } else if (user.isNew || !user.acceptedTerms) {
                if(ISVALID(user.sessionToken)) {
                    [[PFUser becomeInBackground:user.sessionToken] continueWithBlock:^id(BFTask<__kindof PFUser *> *task) {
                        if (self.isGuestLoggingIn) {
                            LOGGER(@"User linked facebook to guest, signed up and logged in!");
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self signUp];
                        });
                        return nil;
                    }];
                } else {
                    if (self.isGuestLoggingIn) {
                        LOGGER(@"User linked facebook to guest, signed up and logged in!");
                        // Analytics will be trackedb in RegistrationTVC
                    }
                    
                    [self signUp];
                }
            } else {
                if(ISVALID(user.sessionToken)) {
                    [[PFUser becomeInBackground:user.sessionToken] continueWithBlock:^id(BFTask<__kindof PFUser *> *task) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isGuestLoggingIn) {
                                LOGGER(@"User linked facebook to guest account and logged in!");
                                [Analytics trackGuestLogInFacebook];
                            }
                            
                            [self initStuffWithUser:user];
                        });
                        return nil;
                    }];
                } else {
                    if (self.isGuestLoggingIn) {
                        LOGGER(@"User linked facebook to guest account and logged in!");
                        // Track
                        [Analytics trackGuestLogInFacebook];
                    }
                    
                    [self initStuffWithUser:user];
                }
            }
        });
        
        return nil;
    };
    
    return resultsBlock;
}



// Forgot Password Stuff

- (IBAction)forgotPassword:(id)sender {
    //UIButton *button = (UIButton *)sender;
    NSString *title = NSLocalizedString(@"Reset Password", @"Forgot password request title in PFLogInViewController");
    NSString *message = NSLocalizedString(@"Please enter the email address for your account.",
                                          @"Email request message in PFLogInViewController");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = PASSWORD_ALERT;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Email", @"Email");
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyDone;
    
    [alertView show];
}

- (IBAction)guestMode:(id)sender {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Register now and unlock the fun new way to wine socially! Meet new friends or invite your friends to experience wine entertainment the unWine way. Or continue as a guest and make your decision later, cheers!"];
    alert.title = @"Continue as guest?";
    alert.delegate = self;
    alert.leftButtonTitle = @"Cancel";
    alert.rightButtonTitle = @"Continue";
    alert.tag = GUEST_ALERT;
    [alert show];
}

- (void)rightButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == GUEST_ALERT) {
        [self continueAsGuest];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"OK"] && alertView.tag == PASSWORD_ALERT) {
        [self _requestPasswordResetWithEmail:[alertView textFieldAtIndex:0].text];
    }
}

- (void)_requestPasswordResetWithEmail:(NSString *)email {
    [User requestPasswordResetWithEmail:email forViewController:self];
}


// Segue Stuff

- (void)showLogin {
    self.isRegistering = NO;
    LOGGER(@"Showing Log In View");
    [self performSegueWithIdentifier:@"toLogin" sender:self];
}

- (void)signUp {
    if(!self.isRegistering) {
        self.isRegistering = YES;
        LOGGER(@"Showing Sign Up View");
        [self performSegueWithIdentifier:@"toSignUp" sender:self];
    } else {
        LOGGER(@"Not showing Sign Up View");
    }
}

- (void)showMainTabBar {
    LOGGER(@"Showing Main Tab Bar");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRegistering = NO;
        customTabBarController *tabBar = [[customTabBarController alloc] init];
        [self presentViewController:tabBar animated:YES completion:nil];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSString *segueString = segue.identifier;
    
    if ([segueString isEqualToString:@"toSignUp"]) {
        RegistrationTVC *rtvc = [segue destinationViewController];
        rtvc.mode = SIGN_UP_MODE;
        
        User *user = [User currentUser];
        
        if (self.isGuestLoggingIn && [user hasFacebook]) {
            rtvc.userIsGuestAndUsingFacebook = YES;
        }
    }
    
}

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

@end
