//
//  unWineAppDelegate.h
//  unWine
//
//  Created by Fabio Gomez on 9/28/13.
//  Copyright (c) 2013 LION Mobile. All rights reserved.
//  Testing JIRA/BitBucket for the first time

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "customTabBarController.h"
#import <UserNotifications/UserNotifications.h>

#define DEVELOPMENT 0
#define PRODUCTION 1
#define LOCAL 2

@interface unWineAppDelegate : UIResponder <UIApplicationDelegate, SFSafariViewControllerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) customTabBarController *ctbc;
@property (nonatomic) NSInteger environment;
@property (nonatomic) NSDictionary* launchOptions;
@property (nonatomic) UIApplication* application;
@property (nonatomic) NSDictionary* userInfo;
@property (nonatomic) BOOL checkForMerits;
@property (nonatomic) NSInteger selectIfNotLoaded;
@property (strong, nonatomic) NSData *deviceToken;


//- (BOOL)myApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions withEnvironment:(NSUInteger)environment;
- (void)initThirdPartyWithUser;
- (void)logoutThirdParty;

+ (UIViewController *)topMostController;
- (void)updateTabBar:(customTabBarController *)ctbc;
@end
