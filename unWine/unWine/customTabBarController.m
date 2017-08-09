//
//  BaseViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "customTabBarController.h"

#import "Analytics.h"
#import "AppboyKit.h"
#import "CastInboxVC.h"
#import "CastProfileVC.h"
#import "CheckinInterface.h"
#import "contactViewController.h"
#import "MeritsTVC.h"
#import "MessengerVC.h"
#import "ParseSubclasses.h"
#import "PopoverVC.h"
#import "unWineAppDelegate.h"
//#import "UserVoice.h"
#import "UVRootViewController.h"
#import "DiscoverTVC.h"


#import <AudioToolbox/AudioToolbox.h>

@interface customTabBarController () <ABKInAppMessageControllerDelegate>
@property (nonatomic) BOOL firstTimeLoading;
@property (nonatomic) BOOL userInteractionBlocked;
@end

@implementation customTabBarController

@synthesize messageButton, userIsOnScanner, profileVC, messenger, searchController, profileController, newsFeedInitialController;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewControllers = [self getControllers];
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
            vc.tabBarItem.title = nil;
            vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        }];
        
        [self addCenterButtonWithImage:[UIImage imageNamed:@"shrunkflatuw"] highlightImage:nil];
    }
    return self;
}

/*
 * BASIC STUFF
 */
