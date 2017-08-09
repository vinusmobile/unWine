//
//  LoginVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/27/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "LoginVC.h"
#import "MainVC.h"
#import "CastProfileVC.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseTwitterUtils/PF_Twitter.h>
#import <TwitterKit/TwitterKit.h>
#import <Branch/Branch.h>
#import "ThemeHandler.h"

#define FACEBOOK_BLUE [UIColor colorWithRed:59/255.f green:89/255.f blue:152/255.f alpha:1]
#define TWITTER_BLUE [UIColor colorWithRed:0/255.f green:172/255.f blue:237/255.f alpha:1]

#define GUEST_ALERT 1
#define PASSWORD_ALERT 2

#define EMAIL_FIELD_TAG 2
#define PASSWORD_FIELD_TAG 3
#define FIRST_NAME_FIELD_TAG 4
#define LAST_NAME_FIELD_TAG 5

@interface LoginVC () <UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation LoginVC {
    NSArray<UIView *> *viewOrder;
    
    UIView *loginView;
    UIButton *cancelLogin;
    UIButton *guestLogin;
    
    UIView *checkingView;
    UITextField *emailField;
    UITextField *passwordField;
    UIButton *checkingNext;
    
    UIView *registerView;
    UITextField *firstNameField;
    UITextField *lastNameField;
    UIButton *registerConfirm;
    
    BOOL loginDidChange;
    UITextField *lastEdited;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackgroundView];
    
    loginView = [self prepareLoginView];
    loginView.alpha = 1;
    [self.view addSubview:loginView];
    
    checkingView = [self prepareCheckingView];
    checkingView.alpha = 0;
    [self.view addSubview:checkingView];
    
    registerView = [self prepareRegisterView];
    registerView.alpha = 0;
    [self.view addSubview:registerView];
    
    viewOrder = @[loginView, checkingView, registerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[[MainVC sharedInstance] checkPresentView];
    
    if(guestLogin)
        guestLogin.alpha = self.isGuestLoggingIn ? 0 : 1;
    
    if(cancelLogin)
        cancelLogin.alpha = self.isGuestLoggingIn ? 1 : 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)addBackgroundView {
    UIImageView *backgroundImage = [[UIImageView alloc] init];
    backgroundImage.frame = self.view.frame;
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if (IS_IPHONE_4) {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_4.png"];
    } else if (IS_IPHONE_5) {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_5.png"];
    } else {
        backgroundImage.image = [UIImage imageNamed:@"loginBackground_6+.png"];
    }
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}

#pragma Keyboard

- (void)keyboardDidHide:(NSNotification *)notifcation {
    if((lastEdited == emailField || lastEdited == passwordField) && self.state == LoginStateChecking) {
        BOOL emailValid = [self isValidEmail:emailField.text] && ![emailField.text isEqualToString:@""];
        BOOL passValid = [self isValidPassword:passwordField.text] && ![passwordField.text isEqualToString:@""];
        if(!emailValid && (lastEdited == emailField || (lastEdited == passwordField && passValid)))
            [unWineAlertView showDisposableAlertView:@"Invalid email address" theme:unWineAlertThemeRed];
        else if(!passValid && (lastEdited == passwordField || (lastEdited == emailField && emailValid)))
            [unWineAlertView showDisposableAlertView:@"Password must be at least 6 characters" theme:unWineAlertThemeRed];
    }
}

#pragma Logging In

