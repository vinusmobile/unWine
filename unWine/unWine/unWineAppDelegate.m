//
//  unWineAppDelegate.m
//  unWine
//
//  Created by Fabio Gomez on 9/28/13.
//  Copyright (c) 2013 LION Mobile. All rights reserved.
//  Test for Biz
//  Testing bitbucket

#import "unWineAppDelegate+Push_Notifications.h"
#import "unWineAppDelegate+URL_Handling.h"
#import <Parse/Parse.h>
#import "Flurry.h"
#import "iRate.h"
#import "MuchAppManyPurchase.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import "Analytics.h"
#import "Appboy.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Bolts/Bolts.h>
#import "ParseSubclasses.h"
#import "ABKFeedViewControllerNavigationContext.h"
#import "MeritsTVC.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "MessengerVC.h"
#import "CommentVC.h"
#import "PFUser.h"
#import <GooglePlaces/GooglePlaces.h>
#import <Neumob/Neumob.h>
#import <CloudSight/CloudSight.h>
#import <Intercom/Intercom.h>

#import "MainVC.h"
#define APPLICATION_SHORTCUT_CHECKIN @"com.LionMobile.unWine.action.checkin"
#import "unWineAppDelegate.h"
#import <Branch/Branch.h>
//#import <NUI/NUISettings.h>

@implementation unWineAppDelegate

@synthesize window = _window, ctbc = _ctbc, environment = _environment, launchOptions = _launchOptions, application = _application, userInfo = _userInfo, checkForMerits = _checkForMerits, deviceToken = _deviceToken;
//Test 125

static NSString *activateOnLoad = nil;

// test 12341234
- (void)initializeiRate
{
    NSLog(@"Getting the latest config...");
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        //configure iRate
        [iRate sharedInstance].eventsUntilPrompt = [config[@"IRATE_EVENTS_UNTIL_PROMPT"] intValue];
        
        //disable minimum day limit and reminder periods
        [iRate sharedInstance].daysUntilPrompt = [config[@"IRATE_DAYS_UNTIL_PROMPT"] intValue];
        [iRate sharedInstance].remindPeriod = [config[@"IRATE_REMIND_PERIOD"] intValue];
        
        //[iRate sharedInstance].messageTitle = @"TEST";
        [iRate sharedInstance].message = config[@"IRATE_MESSAGE"];
        [iRate sharedInstance].rateButtonLabel = config[@"IRATE_RATE_BUTTON_LABEL"];
        [iRate sharedInstance].remindButtonLabel = config[@"IRATE_REMIND_BUTTON_LABEL"];
        [iRate sharedInstance].cancelButtonLabel = config[@"IRATE_CANCEL_BUTTON_LABEL"];
        
        [iRate sharedInstance].promptAtLaunch = NO;
        [iRate sharedInstance].previewMode = [config[@"IRATE_PREVIEW_MODE"] boolValue];
        NSLog(@"Initializing iRate");
    }];
}

// Handle uncaught exception code
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"App Crash:\n%@", exception);
    NSLog(@"Stack Trace:\n%@", [exception callStackSymbols]);
    [Analytics trackException:exception withName:@"Uncaught Exception" andMessage:@"From exception handler in App Delegate"];
    //exit(1);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"********** %s **********", __PRETTY_FUNCTION__);
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = [MainVC sharedInstance];
    self.window.tintColor = UNWINE_RED;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"Environment"] != nil)
        self.environment = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Environment"] integerValue];
    else
        self.environment = DEVELOPMENT;
    
    self.launchOptions = launchOptions;
    
    if(NSClassFromString(@"UIApplicationShortcutItem")) {//[application respondsToSelector:@selector(shortcutItems)]) {
        NSLog(@"device supports shortcuts!");
        UIApplicationShortcutItem *checkin = [[UIApplicationShortcutItem alloc] initWithType:APPLICATION_SHORTCUT_CHECKIN localizedTitle:@"Checkin Wine" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare] userInfo:nil];
        application.shortcutItems = @[checkin];
        
        UIApplicationShortcutItem *shortcut = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if(shortcut) {
            NSLog(@"did launch with shortcut!");
            [self handleShortcut:shortcut];
        }
    }
    
    [self launchThirdPartyLibrariesWithApplication:application];
    [self customizeAppearance];
    
    // To show the logo for a while
    //sleep(2);
    
    [self logLaunchOptions];
    
    application.applicationSupportsShakeToEdit = YES;
    
    // Register for Push Notifications
    [self registerForPushNotificationsUsingApplication:application];
    
    // Log Track Opens
    //happens twice -- [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Handle Push Notifications here
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [[MainVC sharedInstance] enqueueProtocolURL:userInfo];
        //[self handleProtocolURL:userInfo];
    }
    
    [GMSPlacesClient provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    //[[IQKeyboardManager sharedManager] disableInViewControllerClass:(nonnull Class)];
    //[[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[MessengerVC class]];
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[MessengerTVC class]];
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[CommentVC class]];
    [[IQKeyboardManager sharedManager] disableDistanceHandlingInViewControllerClass:[CommentTVC class]];
    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[CastCheckinTVC class]];
    
    // Initiate In App Purchases
    [self initiateInAppPurchases];
    //[MuchAppManyPurchase sharedInstance];
    
    // This is here for reasons.
    // Actually when checking in the whole tab bar gets dismissed and this is a workaround to tell it to check for merits
    self.checkForMerits = NO;
    [self.window makeKeyAndVisible];
    [self setStatusBarBackgroundColor:UNWINE_RED];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    return YES;//[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler([self handleShortcut:shortcutItem]);
}