- (void)viewDidLoad
{
    //LOGGER(@"Enter");
    [super viewDidLoad];
    self.userInteractionBlocked = FALSE;
    
    //[self tabSetUp];
    
    [Analytics trackActivityForTarget:self];
    [Appboy sharedInstance].inAppMessageController.delegate = self;
    
    self.userIsOnScanner = NO;
    //self.delegate = self;
    [customTabBarController fetchConfigConstants];
    
    unWineAppDelegate *appDelegate = (unWineAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateTabBar:self];
    
    self.firstTimeLoading = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // When opening the app, show them the checkin view
    if (self.firstTimeLoading) {
        [self setSelectedIndex:1];
        self.firstTimeLoading = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    //LOGGER(@"Enter");
    [super viewDidAppear:animated];
    //[self becomeFirstResponder];
    
    User *user = [User currentUser];
    if(![user isAnonymous] && [User hasSeen:WITNESS_GUEST_TOAST]) {
        [User unwitness:WITNESS_GUEST_TOAST];
    }
    
    if (self.profileVC) {
        LOGGER(@"Refreshing notifications");
        [self requestNewsNewsFeedUpdate];
    } else {
        LOGGER(@"Don't have profileVC yet");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    //LOGGER(@"Enter");
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    //LOGGER(@"Enter");
    //[[MainVC sharedInstance] dismissPresented:NO];
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (BOOL)canBecomeFirstResponder {
    //LOGGER(@"Enter");
    return YES;
}

- (UINavigationController *)getVinecastNavCon {
    //LOGGER(@"Enter");
    return [self.viewControllers objectAtIndex:1];
}

- (UINavigationController *)getCheckinNavCon {
    //LOGGER(@"Enter");
    return [self.viewControllers objectAtIndex:1];
}

- (UINavigationController *)getProfileNavCon {
    //LOGGER(@"Enter");
    return [self.viewControllers objectAtIndex:2];
}

- (VineCastTVC *)getVinecastTVC {
    //LOGGER(@"Enter");
    return (VineCastTVC *)[[self getVinecastNavCon].viewControllers objectAtIndex:0];
}

- (CastScannerVC *)getScannerVC {
    //LOGGER(@"Enter");
    return (CastScannerVC *)[[self getCheckinNavCon].viewControllers objectAtIndex:1];
}

- (CastProfileVC *)getProfileVC {
    //LOGGER(@"Enter");
    return (CastProfileVC *)[[self getProfileNavCon].viewControllers objectAtIndex:0];
}


- (void)disableInteraction {
    //self.userInteractionBlocked = YES;
    self.tabBar.userInteractionEnabled = NO;
}

- (void)enableInteraction {
    //self.userInteractionBlocked = NO;
    self.tabBar.userInteractionEnabled = YES;
}

/*
 * END BASIC STUFF
 */


/*
 * SETUP STUFF
 */

- (NSArray<UINavigationController *> *)getControllers {
    [self tabSetUp];
    
    return @[newsFeedInitialController, searchController, profileController];
}

- (void)tabSetUp {
    //LOGGER(@"Enter");
    // Tab 1
    newsFeedInitialController = [[UIStoryboard storyboardWithName:@"Recommendation" bundle:nil] instantiateInitialViewController];
    newsFeedInitialController.title = nil;
     newsFeedInitialController.tabBarItem.image = [UIImage imageNamed:@"compass"];

    
    /*newsFeedInitialController = [[UINavigationController alloc] initWithRootViewController:[[DiscoverTVC alloc] init]];
    newsFeedInitialController.title = nil;
    newsFeedInitialController.tabBarItem.image = [UIImage imageNamed:@"compass"];
    newsFeedInitialController.view.tag = 0;
    newsFeedInitialController.view.backgroundColor = [ThemeHandler getDeepBackgroundColor];
    */
    // Tab 2
    UIStoryboard *newsFeed = [UIStoryboard storyboardWithName:@"VineCast" bundle:nil];
    searchController = [newsFeed instantiateInitialViewController];
    searchController.title = @"";
    
    // Tab 3
    UIStoryboard *castProfile = [UIStoryboard storyboardWithName:@"CastProfile" bundle:nil];
    profileController = [castProfile instantiateInitialViewController];
    profileController.title = nil;
    profileController.tabBarItem.image = WINERY_ICON;

    NSLog(@"profileController controllers - %@", [profileController.viewControllers description]);
    
    CastProfileVC *profile = [profileController.viewControllers objectAtIndex:0];//[[CastProfileVC alloc] init];
    profile.isProfileTab = YES;
    [profile setProfileUser:[User currentUser]];
    self.profileVC = profile;
}


// Create a custom UIButton and add it to the center of our tab bar
- (void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage {
    UIView *button = [[UIView alloc] initWithFrame:
                      CGRectMake(SEMIWIDTH(self.tabBar) - SEMIWIDTH2(buttonImage),
                                 -10,
                                 buttonImage.size.width,
                                 buttonImage.size.height)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:buttonImage];
    [button addSubview:imgView];
    [button sendSubviewToBack:imgView];
    
    // Tap Recognizers
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(selectCheckInCell)];
    singleTap.numberOfTapsRequired = 1;
    [button addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(showScanner)];
    doubleTap.numberOfTapsRequired = 2;
    [button addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.tabBar addSubview:button];
}

- (void)selectCheckInCell {
    LOGGER(@"Enter");
    if([User currentUser]) {
        //[Analytics trackUserOpenedScanner];
    }
    
    if(self.view.tag == MOVE_TO_CHECKIN)
        self.view.tag = 0;
    
    [self setSelectedIndex:1];
    [self setSelectedViewController:[self.viewControllers objectAtIndex:1]];
}

- (void)showScanner {
    LOGGER(@"Enter");
    // Make sure this is selected
    [self selectCheckInCell];
    
    // Show Scanner
    VineCastTVC *cvc = (VineCastTVC *)[searchController.viewControllers firstObject];
    [cvc showScanner];
}

/*
 * END SETUP STUFF
 */

/*
 * DELEGATE STUFF
 */

/*- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    LOGGER(@"Enter");
    return !self.userInteractionBlocked;
}*/

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    ////LOGGER(@"Enter");
    NSUInteger indexOfTab = [[tabBar items] indexOfObject:item];
    NSString *s = [NSString stringWithFormat:@"Selected tab %lu", (unsigned long)indexOfTab];
    LOGGER(s);
    
    if (indexOfTab == 0) {
        LOGGER(@"selectDiscoverTab");
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_TAPPED_RECOMMENDATION_TAB);
    
    } else if (indexOfTab == 1) {
        LOGGER(@"selectVineCastTab");
        [self selectCheckInCell];

    } else {
        //LOGGER(@"Everything else");
        //[self countAlertObjects];
        //[self checkForFollowRequestAndOtherNotifications];
        //[self requestNewsNewsFeedUpdate];
        [self setSelectedIndex:indexOfTab];
    }
    //[self switchToTab:indexOfTab];
}

/*
// SELECTING STUFF
- (void)selectFeedCell {
    //LOGGER(@"Enter");
    [self setSelectedIndex:0];
}*/


- (void)selectInboxInCell {
    //LOGGER(@"Enter");
    [self setSelectedIndex:2];
    NSLog(@"selected inbox button");
}

- (void)selectMoreCell {
    //LOGGER(@"Enter");
    [self setSelectedIndex:4];
    
    [self.selectedViewController.navigationController popToRootViewControllerAnimated:YES];
}

/*- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    //[super setSelectedIndex:selectedIndex];
    UINavigationController *navigationController = [[self.viewControllers objectAtIndex:selectedIndex] as:[UINavigationController class]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}*/


// TAB SWITCHING STUFF
#define WINE_LOGO_OFFSET 14

+ (void) hideTabBar:(UITabBarController *) tabbarcontroller {
    //LOGGER(@"Enter");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height + WINE_LOGO_OFFSET;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        fHeight = screenRect.size.width + WINE_LOGO_OFFSET;
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.3];
    
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
    
    //[UIView commitAnimations];
}

