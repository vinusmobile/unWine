//
//  LogInViewController.m
//  unWine
//
//  Created by Fabio Gomez on 3/6/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "LoginGenericButtonView.h"
#import "ParseSubclasses.h"
#import "MainLogInViewController.h"

@interface LogInViewController ()
@property (strong, nonatomic) IBOutlet UITextField      *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField      *passwordTextField;
@property (strong, nonatomic) IBOutlet LoginGenericButtonView *logInButton;


@end

@implementation LogInViewController
@synthesize userNameTextField, passwordTextField, logInButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.navigationItem.title = @"Log In";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
    
    self.logInButton.parentController = self;
    [self.logInButton doLoginSetup];
    
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(NSString *)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:message];
    alert.title = title;
    //alert.delegate = delegate;
    alert.leftButtonTitle = cancelButtonTitle;
    alert.rightButtonTitle = otherButtonTitles;
    [alert show];
}

- (void)logIn {
    User *user = [User currentUser];
    
    if (user && ![user isAnonymous]) {
        [self createAlertWithTitle:@"Uh oh"
                           message:@"It appears you were already logged in, restart the app!"
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        return;
    }
    
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    
    if (!ISVALID(username) && !ISVALID(password)) {
        [self createAlertWithTitle:@"Please enter a username and password!"
                           message:nil
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        return;
    } else if (ISVALID(username) && !ISVALID(password)) {
        [self createAlertWithTitle:@"Please enter a password!"
                           message:nil
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        return;
    } else if (!ISVALID(username) && ISVALID(password)) {
        [self createAlertWithTitle:@"Please enter a username!"
                           message:nil
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        return;
    }
    
    SHOW_HUD;
    if(!user) {
        [User logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            HIDE_HUD;
            
            [self continueLogin:user error:error];
        }];
    } else {
        LOGGER(@"logging out of guest account, to login to existing account");
        
        SHOW_HUD;
        
        [[[User deleteAndLogoutGuest] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                LOGGER(@"Error logging out guest user");
                LOGGER(task.error);
            } else {
                LOGGER(@"Logged out and Deleted guest user");
            }
            return [User logInWithUsernameInBackground:username password:password];
        }] continueWithBlock:^id(BFTask <PFUser *> *task) {
            HIDE_HUD;
            
            [Analytics trackGuestLogIn];
            
            [self continueLogin:task.result error:task.error];
            
            return nil;
        }];
    }
}

- (void)continueLogin:(PFUser *)user error:(NSError *)error {
    if (user) {
        LOGGER(@"Logged in the user");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        NSLog(@"(%li) - %@", (long)error.code, error.userInfo[@"error"]);
        
        NSString *errorString = (error.code == kPFErrorObjectNotFound)?
        @"The username or password does not match our records.\n\nPlease try again." : [error localizedDescription];
        
        if (self.userNameTextField.isFirstResponder) {
            [self.userNameTextField resignFirstResponder];
        } else if (self.passwordTextField.isFirstResponder) {
            [self.passwordTextField resignFirstResponder];
        }
        
        // The login failed. Check error to see why.
        [self createAlertWithTitle:@"Sometimes wine gets the best of us!"
                           message:errorString
                          delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles: nil];
    }
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forgotPassword:(id)sender {
    MainLogInViewController *main = [self.navigationController.viewControllers objectAtIndex:0];
    [main forgotPassword:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
