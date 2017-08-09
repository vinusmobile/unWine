//
//  Analytics.m
//  unWine
//
//  Created by Fabio Gomez on 1/14/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Analytics.h"
#import "Analytics+Wrappers.h"
#import "ParseSubclasses.h"
#import <Crashlytics/Crashlytics.h>

//#define APPBOY

#define FLURRY_RETURN_IF_NOT_PRODUCTION_OR_SIMULATOR if(((unWineAppDelegate *)[[UIApplication sharedApplication] delegate]).environment != PRODUCTION || TARGET_IPHONE_SIMULATOR) { NSLog(@"***** Flurry - Can't execute method %s. Must be running actual device with Production Database *****", FUNCTION_NAME); return;}

@implementation Analytics

# pragma mark - Analytics for Specific events

+ (void)trackGenericEvent:(NSString *)event {
    [self trackEvent:event withDimensions:[Analytics getDimensionsForUser]];

    NSString *string = [NSString stringWithFormat:@"Just Tracked %@", event];
    LOGGER(string);
}

/*
+ (void)trackAppOpensUsingApplication:(UIApplication *)application andLaunchOptions:(NSDictionary *)launchOptions andUserInfo:(NSDictionary *)userInfoDictionary{
    // Track Application opens and push-related open rates. This will be available on unWine's Dashboard
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        NSDictionary *userInfo = userInfoDictionary;

        // Double checking
        if (!userInfo && launchOptions) {
            userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
        
        if (preBackgroundPush || oldPushHandlerOnly || !userInfo) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
            LOGGER(@"Just Tracked App Open");
        } else if (userInfo) {
            [[Appboy sharedInstance] registerApplication:application didReceiveRemoteNotification:userInfo];
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            
            NSString *event = [NSString stringWithFormat:@"UserOpened%@PushNotification", [Push getNotificationTypeName:(NotificationType)userInfo[@"type"]]];
            [self trackEvent:event withDimensions:[Analytics getDimensionsForUser]];
            
            NSString *string = [NSString stringWithFormat:@"Just Tracked %@", event];
            LOGGER(string);
        }
    
    }
    
}*/

+ (void)trackAppLaunchwithLaunchOptions:(NSDictionary *)launchOptions {
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Analytics trackLastLogin];
}

+ (void)trackPushNotificationReceivedWithUserInfo:(NSDictionary *)userInfo
                                   andApplication:(UIApplication *)application
                        andFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
                               notificationCenter:(UNUserNotificationCenter *)center
                                      andResponse:(UNNotificationResponse *)response {
    
    if (center && response) {
        [[Appboy sharedInstance] userNotificationCenter:center
                         didReceiveNotificationResponse:response
                                  withCompletionHandler:completionHandler];
    } else {
        [[Appboy sharedInstance] registerApplication:application
                        didReceiveRemoteNotification:userInfo
                              fetchCompletionHandler:completionHandler];
    }
    
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    
    NSString *event = @"";
    
    if ([Intercom isIntercomPushNotification:userInfo]) {
        event = @"UserOpenedIntercomPushNotification";
    } else if ([[Appboy sharedInstance] pushNotificationWasSentFromAppboy:userInfo] == NO) {
        event = [NSString stringWithFormat:@"UserOpened%@PushNotification", [Push getNotificationNameWithUserInfo:userInfo]];
    } else if (ISVALID(userInfo[@"ab_uri"]) && [userInfo[@"ab_uri"] isEqualToString:@"unwineapp://newsfeed"]) {
        event = @"UserOpenedDailyToastPushNotification";
    } else if (userInfo[@"ab"]) {
        event = @"UserOpenedAppboyPushNotification";
    } else {
        event = @"UserOpenedRandomPushNotification";
    }
    
    NSString *string = [NSString stringWithFormat:@"About to track %@", event];
    LOGGER(string);
    
    [Analytics trackEvent:event withDimensions:[Analytics getDimensionsForUser]];
    
    string = [NSString stringWithFormat:@"Just Tracked %@", event];
    LOGGER(string);
}