+ (void)showTabBar:(UITabBarController *) tabbarcontroller {
    //LOGGER(@"Enter");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - tabbarcontroller.tabBar.frame.size.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        fHeight = screenRect.size.width - tabbarcontroller.tabBar.frame.size.height;
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    
    //[UIView commitAnimations];
}

/*
 * END DELEGATE STUFF
 */


/*
 * APPBOY STUFF
 */

- (BOOL) onInAppMessageReceived:(ABKInAppMessage *)inAppMessage {
    //LOGGER(@"Enter");
    //Return NO when you want Appboy to handle the display of the slideup.
    NSLog(@"%s - Slide Up RECEIVED", __PRETTY_FUNCTION__);
    
    NSLog(@"$s - Slide Up Contents = %@", inAppMessage.message);
    
    return NO;
}

- (BOOL) onInAppMessageClicked:(ABKInAppMessage *)inAppMessage {
    //LOGGER(@"Enter");
    NSLog(@"%s - Slide Up CLICKED", __PRETTY_FUNCTION__);
    
    if(inAppMessage.inAppMessageClickActionType == ABKInAppMessageDisplayNewsFeed) {
        NSURL *url = [NSURL URLWithString:@"unwineapp://newsfeed"];
        [inAppMessage setInAppMessageClickAction:ABKInAppMessageRedirectToURI withURI:url];
    }
    
    return NO;
}

- (void) onInAppMessageDismissed:(ABKInAppMessage *)inAppMessage {
    //LOGGER(@"Enter");
    NSLog(@"%s - Slide Up DISMISSED", __PRETTY_FUNCTION__);
}

/*
 - (ABKInAppMessageDisplayChoice) beforeInAppMessageDisplayed:(ABKInAppMessage *)inAppMessage withKeyboardIsUp:(BOOL)keyboardIsUp {
 NSLog(@"%s", __PRETTY_FUNCTION__);
 
 return ABKDisplayInAppMessageNow;//ABKDisplaySlideupNow;
 }
 */

- (void)showUserVoice {
    //LOGGER(@"Enter");
    ABKFeedbackViewControllerModalContext *modalFeedback = [[ABKFeedbackViewControllerModalContext alloc] init];
    [self presentViewController:modalFeedback animated:YES completion:nil];
}