- (BOOL)handleShortcut:(UIApplicationShortcutItem *)shortcutItem {
    //LOGGER(@"Enter");
    if([shortcutItem.type isEqualToString:APPLICATION_SHORTCUT_CHECKIN]) {
        NSLog(@"checkin shortcut!");
        self.selectIfNotLoaded = 2;
        if(self.ctbc) {
            self.ctbc.view.tag = MOVE_TO_CHECKIN;
            NSLog(@"checkin shortcut! - segueing");
            [self.ctbc selectCheckInCell];
            return YES;
        } else {
            activateOnLoad = APPLICATION_SHORTCUT_CHECKIN;
            return YES;
        }
    }
    
    return NO;
}

- (void)updateTabBar:(customTabBarController *)ctbc {
    _ctbc = ctbc;
    
    if(activateOnLoad) {
        for(UIApplicationShortcutItem *shortcutItem in self.application.shortcutItems) {
            if([shortcutItem.type isEqualToString:activateOnLoad])
                [self handleShortcut:shortcutItem];
        }
        
        activateOnLoad = nil;
    }
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)initiateInAppPurchases { //this shit does nothing, magic happens in PurchaseCell - bryce
    [PFPurchase addObserverForProduct:IAP_PHOTO_FILTERS block:^(SKPaymentTransaction *transaction) {
        LOGGER(@"Purchased Filters");
        if(transaction.transactionState == SKPaymentTransactionStatePurchased) {
        }
        NSLog(@"%@", transaction);
    }];
}