- (UIView *)prepareLoginView {
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    
    cancelLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelLogin setFrame:(CGRect){8, 22, {64, 32}}];
    [cancelLogin.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [cancelLogin setTitle:@"Close" forState:UIControlStateNormal];
    [cancelLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelLogin addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    cancelLogin.alpha = self.isGuestLoggingIn ? 1 : 0;
    [view addSubview:cancelLogin];
    
    CGFloat w = WIDTH(view);
    CGFloat h = HEIGHT(view);
    //NSInteger dim = w * 7 / 8.f;
    NSInteger bufferX = 45;
    NSInteger buttonHeight = 48;
    NSInteger buttonWidth = SCREEN_WIDTH - 30;
    NSInteger buttonBuffer = 15;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, bufferX, {w, h / 3}}];
    [imageView setImage:[UIImage imageNamed:@"unWineLogo"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [view addSubview:imageView];
    
    UIButton *facebookLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    facebookLogin.tag = 1;
    [facebookLogin setFrame:(CGRect){(w - buttonWidth) / 2, Y2(imageView) + HEIGHT(imageView) + bufferX, {buttonWidth, buttonHeight}}];
    [facebookLogin setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [facebookLogin setBackgroundColor:FACEBOOK_BLUE];
    [facebookLogin addTarget:self action:@selector(facebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [self formatButton:facebookLogin withImage:[UIImage imageNamed:@"fbButtonIcon"]];
    [view addSubview:facebookLogin];
    
    UIButton *twitterLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    //TWTRLogInButton *twitterLogin = [TWTRLogInButton buttonWithLogInCompletion:[self handleTwitterLogin]];
    twitterLogin.tag = 2;
    [twitterLogin setFrame:(CGRect){(w - buttonWidth) / 2, Y2(facebookLogin) + HEIGHT(facebookLogin) + buttonBuffer, {buttonWidth, buttonHeight}}];
    [twitterLogin setTitle:@"Log in with Twitter" forState:UIControlStateNormal];
    [twitterLogin setBackgroundColor:TWITTER_BLUE];
    [twitterLogin addTarget:self action:@selector(twitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [self formatButton:twitterLogin withImage:[UIImage imageNamed:@"twButtonIcon"]];
    [view addSubview:twitterLogin];

    
    UIButton *unwineLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    unwineLogin.tag = 3;
    [unwineLogin setFrame:(CGRect){(w - buttonWidth) / 2, Y2(twitterLogin) + HEIGHT(twitterLogin) + buttonBuffer, {buttonWidth, buttonHeight}}];
    [unwineLogin setTitle:@"Log in" forState:UIControlStateNormal];
    [unwineLogin setBackgroundColor:UNWINE_RED];
    [unwineLogin addTarget:self action:@selector(unwineLogin) forControlEvents:UIControlEventTouchUpInside];
    [self formatButton:unwineLogin withImage:[UIImage imageNamed:@"loginButtonIcon"]];
    [view addSubview:unwineLogin];
    
    guestLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    guestLogin.tag = 4;
    [guestLogin setFrame:(CGRect){0, h - 52, {w, 52}}];
    [guestLogin.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [guestLogin setTitle:@"Continue as Guest" forState:UIControlStateNormal];
    [guestLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [guestLogin addTarget:self action:@selector(guestLogin) forControlEvents:UIControlEventTouchUpInside];
    guestLogin.alpha = self.isGuestLoggingIn ? 0 : 1;
    [view addSubview:guestLogin];
    
    return view;
}

- (void)facebookLogin {
    SHOW_HUD;
    [[User facebookLogin] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        HIDE_HUD;
        
        if(task.error) {
            LOGGER(task.error.localizedDescription);
            [unWineAlertView showAlertViewWithTitle:@"Facebook Error" error:task.error];
            return nil;
            
        }
        
        if (self.isGuestLoggingIn) {
            LOGGER(@"User linked Facebook to guest account and logged in!");
            [Analytics trackGuestLogInFacebook];
        }
        
        User *user = (User *)task.result;
        [self setUpUserAndDismiss:user];
        
        if (user.isNew) {
            LOGGER(@"Successfully Signed Up with Facebook");
            ANALYTICS_TRACK_EVENT(EVENT_USER_SIGNED_UP_WITH_FACEBOOK);
        } else {
            LOGGER(@"Successfully Logged in with Facebook");
        }
        
        return nil;
    }];
}

- (void)twitterLogin {
    SHOW_HUD;
    [[User twitterLogin] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        HIDE_HUD;
        
        if(task.error) {
            LOGGER(task.error.localizedDescription);
            [unWineAlertView showAlertViewWithTitle:@"Twitter Error" error:task.error];
            
            return nil;
        }
        
        if (self.isGuestLoggingIn) {
            LOGGER(@"User linked twitter to guest account and logged in!");
            [Analytics trackGuestLogInTwitter];
        }
        
        User *user = (User *)task.result;
        [self setUpUserAndDismiss:user];
        
        if (user.isNew) {
            LOGGER(@"Successfully Signed Up with Twitter");
            ANALYTICS_TRACK_EVENT(EVENT_USER_SIGNED_UP_WITH_TWITTER);
        } else {
            LOGGER(@"Successfully Logged in with Twiter");
        }
        
        return nil;
    }];
}

- (void)setUpUserAndDismiss:(User *)user {
    LOGGER(@"Doing all init stuff after user login/registration");
    [GET_APP_DELEGATE initThirdPartyWithUser];
    
    if([GET_APP_DELEGATE ctbc]) {
        CastProfileVC *profile = [[GET_APP_DELEGATE ctbc] getProfileVC];
        [profile setProfileUser:user];
        profile.shouldRefresh = YES;
    }
    
    [[MainVC sharedInstance] dismissPresented:YES];
}

- (void)formatButton:(UIButton *)button withImage:(UIImage *)image {
    NSInteger dim = 48;
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    //[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    //button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.layer.cornerRadius = 4;
    button.layer.shadowColor = [[UIColor blackColor] CGColor];
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowRadius = 1.7;
    button.layer.shadowOpacity = 1;
    button.clipsToBounds = YES;
    
    CGRect tagRect = CGRectZero;
    switch(button.tag) {
        case 1:
            tagRect = (CGRect){6, 6, {dim - 12, dim - 12}};
            break;
        case 2:
            tagRect = (CGRect){0, 0, {dim, dim}};
            break;
        case 3:
            tagRect = (CGRect){8, 8, {dim - 16, dim - 16}};
            break;
    }
    //LOGGER(@"%li: %@", button.tag, NSStringFromCGRect(tagRect));
    
    UIImageView *buttonImage = [[UIImageView alloc] initWithFrame:tagRect];
    [buttonImage setImage:image];
    [buttonImage setContentMode:UIViewContentModeScaleAspectFit];
    [buttonImage setClipsToBounds:YES];
    [button addSubview:buttonImage];
}





- (void)unwineLogin {
    //present registration
    [self transitionToState:LoginStateChecking];
}

- (void)guestLogin {
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

- (void)continueAsGuest {
    SHOW_HUD;
    [[User continueAsGuest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD;
        if (t.error) {
            LOGGER(t.error.localizedDescription);
            [unWineAlertView showAlertViewWithTitle:@"Guest Login Error" error:t.error];
            return nil;
        }
        ANALYTICS_TRACK_EVENT(EVENT_USER_CONTINUED_AS_GUEST);
        
        User *user = (User *)t.result;
        [self setUpUserAndDismiss:user];
        return nil;
    }];
}



#pragma Checking

- (UIView *)prepareCheckingView {
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    unWineTheme theme = unWineThemeLight;
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancel setFrame:(CGRect){8, 22, {64, 32}}];
    [cancel.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancel];
    
    checkingNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkingNext setFrame:(CGRect){SCREEN_WIDTH - 64 - 8, 22, {64, 32}}];
    [checkingNext setTitle:@"Next" forState:UIControlStateNormal];
    [checkingNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkingNext addTarget:self action:@selector(attemptLogin) forControlEvents:UIControlEventTouchUpInside];
    [checkingNext.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    checkingNext.alpha = 0;
    [view addSubview:checkingNext];
    
    CGFloat w = WIDTH(view);
    //CGFloat h = HEIGHT(view);
    NSInteger bufferY = SCREENHEIGHT / 6;
    //NSInteger buttonBuffer = 15;
    
    NSInteger cBufferX = 14;
    NSInteger cBufferY = 10;
    NSInteger labelHeight = 20;
    NSInteger fieldHeight = 42;
    NSInteger width = SCREEN_WIDTH - 30;
    NSInteger height = (labelHeight + fieldHeight + cBufferY * 3) * 2;
    
    UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){(w - width) / 2, bufferY, {width, height}}];
    [containerView setBackgroundColor:UNWINE_RED]; //[ThemeHandler getBackgroundColor:theme]
    containerView.layer.cornerRadius = 4;
    containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    containerView.layer.shadowOffset = CGSizeMake(0, 0);
    containerView.layer.shadowRadius = 1.7;
    containerView.layer.shadowOpacity = 1;
    containerView.clipsToBounds = YES;
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:(CGRect){cBufferX, cBufferY, {width - cBufferX * 2, labelHeight}}];
    [emailLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [emailLabel setText:@"Email"];
    [emailLabel setTextAlignment:NSTextAlignmentCenter];
    [emailLabel setTextColor:[UIColor whiteColor]]; //[ThemeHandler getForegroundColor:theme]
    [containerView addSubview:emailLabel];
    
    emailField = [[UITextField alloc] initWithFrame:(CGRect){cBufferX, Y2(emailLabel) + HEIGHT(emailLabel) + cBufferY, {width - cBufferX * 2, fieldHeight}}];
    [emailField setBackgroundColor:[ThemeHandler getCellPrimaryColor:theme]];
    [emailField setTextColor:[ThemeHandler getForegroundColor:theme]];
    [emailField setTintColor:UNWINE_RED];
    [emailField setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    emailField.layer.cornerRadius = 4;
    emailField.layer.borderWidth = .5f;
    emailField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
    emailField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0);
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.delegate = self;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.tag = EMAIL_FIELD_TAG;
    [containerView addSubview:emailField];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:(CGRect){cBufferX, Y2(emailField) + HEIGHT(emailField) + cBufferY, {width - cBufferX * 2, labelHeight}}];
    [passwordLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [passwordLabel setText:@"Password"];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setTextColor:[UIColor whiteColor]]; //[ThemeHandler getForegroundColor:theme]
    [containerView addSubview:passwordLabel];
    
    passwordField = [[UITextField alloc] initWithFrame:(CGRect){cBufferX, Y2(passwordLabel) + HEIGHT(passwordLabel) + cBufferY, {width - cBufferX * 2, fieldHeight}}];
    [passwordField setBackgroundColor:[ThemeHandler getCellPrimaryColor:theme]];
    [passwordField setTextColor:[ThemeHandler getForegroundColor:theme]];
    [passwordField setTintColor:UNWINE_RED];
    [passwordField setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    passwordField.layer.cornerRadius = 4;
    passwordField.layer.borderWidth = .5f;
    passwordField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
    passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0);
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.delegate = self;
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.tag = PASSWORD_FIELD_TAG;
    passwordField.secureTextEntry = YES;
    [containerView addSubview:passwordField];
    
    [view addSubview:containerView];
    
    UIButton *forgotButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [forgotButton setFrame:(CGRect){(w - width) / 2, Y2(containerView) + HEIGHT(containerView) + cBufferY, {width, 32}}];
    [forgotButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [forgotButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [forgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:forgotButton];
    
    return view;
}

- (void)forgotPassword {
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
    alertView.tintColor = UNWINE_RED;
    alertView.tag = PASSWORD_ALERT;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"Email", @"Email");
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyDone;
    textField.text = emailField.text;
    
    [alertView show];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    if(textField.tag == EMAIL_FIELD_TAG || textField.tag == PASSWORD_FIELD_TAG)
        loginDidChange = YES;
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    lastEdited = textField;
    if(textField.tag == EMAIL_FIELD_TAG || textField.tag == PASSWORD_FIELD_TAG) {
        if(!loginDidChange)
            return;
        
        loginDidChange = NO;
        
        [self attemptLogin];

    } else { //Name fields
        BOOL first = [self isValidFirstName:firstNameField.text];
        BOOL last = [self isValidLastName:lastNameField.text];
        
        registerConfirm.alpha = first && last ? 1 : 0;
        
        [self attemptRegister];
    }
}

- (void)attemptLogin {
    BOOL emailValid = [self isValidEmail:emailField.text];
    //BOOL userValid = [self isValidUsername:emailField.text];
    BOOL passValid = [self isValidPassword:passwordField.text];

    if (emailValid == false) {
        [unWineAlertView showDisposableAlertView:@"Please enter a valid email" theme:unWineAlertThemeRed];
        return;
    }
    
    if (passValid == false) {
        [unWineAlertView showDisposableAlertView:@"Please enter a password that it's at least 6 characters." theme:unWineAlertThemeRed];
        return;
    }
    
    checkingNext.alpha = 1;
    PFQuery *query1 = [User query];
    [query1 whereKey:@"username" equalTo:emailField.text];
    
    PFQuery *query2 = [User query];
    [query2 whereKey:@"email" equalTo:emailField.text];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];

    SHOW_HUD;
    __block User *user = nil;
    
    [[[[query getFirstObjectInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        user = (User *)task.result;
        NSString *s = [NSString stringWithFormat:@"Found user with username \"%@\" and email \"%@\"",
                       user.username, user.email];
        LOGGER(s);
        
        return [PFCloud callFunctionInBackground:@"isLinkedWithSocialMedia" withParameters:@{@"userId": user.objectId}];
    
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSString *s = [NSString stringWithFormat:@"Came back from isLinkedWithSocialMedia"];
        LOGGER(s);
        return [User logInWithUsernameInBackground:user.username password:passwordField.text];
    
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD;
        NSString *s = [NSString stringWithFormat:@"Came back from login in"];
        LOGGER(s);
        
        if (t.error == nil) {
            LOGGER(@"Success");
            User *theUser = (User *)t.result;
            [self setUpUserAndDismiss:theUser];
            
        } else if (t.error.code == kPFErrorObjectNotFound && user != nil) {
            s = [NSString stringWithFormat:@"Some other error: %@", t.error];
            LOGGER(s);
            [unWineAlertView showDisposableAlertView:@"Oops. Wrong password!" theme:unWineAlertThemeRed];
            
        } else if (user == nil) {
            LOGGER(@"User not found. Moving on to register");
            [self transitionToState:LoginStateRegister];
        }
        
        return nil;
    }];
    
}

- (BOOL)isValidUsername:(NSString *)checkString {
    return checkString.length > 2 && checkString.length < 16 && ![checkString containsString:@"@"];;
}

- (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString] && checkString.length < 80 && checkString.length > 0;
}

- (BOOL)isValidPassword:(NSString *)checkString {
    return checkString.length > 5 && checkString.length <= 25;
}

#pragma Registering

- (UIView *)prepareRegisterView {
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    unWineTheme theme = unWineThemeLight;
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancel setFrame:(CGRect){8, 22, {64, 32}}];
    [cancel setTitle:@"Back" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [cancel.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [view addSubview:cancel];
    
    registerConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [registerConfirm setFrame:(CGRect){SCREEN_WIDTH - 92 - 8, 22, {92, 32}}];
    [registerConfirm setTitle:@"Sign Up" forState:UIControlStateNormal];
    [registerConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerConfirm addTarget:self action:@selector(attemptRegister) forControlEvents:UIControlEventTouchUpInside];
    [registerConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    registerConfirm.alpha = 0;
    [view addSubview:registerConfirm];
    
    CGFloat w = WIDTH(view);
    //CGFloat h = HEIGHT(view);
    NSInteger bufferY = SCREENHEIGHT / 6;
    //NSInteger buttonBuffer = 15;
    
    NSInteger cBufferX = 14;
    NSInteger cBufferY = 10;
    NSInteger labelHeight = 20;
    NSInteger fieldHeight = 42;
    NSInteger width = SCREEN_WIDTH - 30;
    NSInteger height = (labelHeight + fieldHeight + cBufferY * 3) * 2;
    
    UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){(w - width) / 2, bufferY, {width, height}}];
    [containerView setBackgroundColor:UNWINE_RED]; //[ThemeHandler getBackgroundColor:theme]
    containerView.layer.cornerRadius = 4;
    containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    containerView.layer.shadowOffset = CGSizeMake(0, 0);
    containerView.layer.shadowRadius = 1.7;
    containerView.layer.shadowOpacity = 1;
    containerView.clipsToBounds = YES;
    
    UILabel *firstNameLabel = [[UILabel alloc] initWithFrame:(CGRect){cBufferX, cBufferY, {width - cBufferX * 2, labelHeight}}];
    [firstNameLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [firstNameLabel setText:@"First Name"];
    [firstNameLabel setTextAlignment:NSTextAlignmentCenter];
    [firstNameLabel setTextColor:[UIColor whiteColor]]; //[ThemeHandler getForegroundColor:theme]
    [containerView addSubview:firstNameLabel];
    
    firstNameField = [[UITextField alloc] initWithFrame:(CGRect){cBufferX, Y2(firstNameLabel) + HEIGHT(firstNameLabel) + cBufferY, {width - cBufferX * 2, fieldHeight}}];
    [firstNameField setBackgroundColor:[ThemeHandler getCellPrimaryColor:theme]];
    [firstNameField setTextColor:[ThemeHandler getForegroundColor:theme]];
    [firstNameField setTintColor:UNWINE_RED];
    [firstNameField setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    firstNameField.layer.cornerRadius = 4;
    firstNameField.layer.borderWidth = .5f;
    firstNameField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
    firstNameField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0);
    firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    firstNameField.keyboardType = UIKeyboardTypeEmailAddress;
    firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstNameField.delegate = self;
    firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    firstNameField.tag = FIRST_NAME_FIELD_TAG;
    [containerView addSubview:firstNameField];
    
    UILabel *lastNameLabel = [[UILabel alloc] initWithFrame:(CGRect){cBufferX, Y2(firstNameField) + HEIGHT(firstNameField) + cBufferY, {width - cBufferX * 2, labelHeight}}];
    [lastNameLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [lastNameLabel setText:@"Last Name"];
    [lastNameLabel setTextAlignment:NSTextAlignmentCenter];
    [lastNameLabel setTextColor:[UIColor whiteColor]]; //[ThemeHandler getForegroundColor:theme]
    [containerView addSubview:lastNameLabel];
    
    lastNameField = [[UITextField alloc] initWithFrame:(CGRect){cBufferX, Y2(lastNameLabel) + HEIGHT(lastNameLabel) + cBufferY, {width - cBufferX * 2, fieldHeight}}];
    [lastNameField setBackgroundColor:[ThemeHandler getCellPrimaryColor:theme]];
    [lastNameField setTextColor:[ThemeHandler getForegroundColor:theme]];
    [lastNameField setTintColor:UNWINE_RED];
    [lastNameField setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    lastNameField.layer.cornerRadius = 4;
    lastNameField.layer.borderWidth = .5f;
    lastNameField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
    lastNameField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0);
    lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    lastNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    lastNameField.keyboardType = UIKeyboardTypeDefault;
    lastNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    lastNameField.delegate = self;
    lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    lastNameField.tag = LAST_NAME_FIELD_TAG;
    [containerView addSubview:lastNameField];
    
    [view addSubview:containerView];
    
    return view;
}

- (void)attemptRegister {
    
    if ([self isValidEmail:emailField.text] == false) {
        [unWineAlertView showDisposableAlertView:@"Please enter a valid email" theme:unWineAlertThemeRed];
        return;
    }
    
    if ([self isValidFirstName:firstNameField.text] == false) {
        [unWineAlertView showDisposableAlertView:@"Please enter your first name" theme:unWineAlertThemeRed];
        return;
    }
    
    if ([self isValidLastName:lastNameField.text] == false) {
        [unWineAlertView showDisposableAlertView:@"Please enter your last name" theme:unWineAlertThemeRed];
        return;
    }
    
    MBProgressHUD *hud = SHOW_HUD;
    hud.label.text = @"Signing Up";
    
    __block User *user = [User user];
    user.username = emailField.text;
    user.password = passwordField.text;
    user.email = emailField.text;
    user.canonicalName = [NSString stringWithFormat:@"%@ %@", firstNameField.text, lastNameField.text];
    
    [[user initializeAndThenSignUp] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        HIDE_HUD;
        
        if(task.error) {
            LOGGER(task.error);
            [unWineAlertView showAlertViewWithTitle:nil error:task.error];
            return nil;
        }
        
        [self setUpUserAndDismiss:user];
        
        LOGGER(@"Signed Up with Email");
        ANALYTICS_TRACK_EVENT(EVENT_USER_SIGNED_UP_WITH_EMAIL);
        
        return nil;
    }];
}

- (BOOL)isValidFirstName:(NSString *)checkString {
    return checkString.length > 0 && checkString.length < 25;
}

- (BOOL)isValidLastName:(NSString *)checkString {
    return checkString.length > 0 && checkString.length < 25;
}

#pragma Other Stuff

- (void)dismissViewController:(UIButton *)sender {
    loginDidChange = NO;
    
    if(self.isGuestLoggingIn && sender == cancelLogin)
        [self dismissViewControllerAnimated:YES completion:nil];
    else {
        [self resetTextfields];
        [self transitionToState:self.state - 1];
    }
}

- (void)resetTextfields {
    if(self.state == LoginStateChecking) {
        checkingNext.alpha = 0;
        emailField.text = @"";
        passwordField.text = @"";
        
        [emailField resignFirstResponder];
        [passwordField resignFirstResponder];
    } else if(self.state == LoginStateRegister) {
        checkingNext.alpha = 1;
        registerConfirm.alpha = 0;
        firstNameField.text = @"";
        lastNameField.text = @"";
        
        [firstNameField resignFirstResponder];
        [lastNameField resignFirstResponder];
    }
}

#pragma Transition Handling

- (UIView *)getCurrentView:(LoginState)state {
    return [viewOrder objectAtIndex:state];
}

/*- (UIView *)getPrevView:(LoginState)state {
    if(state > 0)
        return [viewOrder objectAtIndex:state - 1];
    else
        return nil;
}

- (UIView *)getNextView:(LoginState)state {
    if(state < [viewOrder count] - 1)
        return [viewOrder objectAtIndex:state + 1];
    else
        return nil;
}*/

- (void)transitionToState:(LoginState)state {
    if(state == self.state)
        return;
    
    BOOL slidesLeft = state > self.state;
    UIView *toView = [self getCurrentView:state];
    UIView *fromView = [self getCurrentView:self.state];
    if(toView == nil || fromView == nil)
        return;
    
    self.state = state;
    
    CGRect mainFrame = self.view.frame;
    CGRect offFrame = self.view.frame;
    CGRect startFrame = self.view.frame;
    if(slidesLeft) {
        offFrame.origin.x = -WIDTH(self.view) + 1;
        startFrame.origin.x = WIDTH(self.view) - 1;
    } else {
        offFrame.origin.x = WIDTH(self.view) - 1;
        startFrame.origin.x = -WIDTH(self.view) + 1;;
    }
    [toView setFrame:startFrame];
    toView.alpha = 1;
    fromView.alpha = 1;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^(void) {
         [toView setFrame:mainFrame];
         [fromView setFrame:offFrame];
     } completion:^(BOOL finished) {
         if(state == LoginStateRegister)
             [firstNameField becomeFirstResponder];
         else if(state == LoginStateChecking)
             [emailField becomeFirstResponder];
         else
             [self resignFirstResponder];
     }];
}

/*- (void)flashBorder:(UITextField *)textField count:(NSInteger)count {
    unWineTheme theme = unWineThemeDark;
    if(count > 0) {
        [UIView animateWithDuration:.1 animations:^{
            textField.layer.borderColor = UNWINE_RED.CGColor;
        } completion:^(BOOL finished) {
            textField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
            [self flashBorder:textField count:(count - 1)];
        }];
    } else {
        textField.layer.borderColor = [ThemeHandler getSeperatorColor:theme].CGColor;
    }
}*/

@end
