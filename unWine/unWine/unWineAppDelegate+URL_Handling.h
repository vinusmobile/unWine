//
//  unWineAppDelegate+URL_Handling.h
//  unWine
//
//  Created by Fabio Gomez on 2/13/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWineAppDelegate.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface unWineAppDelegate (URL_Handling)
- (void)handleProtocolURL:(NSDictionary *)notification;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler;
@end