+ (void)trackPostToFacebookUsingWineObject:(unWine *)wineObject{
    NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
    [self trackEvent:EVENT_POST_TO_FACEBOOK withDimensions:dimensions];
    LOGGER(@"Just Tracked Posting to Facebook");
}

+ (void)trackNewCheckinUsingNewsFeedObject:(NewsFeed *)checkin {
    unWine *wineObject = checkin.unWinePointer;
    if(wineObject) {
        NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
        
        [self trackEvent:EVENT_NEW_CHECKIN_CREATED withDimensions:dimensions];
        LOGGER(@"Just Tracked New Checkin");
    } else {
        LOGGER(@"Tried to track New Checkin, something is broken");
    }
}

+ (void)trackAccountDeletions {
    [self trackEvent:EVENT_ACCOUNT_DELETION withDimensions:nil];
    LOGGER(@"Just Tracked Account Deletion");
}

+ (void)trackNewFriendInviteWithUser:(User *)user {
    NSDictionary *dimensions = [self getDimensionsForReceivingUser:user];
    
    [self trackEvent:EVENT_NEW_FRIEND_INVITE withDimensions:dimensions];
    LOGGER(@"Just Tracked New Friend Invite");
}

+ (void)trackUserUnfriendedFriendWithUser:(User *)user {
    NSDictionary *dimensions = [self getDimensionsForReceivingUser:user];
    
    [self trackEvent:EVENT_USER_UNFRIENDED_FRIEND withDimensions:dimensions];
    LOGGER(@"Just Tracked Unfriending");
}

+ (void)trackSobrietyGameOpens {
    NSDictionary *dimensions = [self getDimensionsForUser];
    
    [self trackEvent:EVENT_SOBRIETY_GAME_OPEN withDimensions:dimensions];
    LOGGER(@"Just Tracked New Sobriety Game Open");
}




////

+ (void)trackUserEditedWine:(unWine *)wineObject {
    NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
    
    [self trackEvent:EVENT_USER_EDITED_WINE withDimensions:dimensions];
    LOGGER(@"Just Tracked User Editing a Wine");
}

+ (void)trackLastLogin {
    User *user = [User currentUser];
    if(user != nil && [user isDataAvailable]) {
        NotificationsSetting setting = [user getNotificationStatus:NotificationTypeDailyToast];
        [[Appboy sharedInstance].user setEmailNotificationSubscriptionType:(setting == NotificationsSettingOn) ? ABKOptedIn : ABKUnsubscribed];
        [[Appboy sharedInstance].user setPushNotificationSubscriptionType:(setting == NotificationsSettingOn) ? ABKOptedIn : ABKUnsubscribed];
        
        user.lastLogin = [NSDate date];
        user.timezone = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        user.version = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        [user saveInBackground];
    }
}

+ (void)trackUserOpenedScanner {
    NSDictionary *dimensions = [self getDimensionsForUser];
    
    [self trackEvent:EVENT_OPENED_SCANNER withDimensions:dimensions];
    LOGGER(@"Just Tracked User Opened Scanner");
}

+ (void)trackUserScannedWine {
    NSDictionary *dimensions = [self getDimensionsForUser];
    
    [self trackEvent:EVENT_SCANNED_WINE withDimensions:dimensions];
    LOGGER(@"Just Tracked User Scanned a Wine");
}

+ (void)trackUserSearchedWine:(NSString *)searchString {
    NSDictionary *dimensions = [self getDimensionsForSearchedWine:searchString == nil ? @"" : searchString];
    
    [self trackEvent:EVENT_SEARCHED_WINE withDimensions:dimensions];
    LOGGER(@"Just Tracked User Searched a Wine");
}

+ (void)trackUserSelectedWineFromResults: (unWine *)wineObject andSearchString:(NSString *)searchString {
    NSDictionary *dimensions = [self getDimensionsForSelectedWine:wineObject andSearchString:searchString];
    
    [self trackEvent:EVENT_SELECTED_WINE_FROM_SEARCH_RESULTS withDimensions:dimensions];
    LOGGER(@"Just Tracked User Selecting a Wine from Search Results");
}