/*
- (void)showUserVoice{
    
    NSLog(@"%s - Showing UserVoice", __PRETTY_FUNCTION__);
    
    // Set this up once when your application launches
    UVConfig *config = [UVConfig configWithSite:@"unwine.uservoice.com"];
    config.forumId = 266805;
    
    User *user = [User currentUser];
    if(![user isAnonymous]) {
        [config identifyUserWithEmail:user.email name:[user getName] guid:user.objectId];
        
        config.userTraits = @{
                              @"created_at" : @(user.createdAt.timeIntervalSinceNow),    // Unix timestamp for the date the user signed up
                              @"type"       : @"iOS App Version", // Optional: segment your users by type
                              @"account"        : @{
                                      @"id"             : user.objectId,                 // Optional: associate multiple users with a single account
                                      @"name"           : [NSString stringWithFormat:@"iOS App Version - %@", GET_UNWINE_VERSION],         // Account name
                                      @"created_at"     : @(user.createdAt.timeIntervalSinceNow),  // Unix timestampe for the date the account was created
                                      @"monthly_rate"   : @(1.00),                  // Decimal; monthly rate of the account
                                      @"ltv"            : @(1.00),            // Decimal; lifetime value of the account
                                      @"plan"           : @"Free"           // Plan name for the account
                                      }
                              };
    }
    
    [UserVoice initialize:config];
    
    // Visual appearance
    UVStyleSheet *styleSheet = [UVStyleSheet instance];
    
    styleSheet.navigationBarTintColor = [UIColor whiteColor];
    styleSheet.navigationBarTextColor = [UIColor whiteColor];
    styleSheet.navigationBarBackgroundColor = UNWINE_RED;
    
    // Call this wherever you want to launch UserVoice
    
    [UserVoice presentUserVoiceInterfaceForParentViewController:[unWineAppDelegate topMostController]];
}
 */
 

- (void)showCustomSlideUpWithMessage:(NSString *)message andURL:(NSURL *)url {
    //LOGGER(@"Enter");
    if (![User currentUser]) {
        NSLog(@"%s - User must be logged in", __PRETTY_FUNCTION__);
        return;
    }
    [self.profileVC updateNewsButtonWithTimer:NO];
    
    NSLog(@"%s - Creating Custom Slideup", __PRETTY_FUNCTION__);
    
    if (!message) {
        NSLog(@"%s - Did not display a Custom Slide Up. Message is nil", __PRETTY_FUNCTION__);
        return;
    }
    
    LOGGER(url);
    
    ABKInAppMessageSlideup *customSlideup = [[ABKInAppMessageSlideup alloc] init];
    customSlideup.message = [NSString stringWithFormat:@"%@", message];
    if (url) {
        LOGGER(@"Showing slide up with custom url");
        [customSlideup setInAppMessageClickAction:ABKInAppMessageRedirectToURI withURI:url];
    } else {
        LOGGER(@"Showing slide up with no url");
        NSURL *url = [NSURL URLWithString:@"unwineapp://inbox"];
        [customSlideup setInAppMessageClickAction:ABKInAppMessageRedirectToURI withURI:url];
    }
    customSlideup.duration = 6;
    customSlideup.inAppMessageDismissType = ABKInAppMessageDismissManually;
    customSlideup.inAppMessageSlideupAnchor = ABKInAppMessageSlideupFromBottom;
    
    ABKInAppMessageController *messageController = [Appboy sharedInstance].inAppMessageController;
    
    [messageController addInAppMessage:customSlideup];
}

#pragma mark - Feed Controller Stuff

- (void)showNewsFeedController:(CastInboxDefault)openTo {
    //LOGGER(@"Enter");
    // Look at Parse Config dashboard for parameter names and types
    LOGGER(@"Showing NewsFeed Controller");
    
    /*ABKFeedViewControllerNavigationContext *genericFeed = [[ABKFeedViewControllerNavigationContext alloc] init];
     PFConfig *config = [PFConfig currentConfig];
     
     genericFeed.title = config[@"NEWSFEED_TITLE"];*/
    
    UINavigationController *inbox = [[UIStoryboard storyboardWithName:@"CastInbox" bundle:nil] instantiateInitialViewController];
    
    CastInboxVC *cast = [[inbox viewControllers] objectAtIndex:0];
    cast.openTo = openTo;
    
    [(UINavigationController *)self.selectedViewController presentViewController:inbox animated:YES completion:nil];
    
    //if (IOS_8_OR_MAJOR) {
    //    [(UINavigationController *)self.selectedViewController showViewController:inbox sender:nil];
    //} else {
    //    [(UINavigationController *)self.selectedViewController pushViewController:inbox animated:YES];
    //}
}

- (void)requestNewsNewsFeedUpdate {
    //LOGGER(@"Enter");
    [self.profileVC refreshUnWineNewsNewsFeed];
}

