//
//  Analytics.h
//  unWine
//
//  Created by Fabio Gomez on 1/14/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "unWineTypes.h"
#import <UserNotifications/UserNotifications.h>

#define ANALYTICS_TRACK_EVENT(event) [Analytics trackGenericEvent:event]

@class PFObject;
@class unWine;
@class User;
@class NewsFeed;
@class UIApplication;

@interface Analytics : NSObject

// Analytics for Specific Events

/* Lazy way of tracking an event
 */
+ (void)trackGenericEvent:(NSString *)event;

/*! Track App Opens using Parse
 \warning All arguments required
 */
//+ (void)trackAppOpensUsingApplication:(UIApplication *)application andLaunchOptions:(NSDictionary *)launchOptions andUserInfo:(NSDictionary *)userInfoDictionary;
+ (void)trackAppLaunchwithLaunchOptions:(NSDictionary *)launchOptions;

/*! Track receiving push notification
 */

+ (void)trackPushNotificationReceivedWithUserInfo:(NSDictionary *)userInfo
                                   andApplication:(UIApplication *)application
                        andFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
                               notificationCenter:(UNUserNotificationCenter *)center
                                      andResponse:(UNNotificationResponse *)response;

/*! Trak post to Facebook
 \param wineObject REQUIRED. The Wine Object that was posted to Facebook
 */
+ (void)trackPostToFacebookUsingWineObject:(unWine *)wineObject;

/*! Track new Checkins
 \param checkinObject REQUIRED. The new Checkin object
 */
+ (void)trackNewCheckinUsingNewsFeedObject:(PFObject *)checkinObject;

/*! Track Account Deletions
 */
+ (void)trackAccountDeletions;

/*! Track new Friend Invite
 */
+ (void)trackNewFriendInviteWithUser:(User *)user;

/*! Track Unfriending
 */
+ (void)trackUserUnfriendedFriendWithUser:(User *)user;

/*! Track how many times Sobriety Game is opened by user
 */
+ (void)trackSobrietyGameOpens;





/*! Trach when a user edits the wine
 */
+ (void)trackUserEditedWine:(unWine *)wineObject;

/*! Trach when a user opens the scanner
 */
+ (void)trackUserOpenedScanner;

/*! Trach when a user scans a wine
 */
+ (void)trackUserScannedWine;

/*! Trach when a user searches a wine
 */
+ (void)trackUserSearchedWine:(NSString *)searchString;

/*! Trach when a user selects a wine after doing a wine search
 */
+ (void)trackUserSelectedWineFromResults: (unWine *)wineObject andSearchString:(NSString *)searchString;

/*! Trach when a user merges two or more wines
 */
+ (void)trackUserMergedWine:(unWine *)wineObject;

/*! Trach when a user last login
 */
+ (void)trackLastLogin;

// Timed Transactions
/*! Start tracking timing of Post to Facebook transaction
 \param wineObject REQUIRED. The wine object that was posted to facebook
 \warning You must call stopTrackingPostToFacebookTransactionUsingWineObject: to stop tracking the length of this transaction
 */
+ (void)startTrackingPostToFacebookTransactionUsingWineObject:(unWine *)wineObject;

/*! Stop tracking timing of Post to Facebook transaction
 \param wineObject REQUIRED. The wine object that was posted to facebook
 */
+ (void)stopTrackingPostToFacebookTransactionUsingWineObject:(unWine *)wineObject;

/*! Tracks user Demographics used by the different Analytics SDKs (Flurry, Appboy, Splunk Mint)
 */
+ (void)trackUserDemographics;

/* Track Guest Login with Existing unWine Account
 */
+ (void)trackGuestLogIn;

/*! Tracks Guest Sign Up
 */
+ (void)trackGuestSignUp;

/*! Track Guest Login with Existing unWine Facebook Account
 */
+ (void)trackGuestLogInFacebook;

/*! Tracks Guest Sign Up via Facebook
 */
+ (void)trackGuestSignUpFacebook;

/*! Track Guest Login with Existing unWine Twitter Account
 */
+ (void)trackGuestLogInTwitter;

/*! Tracks Guest Sign Up via Twitter
 */
+ (void)trackGuestSignUpTwitter;


/*! Tracks users cancelling registration
 */
+ (void)trackUserCancelledRegistration;


/*! Track filter user checkedInWith
 */
+ (void)trackFilterCheckin:(NSString *)filter;

/*! Track grapes awarding
 */
+ (void)trackUserWasAwardedGrapes:(NSInteger)grapesAmount forReason:(NSString *)reason;


/*! Track wine sharing
 */
+ (void)trackUserSharedWine:(unWine *)wine withFriends:(NSInteger)nFriends;


/*! Track checkin sharing
 */
+ (void)trackUserSharedCheckin:(NewsFeed *)checkin withFriends:(NSInteger)nFriends;


/*! Trach checkin source
 */
+ (void)trackCheckInSource:(CastCheckinSource)source;

/*! Track Navigation/Tab Bar taps
 */
+ (void)trackActivityForTarget:(id)target;

/*! This is to leave trails of what the apps has been doing prior to a crash.
 \warning This works only for Splunk Mint. The crash log tracks the latest 16 breadcrumbs prior to a crash
 */
+ (void)leaveBreadcrumb:(NSString *)name;

/*! Clears the global breadcrumb list
 */
+ (void)clearBreadcrumb;

/*!
 \param errorName REQUIRED. The name of the error
 \param errorMessage REQUIRED. Error name/description
 \param exception REQUIRED. The caught exception
 \param functionName REQUIRED. This is so we know where this error came from. Use [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] to get the function name and its class AUTOMATICALLY.
 */
+ (void)trackError:(NSError *)error withName:(NSString *)name withMessage:(NSString *)message;
+ (void)trackException:(NSException *)exception withName:(NSString *)name andMessage:(NSString *)message;


+ (NSDictionary *)getDimensionsForUser;

@end