+ (void)trackUserMergedWine:(unWine *)wineObject {
    NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
    
    [self trackEvent:EVENT_USER_MERGED_WINE withDimensions:dimensions];
    LOGGER(@"Just Tracked User Merging a Wine");
}



#pragma mark - Timed Transactions

+ (void)startTrackingPostToFacebookTransactionUsingWineObject:(unWine *)wineObject {
    NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
    
    [self startTrackingTimedEvent:EVENT_POST_TO_FACEBOOK withDimensions: dimensions];
}

+ (void)stopTrackingPostToFacebookTransactionUsingWineObject:(unWine *)wineObject {
    NSDictionary *dimensions = [self getDimensionsForWineObject:wineObject];
    
    [self stopTrackingTimedEvent:EVENT_POST_TO_FACEBOOK withDimensions:dimensions];
}

#pragma mark - User Demographics

+ (void)trackUserDemographics {
    User *user = [User currentUser];
    NSString *lastName = [user getLastName];
    int age = [user getAge];
    NSDate *birthday = [user getDateOfBirth];
    NSString *gender = [user getGender];
    NSString *profileURL = [user getProfileImageURL];
    
    // Flurry
    [Flurry setUserID:user.objectId];
    if (age > 0) {
        [Flurry setAge:age];
    }
    if (gender) {
        [Flurry setGender:[gender isEqualToString:@"male"] ? @"m" : @"f"];
    }
    
    // Appboy stuff goes here
    [APPBOY changeUser:user.objectId];
    if (!APPBOY.user.firstName) {
        APPBOY.user.firstName = [user getFirstName];
    }
    if (!APPBOY.user.lastName && lastName) {
        APPBOY.user.lastName = [user getLastName];
    }
    if (!APPBOY.user.email) {
        APPBOY.user.email = user.email;
    }
    if (gender) {
        [APPBOY.user setGender:[gender isEqualToString:@"male"] ? ABKUserGenderMale : ABKUserGenderFemale];
    }
    if (!APPBOY.user.dateOfBirth && birthday) {
        APPBOY.user.dateOfBirth = birthday;
    }
    if (!APPBOY.user.avatarImageURL && profileURL) {
        APPBOY.user.avatarImageURL = profileURL;
    }
    
    if ([user hasFacebook]) {
        [[User getFacebookUserData] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if (t.error) {
                LOGGER(@"Could not init AppBoy with Facebook User");
                LOGGER(t.error.localizedDescription);
            } else {
                LOGGER(@"Initializing AppBoy with Facebook User");
                ABKFacebookUser *facebookUser = [[ABKFacebookUser alloc] initWithFacebookUserDictionary:t.result numberOfFriends:-1 likes:nil];
                APPBOY.user.facebookUser = facebookUser;
                LOGGER(facebookUser.facebookUserDictionary);
            }
            
            return nil;
        }];
        
    } else if ([user hasTwitter]) {
        [[User getTwitterUserData] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if (t.error) {
                LOGGER(@"Could not init AppBoy with Twitter User");
                LOGGER(t.error.localizedDescription);
            } else {
                LOGGER(@"Initializing AppBoy with Twitter User");
                NSDictionary *tdata = (NSDictionary *)t.result;
                
                ABKTwitterUser *twitterUser = [[ABKTwitterUser alloc] init];
                twitterUser.userDescription = tdata[@"description"];
                twitterUser.twitterID = [tdata[@"id"] integerValue];
                twitterUser.twitterName = tdata[@"name"];
                twitterUser.profileImageUrl = tdata[@"profile_image_url"];
                twitterUser.screenName = tdata[@"screen_name"];
                twitterUser.followersCount = [tdata[@"followers_count"] integerValue];
                twitterUser.friendsCount = [tdata[@"friends_count"] integerValue];
                twitterUser.statusesCount = [tdata[@"statuses_count"] integerValue];
                
                APPBOY.user.twitterUser = twitterUser;
                LOGGER(APPBOY.user.twitterUser.userDescription);
                NSString *s = [NSString stringWithFormat:@"%li", APPBOY.user.twitterUser.twitterID];
                LOGGER(s);
            }
            
            return nil;
        }];
    
    } else {
        NSLog(@"%s - Just tracked user demographics", __PRETTY_FUNCTION__);
    }
    
}