/*
 * END APPBOY STUFF
 */


/*
 * DEEP LINKING STUFF
 */

#define OK_BUTTON_TITLE     @"Cheers"
#define CANCEL_BUTTON_TITLE @"After a bottle"

#define CONTACT_CONTROLLER_IDENTIFIER @"contactController"

- (void)showClubW {
    //LOGGER(@"Enter");
    UIStoryboard *discover = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    UIViewController *clubWController = [discover instantiateViewControllerWithIdentifier:@"ClubW"];
    
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.selectedViewController pushViewController:clubWController animated:YES];
    }
}

- (void)showTrendingWines {
    //LOGGER(@"Enter");
    UIStoryboard *discover = [UIStoryboard storyboardWithName:@"Discover" bundle:nil];
    UIViewController *trendingWinesController = [discover instantiateViewControllerWithIdentifier:@"TrendingWines"];
    
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.selectedViewController pushViewController:trendingWinesController animated:YES];
    }
}

- (void)showMerits {
    //LOGGER(@"Enter");
    UIStoryboard *meritsStoryboard = [UIStoryboard storyboardWithName:@"Merits" bundle:nil];
    MeritsTVC *merits = [meritsStoryboard instantiateInitialViewController];
    
    merits.earnedMerits = [User currentUser].earnedMerits;
    merits.title = @"Merits";
    
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self.selectedViewController pushViewController:merits animated:YES];
    }
}

/*
 - (void)showSobrietyTest {
 UIStoryboard *moreStoryboard = [UIStoryboard storyboardWithName:@"Minigames" bundle:nil];
 UIViewController *sobrietyController = [moreStoryboard instantiateViewControllerWithIdentifier:@"minigameCentral"];
 
 if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
 [(UINavigationController *)self.selectedViewController pushViewController:sobrietyController animated:YES];
 }
 }*/

- (void)showInviteFriends {
    //LOGGER(@"Enter");
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    UIViewController *friendsController = [profileStoryboard instantiateViewControllerWithIdentifier:@"friendsController"];
    
    //if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *nav = (UINavigationController *)[unWineAppDelegate topMostController];
    [nav pushViewController:friendsController animated:YES];
    //}
}

- (void)showAppBoyNewsFeed:(CastInboxDefault)openTo {
    //LOGGER(@"Enter");
    [self showNewsFeedController:openTo];
}

- (void)showConversationWith:(NSString *)path useRootVC:(BOOL)useRoot {
    //LOGGER(@"Enter");
    NSString *objectId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSLog(@"showing conversation with %@", objectId);
    
    SHOW_HUD;
    [[Conversations getConvoObjectTask:objectId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        if(task.error) {
            LOGGER(task.error);
            //[unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
        } else if(task.result) {
            MessengerVC *mess = [[MessengerVC alloc] initWithConversation:task.result];
            
            if([mess.convo isUnread]) {
                [mess.convo markRead];
            }
            
            [self pushViewController:mess];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"" message:@"Conversation not found."];
        }
        
        return nil;
    }];
}

- (void)showVineCastWith:(NSString *)path useRootVC:(BOOL)useRoot {
    //LOGGER(@"Enter");
    NSString *objectId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSLog(@"showing vinecast with %@", objectId);
    
    SHOW_HUD;
    [[NewsFeed getNewsFeedObjectTask:objectId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        if(task.error) {
            LOGGER(task.error);
            //[unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
        } else if(task.result) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VineCast" bundle:nil];
            VineCastTVC *feed = [storyboard instantiateViewControllerWithIdentifier:@"feed"];
            //[feed adjustFrame];
            [feed setVineCastSingleObject:(NewsFeed *)task.result];
            
            [self pushViewController:feed];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"" message:@"Checkin not found."];
        }
        
        return nil;
    }];
}

- (void)showProfileWith:(NSString *)path useRootVC:(BOOL)useRoot {
    //LOGGER(@"Enter");
    NSString *objectId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSLog(@"showing user with %@", objectId);
    
    SHOW_HUD;
    [[User getUserObjectTask:objectId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        if(task.error) {
            LOGGER(task.error);
            //[unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
        } else if(task.result) {
            CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
            [profile setProfileUser:(User *)task.result];
            
            [self pushViewController:profile];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"" message:@"User not found."];
        }
        
        return nil;
    }];
}

