//
//  unWineAppDelegate+URL_Handling.m
//  unWine
//
//  Created by Fabio Gomez on 2/13/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWineAppDelegate+URL_Handling.h"
#import "unWineAppDelegate+Push_Notifications.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <Bolts/Bolts.h>
#import <Branch/Branch.h>
#import "ParseSubclasses.h"

#define URL_FACEBOOK_APP @"com.facebook.Facebook" /*@"fb160086400862780"*/
#define URL_FACEBOOK_SAFARI @"com.apple.SafariViewService"

@implementation unWineAppDelegate (URL_Handling)

#pragma mark - Handle URL

static NSTimeInterval lastTimeStamp = 0;

- (void)handleProtocolURL:(NSDictionary *)notification {
    LOGGER(notification);
    
    // Sanity Check to prevent segues when user is not logged in
    if (![User currentUser]) {
        NSLog(@"%s - User must be logged in", __PRETTY_FUNCTION__);
        return ;
    }
    
    if (notification && ([[notification allKeys] containsObject:@"url"] || [[notification allKeys] containsObject:@"ab_uri"])) {
        NSString *url = [[notification allKeys] containsObject:@"url"] ? notification[@"url"] : notification[@"ab_uri"];
        if(ISVALID(url)) {
            NSString *urlLink = [NSString stringWithFormat:@"%@", url];
            NSURL *url = [NSURL URLWithString:urlLink];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[UIApplication sharedApplication] openURL:url]) {
                    NSLog(@"Failed to open url:%@", [url description]);
                }
            });
        }
    }
}

/*- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}*/

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"********** %s - Handling URL **********", __PRETTY_FUNCTION__);
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    //NSString *firstPathComponent = [parsedUrl.targetURL.pathComponents objectAtIndex:1];
    
    NSLog(@"Source              = %@", sourceApplication);
    NSLog(@"Scheme              = %@", parsedUrl.targetURL.scheme);
    NSLog(@"Host                = %@", parsedUrl.targetURL.host);
    NSLog(@"Path                = %@", parsedUrl.targetURL.path);
    
    /*NSLog(@"Resource Specifier  = %@", parsedUrl.targetURL.resourceSpecifier);
    NSLog(@"Path                = %@", parsedUrl.targetURL.path);
    NSLog(@"Path Components     = %@", parsedUrl.targetURL.pathComponents);
    NSLog(@"Last Path Component = %@", parsedUrl.targetURL.lastPathComponent);
    NSLog(@"Parameter String    = %@", parsedUrl.targetURL.parameterString);
    NSLog(@"Query               = %@", parsedUrl.targetURL.query);*/
    
    // pass the url to the handle deep link call
    [[Branch getInstance]
     application:application
     openURL:url
     sourceApplication:sourceApplication
     annotation:annotation];
    
    if ([sourceApplication isEqualToString:URL_FACEBOOK_APP] ||
        //[sourceApplication isEqualToString:URL_FACEBOOK_SAFARI] ||
        [parsedUrl.targetURL.host isEqualToString:@"authorize"] ||
        [parsedUrl.targetURL.host isEqualToString:@"bridge"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                
                                                              openURL:url
                
                                                    sourceApplication:sourceApplication
                
                                                           annotation:annotation];
        
    }
    
    // Sanity Check to prevent segues when user is not logged in
    if (![User currentUser]) {
        NSLog(@"%s - User must be logged in", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if([parsedUrl.targetURL.scheme isEqualToString:@"unwineapp"]) {
        /*if(TIME_STAMP > lastTimeStamp + 3000)
            return NO;
        
        lastTimeStamp = TIME_STAMP;*/
        
        if ([parsedUrl.targetURL.host isEqualToString:@"feedback"]) {
            [self.ctbc showUserVoice];
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_FEEDBACK_POP_UP_AND_SAW_FEEDBACK_VIEW);
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"inbox"]) {
            [self.ctbc setSelectedIndex:INBOX_TAB_INDEX];
            [self.ctbc showAppBoyNewsFeed:CastInboxDefaultNotification];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"newsfeed"]) {
            [self.ctbc setSelectedIndex:INBOX_TAB_INDEX];
            [self.ctbc showAppBoyNewsFeed:CastInboxDefaultDailyToast];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"conversation"]) {
            LOGGER(self.window.rootViewController);
            if(self.ctbc.isViewLoaded && self.ctbc.view.window && ![self.ctbc.tabBar isHidden]) {
                [self.ctbc showConversationWith:parsedUrl.targetURL.path useRootVC:NO];
            } else {
                [self.ctbc showConversationWith:parsedUrl.targetURL.path useRootVC:YES];
                NSLog(@"conversation - tabbar out of view");
            }
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"vinecast"]) {
            NSLog(@"%@", self.window.rootViewController);
            if(self.ctbc.isViewLoaded && self.ctbc.view.window && ![self.ctbc.tabBar isHidden]) {
                [self.ctbc showVineCastWith:parsedUrl.targetURL.path useRootVC:NO];
            } else {
                [self.ctbc showVineCastWith:parsedUrl.targetURL.path useRootVC:YES];
                NSLog(@"vinecast - tabbar out of view");
            }
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"user"]) {
            NSLog(@"%@", self.window.rootViewController);
            if(self.ctbc.isViewLoaded && self.ctbc.view.window && ![self.ctbc.tabBar isHidden]) {
                [self.ctbc showProfileWith:parsedUrl.targetURL.path useRootVC:NO];
            } else {
                [self.ctbc showProfileWith:parsedUrl.targetURL.path useRootVC:YES];
                NSLog(@"user - tabbar out of view");
            }
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"wine"]) {
            NSLog(@"%@", self.window.rootViewController);
            if(self.ctbc.isViewLoaded && self.ctbc.view.window && ![self.ctbc.tabBar isHidden]) {
                [self.ctbc showWineWith:parsedUrl.targetURL.path useRootVC:NO];
            } else {
                [self.ctbc showWineWith:parsedUrl.targetURL.path useRootVC:YES];
                NSLog(@"wine - tabbar out of view");
            }
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"winery"]) {
            NSLog(@"%@", self.window.rootViewController);
            if(self.ctbc.isViewLoaded && self.ctbc.view.window && ![self.ctbc.tabBar isHidden]) {
                [self.ctbc showWineryWith:parsedUrl.targetURL.path useRootVC:NO];
            } else {
                [self.ctbc showWineryWith:parsedUrl.targetURL.path useRootVC:YES];
                NSLog(@"winery - tabbar out of view");
            }
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"clubw"]) {
            [self.ctbc showClubW];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"guestsignup"]) {
            //[self.ctbc promptGuest:[(GET_APP_DELEGATE)]];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"trendingwines"]) {
            [self.ctbc showTrendingWines];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"merits"]) {
            [self.ctbc showMerits];
        }
        
        if ([parsedUrl.targetURL.host isEqualToString:@"invitefriends"]) {
            [self.ctbc setSelectedIndex:PROFILE_TAB_INDEX];
            //[self.ctbc showInviteFriends];
        }
    }
    
    /*
    if ([parsedUrl.targetURL.host isEqualToString:@"sobrietytest"]) {
        [self.ctbc showSobrietyTest];
    }*/
    
    // Shouldn't really get here
    return NO;
}

@end