#pragma mark - Guest Analytics

+ (void)trackGuestLogIn {
    [self trackEvent:EVENT_GUEST_LOGIN withDimensions:nil];
    LOGGER(@"Just Tracked Guest Login with Existing account");
}

+ (void)trackGuestSignUp {
    [self trackEvent:EVENT_GUEST_SIGNED_UP withDimensions:nil];
    LOGGER(@"Just Tracked Guest Sign Up");
}

+ (void)trackGuestLogInFacebook {
    [self trackEvent:EVENT_GUEST_LOGIN_FACEBOOK withDimensions:nil];
    LOGGER(@"Just Tracked Guest Login with Existing account with Facebook");
}

+ (void)trackGuestSignUpFacebook {
    [self trackEvent:EVENT_GUEST_SIGNED_UP_FACEBOOK withDimensions:nil];
    LOGGER(@"Just Tracked Guest Sign Up using Facebook");
}

+ (void)trackGuestLogInTwitter {
    [self trackEvent:EVENT_GUEST_LOGIN_TWITTER withDimensions:nil];
    LOGGER(@"Just Tracked Guest Login with Existing account with Twitter");
}

+ (void)trackGuestSignUpTwitter {
    [self trackEvent:EVENT_GUEST_SIGNED_UP_TWITTER withDimensions:nil];
    LOGGER(@"Just Tracked Guest Sign Up using Twitter");
}


#pragma mark - Registration
+ (void)trackUserCancelledRegistration {
    [self trackEvent:EVENT_USER_CANCELLED_REGISTRATION withDimensions:nil];
    LOGGER(@"Just Tracked User CancelledRegistration");
}

#pragma mark - Track Navigation/Tab Bar taps

+ (void)trackActivityForTarget:(id)target{
    // Track User Interactions. Hopefully this is all it needs to track user activity after login
    [Flurry logAllPageViewsForTarget:target];
    
    LOGGER(@"Tracking User Activity on Navigation/Tab Controller");
}

#pragma mark - Filters

+ (NSString *)getAnalyticsNameForFilter:(NSString *)filter {
    return [NSString stringWithFormat:@"%@%@", EVENT_FILTERS_USER_CHECKED_IN_USING_FILTER_X, [filter stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

+ (void)trackFilterCheckin:(NSString *)filter {
    [self trackGenericEvent:[Analytics getAnalyticsNameForFilter:filter]];
    [self trackGenericEvent:EVENT_FILTERS_USER_CHECKED_IN_USING_FILTER_X]; // To track filters usage overall
}

#pragma mark - Grapes
+ (void)trackUserWasAwardedGrapes:(NSInteger)grapesAmount forReason:(NSString *)reason {
    NSString *event = [NSString stringWithFormat:@"%@%@", EVENT_USER_WAS_AWARDED_GRAPES, reason];
    
    [self trackEvent:event withDimensions:[Analytics getDimensionsForGrapes:grapesAmount]];
    
    NSString *string = [NSString stringWithFormat:@"Just Tracked %@", event];
    LOGGER(string);
}

#pragma mark - Wine sharing
+ (void)trackUserSharedWine:(unWine *)wine withFriends:(NSInteger)nFriends {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForWineObject:wine]];

    dimensions[@"numberOfUsersWineWasSharedWith"] = [NSString stringWithFormat:@"%li", (long)nFriends];

    [self trackEvent:EVENT_USER_SHARED_WINE_INTERNALLY withDimensions:dimensions];

    NSString *string = [NSString stringWithFormat:@"Just Tracked %@", EVENT_USER_SHARED_WINE_INTERNALLY];
    LOGGER(string);
}

+ (void)trackUserSharedCheckin:(NewsFeed *)checkin withFriends:(NSInteger)nFriends {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForCheckinObject:checkin]];

    NSString *event = [checkin userIsEqualToAuthor:[User currentUser]] ? EVENT_USER_SHARED_OWN_CHECKIN_INTERNALLY: EVENT_USER_SHARED_SOMEONE_CHECKIN_INTERNALLY;

    dimensions[@"numberOfUsersCheckinWasSharedWith"] = [NSString stringWithFormat:@"%li", (long)nFriends];

    [self trackEvent:event withDimensions:dimensions];

    NSString *string = [NSString stringWithFormat:@"Just Tracked %@", event];
    LOGGER(string);
}

