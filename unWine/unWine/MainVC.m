//
//  MainVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/27/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "MainVC.h"
#import "LoginVC.h"
#import "customTabBarController.h"
#import "CheckinInterface.h"
#import "unWineAppDelegate+URL_Handling.h"

@implementation MainVC {
    NSDictionary *afterLaunching;
    BOOL alreadyLaunched;
}

+ (instancetype)sharedInstance {
    //LOGGER(@"Enter");
    static dispatch_once_t p = 0;
    
    __strong static MainVC *_main = nil;
    dispatch_once(&p, ^{
        _main = [[self alloc] init];
    });
    
    return _main;
}

- (void)viewDidLoad {
    //LOGGER(@"Enter");
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:CI_FOREGROUND_COLOR];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:CI_FOREGROUND_COLOR];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:UNWINE_RED];
    [[UIToolbar appearance/*WhenContainedIn:[CastCheckinTVC class], nil*/] setBackgroundColor:CI_MIDDGROUND_COLOR];
    
    self.view.backgroundColor = [UIColor blackColor];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    //LOGGER(@"Enter");
    [super viewDidAppear:animated];
    
    [[self presentIfNecessary:NO] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        if([self.presented isKindOfClass:[customTabBarController class]])
            [self didPresentTabBar];
        
        return nil;
    }];
}

- (void)checkPresentView {
    //LOGGER(@"Enter");
    if(self.presented) {
        User *user = [User currentUser];
        if(user && ![user isAnonymous] && [self.presented isKindOfClass:[LoginVC class]]) {
            [self dismissPresented:NO];
        } else if(!user && [self.presented isKindOfClass:[customTabBarController class]]) {
            [self dismissPresented:NO];
        }
    }
}

- (BFTask *)presentIfNecessary:(BOOL)animated {
    //LOGGER(@"Enter");
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];

    if(!self.presented && user) {
        LOGGER(@"Updating user social media");
        [[user updateSocialMediaInfo] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            if (t.error) {
                LOGGER(@"Something went wrong updating social media");
                LOGGER(t.error.localizedDescription);
                exit(1);
            
            }

            LOGGER(@"Updated social media information");
            [Analytics trackLastLogin];
            [GET_APP_DELEGATE initThirdPartyWithUser];
            
            customTabBarController<StateControl> *tabBar = [[customTabBarController alloc] init];
            //LOGGER(tabBar);
            self.presented = tabBar;
            [self presentViewController:tabBar animated:animated completion:^{
                [source setResult:@(YES)];
            }];
            
            return nil;
        }];
            
    } else if (!self.presented && !user) {
        LOGGER(@"Presenting Login VC");
        LoginVC<StateControl> *login = [[LoginVC alloc] init];
        self.presented = login;
        [self presentViewController:login animated:animated completion:^{
            [source setResult:@(YES)];
        }];

    } else
        [source setResult:@(NO)];
    
    return source.task;
}

- (BFTask *)dismissPresented:(BOOL)animated {
    //LOGGER(@"Enter");
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    UIViewController *vc = self.presented.presentedViewController;
    while(vc) {
        [vc dismissViewControllerAnimated:NO completion:nil];
        vc = vc.presentedViewController;
    }
    
    [self.presented dismissViewControllerAnimated:animated completion:^{
        if([self.presented isKindOfClass:[customTabBarController class]])
            [self didDismissTabBar];
        
        self.presented = nil;
        (GET_APP_DELEGATE).ctbc = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self presentIfNecessary:YES] continueWithBlock:^id(BFTask *task) {
                [source setResult:task.result];
                return nil;
            }];
        });
    }];
    
    return source.task;
}

- (void)enqueueProtocolURL:(NSDictionary *)dict {
    //LOGGER(@"Enter");
    @synchronized (self) {
        if(alreadyLaunched) {
            afterLaunching = nil;
            [(GET_APP_DELEGATE) handleProtocolURL:dict];
        } else
            afterLaunching = dict;
    }
}

- (void)didPresentTabBar {
    //LOGGER(@"Enter");
    @synchronized (self) {
        if(!alreadyLaunched) {
            if(afterLaunching) {
                [(GET_APP_DELEGATE) handleProtocolURL:afterLaunching];
                afterLaunching = nil;
            }
            alreadyLaunched = YES;
        }
    }
}

- (void)didDismissTabBar {
    //LOGGER(@"Enter");
    @synchronized (self) {
        if(alreadyLaunched)
            alreadyLaunched = NO;
    }
}

@end