- (void)launchThirdPartyLibrariesWithApplication:(UIApplication *)application {
    // This must be done before enabling Parse
    [self registerParseSubclasses];
    [Flurry setCrashReportingEnabled:YES];
    [PFQuery clearAllCachedResults];
    
    if (self.environment == DEVELOPMENT || self.environment == LOCAL) {
        [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = UNWINE_APP_ID_DEVELOPMENT;
            configuration.clientKey = UNWINE_APP_CLIENT_KEY_DEVELOPMENT;
            if(self.environment == DEVELOPMENT) {
                LOGGER(@"Using either AWS or Heroku");
                configuration.server = @"https://parseapi.back4app.com/";
                //configuration.server = @"http://dev.unwine.me/parse"; // AWS
                //configuration.server = @"http://52.87.142.223/parse"; // AWS
                //configuration.server = @"http://unwine-parse-server-dev.herokuapp.com/parse";;
            } else {
                LOGGER(@"Using Local Host");
                configuration.server = @"http://70.115.146.210:1337/parse";
                //configuration.server = @"http://localhost:1337/parse";
            }
            configuration.localDatastoreEnabled = NO;
        }]];
        //[Parse setApplicationId:UNWINE_APP_ID_DEVELOPMENT clientKey:UNWINE_APP_CLIENT_KEY_DEVELOPMENT];
        [Flurry startSession:FLURRY_KEY_DEVELOPMENT];
        [Neumob initialize: NEUMOB_KEY_DEVELOPMENT];
        [Intercom setApiKey:INTERCOM_API_KEY_DEVELOPMENT forAppId:INTERCOM_APP_ID_DEVELOPMENT];
        LOGGER(@"Initialized Neumob in development");
        
    } else if (self.environment == PRODUCTION) {
        //[Parse setApplicationId:UNWINE_APP_ID_PRODUCTION clientKey:UNWINE_APP_CLIENT_KEY_PRODUCTION];
        
        [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = UNWINE_APP_ID_PRODUCTION;
            configuration.clientKey = UNWINE_APP_CLIENT_KEY_PRODUCTION;
            configuration.server = @"https://parseapi.back4app.com/"; //@"http://prod.unwine.me/parse";
            configuration.localDatastoreEnabled = NO;
        }]];
        [Flurry startSession:FLURRY_KEY_PRODUCTION];
        [Neumob initialize: NEUMOB_KEY_PRODUCTION];
        [Intercom setApiKey:INTERCOM_API_KEY_PRODUCTION forAppId:INTERCOM_APP_ID_PRODUCTION];
        LOGGER(@"Initialized Neumob in production");
    }
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:_launchOptions];
    
    // Twitter Initialization
    [PFTwitterUtils initializeWithConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    //[Fabric with:@[[Crashlytics class]]];
    
    //[[Twitter sharedInstance] startWithConsumerKey:TWITTER_CONSUMER_KEY  consumerSecret:TWITTER_CONSUMER_SECRET];
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class], [Twitter class]]];

    
    // Facebook initialization
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:_launchOptions];
    
    [self initializeiRate];
    
    // Cloudsight
    [CloudSightConnection sharedInstance].consumerKey = CLOUDSIGHT_KEY;
    [CloudSightConnection sharedInstance].consumerSecret = CLOUDSIGHT_SECRET;
    
    // Branch.io
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:self.launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            NSString *s = [NSString stringWithFormat:@"Branch params: %@", params.description];
            LOGGER(s);
            
            LOGGER(@"Test");
        }
    }];
    
    // UI Stuff
    //[NUISettings init];
}

- (void)initThirdPartyWithUser {
    LOGGER(@"Enter");
    [self initializeAppBoy];
    [self initializeCrashlitics];
    @try {
        [self initializeIntercom];

    } @catch (NSException *exception) {
        LOGGER(@"Something happened");
        LOGGER(exception);
    }
    
    LOGGER(@"Done");
}

- (void)initializeAppBoy {
    if (self.environment == DEVELOPMENT) {
        [Appboy startWithApiKey:APP_BOY_API_KEY_DEVELOPMENT inApplication:[UIApplication sharedApplication] withLaunchOptions:_launchOptions];
    } else if (self.environment == PRODUCTION) {
        [Appboy startWithApiKey:APP_BOY_API_KEY_PRODUCTION inApplication:[UIApplication sharedApplication] withLaunchOptions:_launchOptions];
    }
    
    if (_deviceToken) {
        LOGGER(@"Initializing appboy push notification");
        [[Appboy sharedInstance] registerPushToken: [NSString stringWithFormat:@"%@", _deviceToken]];
    } else {
        LOGGER(@"No device token to register appboy push notifications");
    }
    
    [Analytics trackUserDemographics];
}

- (void)initializeCrashlitics {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    User *user = [User currentUser];
    
    if (![user isAnonymous]) {
        [CrashlyticsKit setUserEmail:user.email];
    }
    
    [CrashlyticsKit setUserIdentifier:user.objectId];
    [CrashlyticsKit setUserName:user.username];
}

- (void)initializeIntercom {
    LOGGER(@"Enter");
    User *user = [User currentUser];

    if (_deviceToken) {
        LOGGER(@"Initializing Intercom push notification");
        [Intercom setDeviceToken:_deviceToken];
    } else {
        LOGGER(@"No device token to register Intercom push notifications");
    }

    [Intercom setBottomPadding:30.0];
    [Intercom registerUserWithUserId:user.objectId];
    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
    
    if (![user isAnonymous]) {
        userAttributes.email = user.email;
    }
    
    userAttributes.name = [user getName];
    userAttributes.customAttributes = @{@"rated_app" : @(user.ratedApp),
                                        @"shared_app"   : @(user.sharedApp),
                                        @"has_wine_recommendations"      : @(user.hasWineRecommendations),
                                        @"is_super_user"      : @(user.isSuperUser),
                                        @"unique_wines"      : @(user.uniqueWines),
                                        @"app_version"      : user.version,
                                        @"recent_searches"      : ISVALIDARRAY(user.recentSearches) ? [user.recentSearches componentsJoinedByString:@", "] : @"",
                                        @"number_of_checkins"      : @(user.checkIns),
                                        @"earned_merits"      : ISVALIDARRAY(user.earnedMerits) ? [user.earnedMerits componentsJoinedByString:@", "] : @"",
                                        @"gender"      : ISVALID(user.gender) ? user.gender : @"",
                                        @"twitter_handle" : ISVALID(user.twitterHandle) ? user.twitterHandle : @"",
                                        @"facebook_id" : ISVALID(user.facebookId) ? user.facebookId : @""};
    
    [Intercom updateUser:userAttributes];
    LOGGER(@"Done");
}