+ (void)trackCheckInSource:(CastCheckinSource)source {
    NSString *sourceString = @"";
    
    switch (source) {
        case CastCheckinSourceVinecast:
            sourceString = @"VineCast";
            break;
            
        case CastCheckinSourceWishList:
            sourceString = @"WishList";
            break;
            
        case CastCheckinSourceInbox:
            sourceString = @"Inbox";
            break;
            
        case CastCheckinSourcePushNotification:
            sourceString = @"PushNotification";
            break;
            
        case CastCheckinSourceUnique:
            sourceString = @"UniqueWines";
            break;
            
        case CastCheckinSourceExpress:
            sourceString = @"Express";
            break;
            
        default:
            sourceString = @"Somewhere";
            break;
    }
    
    NSString *wholeEvent = [NSString stringWithFormat:@"%@%@", EVENT_USER_CHECKED_IN_FROM, sourceString];
    
    ANALYTICS_TRACK_EVENT(wholeEvent);
}

#pragma mark - Track Error

+ (void)trackError:(NSError *)error withName:(NSString *)name withMessage:(NSString *)message {
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc] init];
    dimensions[@"errorName"] = name;
    dimensions[@"errorMessage"] = message;
    
    [CrashlyticsKit recordError:error withAdditionalUserInfo:dimensions];
    [Flurry logError:name message:message error:error];
}

+ (void)trackException:(NSException *)exception withName:(NSString *)name andMessage:(NSString *)message {
    [Flurry logError:name message:message exception:exception];
}

#pragma mark - Helpers

+ (NSDictionary *)getDimensionsForUser {
    User *user = [User currentUser];
    
    NSDictionary *dimensions = @{
                                 @"userId"      : user.objectId,
                                 @"userName"    : [user isAnonymous] ? @"Anonymous" : [user getName]
                                 };
    return dimensions;
}

+ (NSDictionary *)getDimensionsForReceivingUser:(User *)user {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForUser]];
    
    [dimensions addEntriesFromDictionary: @{
                                            @"receivingUserId"      : user.objectId,
                                            @"receivingUserIdName"  : [user getName]
                                            }];
    
    return dimensions;
}

+ (NSDictionary *)getDimensionsForCheckinObject:(NewsFeed *)checkin {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForWineObject:checkin.unWinePointer]];

    [dimensions addEntriesFromDictionary: @{
                                            @"checkinID"   : checkin.objectId
                                            }];

    return dimensions;
}

+ (NSDictionary *)getDimensionsForWineObject:(unWine *)wineObject {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForUser]];
    
    [dimensions addEntriesFromDictionary: @{
                                            @"wineId"      : wineObject.objectId,
                                            @"wineName"    : [wineObject getWineName],
                                            @"wineClass"   : wineObject.parseClassName
                                            }];
    
    return dimensions;
}

+ (NSDictionary *)getDimensionsForSearchedWine:(NSString *)searchString {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForUser]];
    
    [dimensions addEntriesFromDictionary: @{
                                            @"searchedWine": searchString
                                            }];
    
    return dimensions;
}

+ (NSDictionary *)getDimensionsForSelectedWine:(unWine *)wineObject andSearchString:(NSString *)searchString {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForWineObject:wineObject]];
    
    [dimensions addEntriesFromDictionary: @{
                                            @"searchedWine": searchString
                                            }];
    
    return dimensions;
}

+ (NSDictionary *)getDimensionsForGrapes:(NSInteger) grapesAmount {
    NSMutableDictionary *dimensions = [NSMutableDictionary dictionaryWithDictionary:[Analytics getDimensionsForUser]];
    
    [dimensions addEntriesFromDictionary: @{
                                            @"grapesAwarded": [NSString stringWithFormat:@"%li", (long)grapesAmount]
                                            }];
    
    return dimensions;
}


@end