- (void)showWineWith:(NSString *)path useRootVC:(BOOL)useRoot {
    //LOGGER(@"Enter");
    NSString *objectId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSLog(@"showing wine with %@", objectId);
    
    SHOW_HUD;
    [[unWine getWineObjectTask:objectId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        if(task.error) {
            LOGGER(task.error);
            //[unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
        } else if(task.result) {
            unWine *wine = task.result;
            
            WineContainerVC *container = [[WineContainerVC alloc] init];
            container.wine = wine;
            container.isNew = NO;
            container.cameFrom = CastCheckinSourcePushNotification;
            [self pushViewController:container];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"" message:@"Wine not found."];
        }
        
        return nil;
    }];
}

- (void)showWineryWith:(NSString *)path useRootVC:(BOOL)useRoot {
    //LOGGER(@"Enter");
    NSString *objectId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSLog(@"showing winery with %@", objectId);
    
    SHOW_HUD;
    [[Winery getWineryObjectTask:objectId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        if(task.error) {
            LOGGER(task.error);
            //[unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
        } else if(task.result) {
            Winery *winery = task.result;
            
            WineryContainerVC *container = [[WineryContainerVC alloc] init];
            container.winery = winery;
            [self pushViewController:container];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"" message:@"Winery not found."];
        }
        
        return nil;
    }];
}

- (void)pushViewController:(UIViewController *)controller {
    //LOGGER(@"Enter");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nav = [unWineAppDelegate topMostController];
        if([nav isKindOfClass:[customTabBarController class]])
            nav = self.selectedViewController;
        
        [(UINavigationController *)nav pushViewController:controller animated:YES];
        /*if(useRoot && !self.selectedViewController) {
         UINavigationController *nav = (UINavigationController *)[unWineAppDelegate topMostController];
         [nav pushViewController:detail animated:YES];
         } else {
         UINavigationController *nav = (UINavigationController *) self.selectedViewController;
         [nav pushViewController:detail animated:YES];
         }*/
    });
}

/*
 * END DEEP LINKING STUFF
 */


/*
 * NOTIFICATION STUFF
 */

- (void)showFeedBackAlert{
    //LOGGER(@"Enter");
    //    NSLog(@"showFeedBackAlert");
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Feedback"
    //                                                    message:@"Let's make the world a better place together"
    //                                                   delegate:self
    //                                          cancelButtonTitle:nil
    //                                          otherButtonTitles:OK_BUTTON_TITLE, CANCEL_BUTTON_TITLE, nil];
    //    
    //    [alert show];
}
/*
 * END NOTIFICATION STUFF
 */



/*
 * PARSE STUFF
 */
- (void)countAlertObjects {
    
    //LOGGER(@"Enter");
    /*PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
     [query whereKey:@"Owner" equalTo:[User currentUser]];
     [query whereKey:@"Type" equalTo:@"Alert"];
     [query whereKey:@"viewed" equalTo:[NSNumber numberWithBool:NO]];
     [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
     NSLog(@"Count should be: %i", number);
     self.messageButton.alpha = (number > 0)? 1 : 0;
     }];*/
    
}

