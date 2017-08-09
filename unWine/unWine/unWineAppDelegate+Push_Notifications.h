//
//  unWineAppDelegate+Push_Notifications.h
//  unWine
//
//  Created by Fabio Gomez on 2/13/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWineAppDelegate.h"

@interface unWineAppDelegate (Push_Notifications)
- (void)registerForPushNotificationsUsingApplication:(UIApplication *)application;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