- (void)registerParseSubclasses {
    [User registerSubclass];
    [Friendship registerSubclass];
    [Partner registerSubclass];
    [unWine registerSubclass];
    [Grapes registerSubclass];
    [Level registerSubclass];
    [Merits registerSubclass];
    [NewsFeed registerSubclass];
    [Notification registerSubclass];
    [Images registerSubclass];
    [Conversations registerSubclass];
    [Messages registerSubclass];
    [Venue registerSubclass];
    [Feeling registerSubclass];
    [Occasion registerSubclass];
    [Comment registerSubclass];
    [Search registerSubclass];
    [Records registerSubclass];
    [Winery registerSubclass];
}

- (void)customizeAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[[UIApplication sharedApplication] preferredstatus]
    
    // Customize the navigationBar appearance
    [[UINavigationBar appearance] setBarTintColor:UNWINE_RED];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],NSForegroundColorAttributeName, Nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    
    if (IOS_8_OR_MAJOR) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    // Customize the tabBar appearance
    [[UITabBar appearance] setTintColor:UNWINE_RED];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    
    //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:UNWINE_RED];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [UIToolbar class]]]
     setTintColor:UNWINE_RED];
}

- (void)logLaunchOptions{
    if (self.launchOptions) {
        NSLog(@"********** Launched App From Scratch **********");
        
        // Extract the notification data
        NSDictionary *notificationPayload = self.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        NSLog(@"%s - notificationPayload", __PRETTY_FUNCTION__);
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, notificationPayload);
    }
}


#pragma mark - App States

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(self.ctbc && self.ctbc.messenger) {
        [self.ctbc.messenger.navigationController popViewControllerAnimated:NO];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSTimeInterval initial = TIME_STAMP;
    LOGGER(@"FBSDKAppEvents works on the main thread...");
    [FBSDKAppEvents activateApp];
    NSLog(@"delay caused by activateApp %@ms", @(TIME_STAMP - initial));
    
    User *user = [User currentUser];
    if(user != nil) {
        [customTabBarController fetchConfigConstants];
        if(self.ctbc.profileVC != nil)
            [self.ctbc.profileVC updateNewsButtonWithTimer:NO];
        
        if(ISVALID(user.sessionToken)) {
            if([user isAnonymous]) {
                [User becomeInBackground:user.sessionToken block:^(PFUser *user, NSError *error) {
                    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [Analytics trackLastLogin];
                        NSLog(@"Refreshed cached self. 0");
                    }];
                }];
            } else {
                [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [Analytics trackLastLogin];
                    NSLog(@"Refreshed cached self. 1");
                }];
            }
        } else {
            [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if([object isKindOfClass:[PFUser class]] && ISVALID(((PFUser *)object).sessionToken)) {
                    NSLog(@"Became %@", ((PFUser *)object).sessionToken);
                    [PFUser becomeInBackground:((PFUser *)object).sessionToken block:^(PFUser *user, NSError *error) {
                        [Analytics trackLastLogin];
                        NSLog(@"Refreshed cached self. 2");
                    }];
                } else {
                    [Analytics trackLastLogin];
                    NSLog(@"Refreshed cached self. 3");
                }
            }];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    //[[PFFacebookUtils session] close];
}

#pragma mark - Switch from Dev to Production

/*- (BOOL)myApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions withEnvironment:(NSUInteger)environment {
    self.environment = environment;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)environment] forKey:@"Environment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [User logOutAndDismiss:[unWineAppDelegate topMostController]];
    
    [self launchThirdPartyLibrariesWithApplication:application];
    
    
    return YES;
}*/

+ (UIViewController *)topMostController {
    UIViewController *topController = (GET_APP_DELEGATE).window.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

/*- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if([[url host] isEqualToString:@"partner"]) {
        if([[url path] isEqualToString:@"/beatbox"]) {
            //[self.window.rootViewController pushViewController:nil animated:YES];
        }
        return YES;
    }
    return NO;
}*/


@end