- (void)checkForFollowRequestAndOtherNotifications{
    //LOGGER(@"Enter");
    //NSLog(@"%s - Checking for Inbox Count in Background -- disabled", __PRETTY_FUNCTION__);
    
    /*PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
     if(![User currentUser])
     return;
     [query whereKey:@"toUser" equalTo:[User currentUser]];
     [query includeKey:@"fromUser"];
     [query whereKey:@"state" equalTo:@"Pending"];
     
     [query countObjectsInBackgroundWithBlock:^(int friendShipCount, NSError *error){
     if(!error) {
     PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
     if(![User currentUser])
     return;
     [notificationQuery whereKey:@"Owner" equalTo:[User currentUser]];
     [notificationQuery whereKeyExists:@"newsFeedPointer"];
     [notificationQuery whereKey:@"viewed" equalTo:[NSNumber numberWithBool:NO]];
     
     [notificationQuery countObjectsInBackgroundWithBlock:^(int notificationCount, NSError *error) {
     if(!error) {
     NSLog(@"%s - notificationCount = %i", __PRETTY_FUNCTION__, notificationCount);
     //NSInteger totalCount = notificationCount + friendShipCount;
     //NSString *countString = (totalCount > 0)? [NSString stringWithFormat:@"%li", (long)totalCount] : nil;
     
     [notificationQuery countObjectsInBackgroundWithBlock:^(int notificationCount, NSError *error) {
     NSLog(@"%s - notificationCount = %i", __PRETTY_FUNCTION__, notificationCount);
     NSInteger totalCount = notificationCount + friendShipCount;
     NSString *countString = (totalCount > 0)? [NSString stringWithFormat:@"%li", (long)totalCount] : nil;
     
     [[self.tabBar.items objectAtIndex:INBOX_TAB_INDEX] setBadgeValue: countString];
     }];
     } else {
     NSLog(@"supposed error %@", error);
     [[self.tabBar.items objectAtIndex:INBOX_TAB_INDEX] setBadgeValue: @"0"];
     }
     }];
     } else {
     NSLog(@"supposed error %@", error);
     [[self.tabBar.items objectAtIndex:INBOX_TAB_INDEX] setBadgeValue: @"0"];
     }
     }];*/
    
    
    // Count Alerts
    //[self countAlertNotifications:object];
}

+ (void)fetchConfigConstants {
    //LOGGER(@"Enter");
    LOGGER(@"general config");
    
    [[PFConfig getConfigInBackground] continueWithBlock:^id _Nullable(BFTask<PFConfig *> * _Nonnull task) {
        PFConfig *config = task.result;
        if (!task.error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        [User setFiltersLockedAfter:[config[@"FILTERS_LOCKED_AFTER"] integerValue]];
        [User setSuperUserCheckinCount:[config[@"SUPER_USER_CHECKIN_COUNT"] integerValue]];
        [User setShareMessage:config[@"UNWINE_SHARE_MESSAGE"]];
        [User setAppStoreURL:config[@"IOS_APP_STORE_URL"]];
        [unWine setAllWinesLocked:[config[@"LOCK_ALL_WINES"] boolValue]];
        [unWine setFeaturedWines:config[@"FEATURED_WINES"]];
        [unWine setVerifiedCount:[config[@"CHECKIN_FOR_VERIFICATION"] integerValue]];
        [unWine setWeatheredCount:[config[@"CHECKIN_FOR_WEATHERED"] integerValue]];
        
        return [User getLevels];
    }];
}

- (void)checkForNewAppUpdate {
    //LOGGER(@"Enter");
    NSLog(@"%s - Getting the latest config...", __PRETTY_FUNCTION__);
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        // Look at Parse Config dashboard for parameter names and types
        NSString *appStoreversion = config[@"IOS_APP_STORE_VERSION"];
        NSString *currentVersion = GET_UNWINE_VERSION;
        NSString *appStoreURL = config[@"IOS_APP_STORE_URL"];
        NSString *updateMessage = config[@"UPDATE_MESSAGE"];
        
        if (![appStoreversion isEqualToString:currentVersion]) {
            [self showCustomSlideUpWithMessage:updateMessage andURL:[NSURL URLWithString:appStoreURL]];
        }
        
    }];
}

/*
 * END PARSE STUFF
 */

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    //LOGGER(@"Enter");
    if (motion == UIEventSubtypeMotionShake) {
        UIViewController *controller = [unWineAppDelegate topMostController];
        if([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)controller;
            if(![[nav.viewControllers objectAtIndex:0] isKindOfClass:[UVRootViewController class]]) {
                [self showCustomSlideUpWithMessage:@"Like shaking things up?\nPlease tell us how to make your experience better!" andURL:UNWINE_FEEDBACK_URL];
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        } else {
            [self showCustomSlideUpWithMessage:@"Like shaking things up?\nPlease tell us how to make your experience better!" andURL:UNWINE_FEEDBACK_URL];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

@end

