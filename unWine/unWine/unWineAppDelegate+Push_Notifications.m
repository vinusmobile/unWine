//
//  unWineAppDelegate+Push_Notifications.m
//  unWine
//
//  Created by Fabio Gomez on 2/13/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWineAppDelegate+Push_Notifications.h"
#import "unWineAppDelegate+URL_Handling.h"
#import <Parse/Parse.h>
#import "Appboy.h"
#import "Analytics.h"
#import "Analytics+Wrappers.h"
#import "ParseSubclasses.h"
#import "MessengerVC.h"
#import "CommentVC.h"
#import <Bolts/Bolts.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation unWineAppDelegate (Push_Notifications)

- (void)registerForPushNotificationsUsingApplication:(UIApplication *)application{
    // Register for Push Notitications, if running iOS 8
    //if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    
    // iOS 10 Push notification stuff
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        LOGGER(@"Registering push notifications using iOS 10 method");
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if (!error) {
                LOGGER(@"Registering push notifications iOS 10!");
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            } else {
                NSString *errstr = [NSString stringWithFormat:@"iOS 10: Something happened: %@", error];
                LOGGER(errstr);
            }
        }];
    } else {
        LOGGER(@"Registering push notifications using iOS 8 method");
        // iOS 8 Push notification stuff
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    /*} else {
     // Register for Push Notifications before iOS 8
     [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound)];
     }*/
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"********** %s **********", __PRETTY_FUNCTION__);
    
    [self _saveInstallation:deviceToken]; //Cant query installations on Client, need cloud function. temporary replacement
    [Intercom setDeviceToken:deviceToken];
    
    /*PFQuery *query = [PFInstallation query];
     [query whereKey:@"deviceToken" equalTo:[self _convertDeviceTokenToString:deviceToken]];
     [[query findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
     if(task.error)
     LOGGER(task.error);
     
     if(!task.result || [task.result count] == 0) {
     return [[PFInstallation clearCurrentInstallationAsync] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
     return [self _saveInstallation:deviceToken];
     }];
     } else {
     return [self _saveInstallation:deviceToken];
     }
     
     return nil;
     }];*/
    
    LOGGER(@"Saving device token");
    self.deviceToken = deviceToken;
}

- (NSString *)_convertDeviceTokenToString:(id)deviceToken {
    if ([deviceToken isKindOfClass:[NSString class]]) {
        return deviceToken;
    } else {
        NSMutableString *hexString = [NSMutableString string];
        const unsigned char *bytes = [deviceToken bytes];
        for (int i = 0; i < [deviceToken length]; i++) {
            [hexString appendFormat:@"%02x", bytes[i]];
        }
        return [NSString stringWithString:hexString];
    }
}

- (BFTask *)_saveInstallation:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSLog(@"deviceToken - %@", deviceToken);
    [currentInstallation setObject:GET_UNWINE_VERSION forKey:@"version"];
    
    if([User currentUser])
        [currentInstallation setObject:[User currentUser] forKey:@"user"];
    
    return [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *errstr = [NSString stringWithFormat:@"Something happened: %@", error];
    LOGGER(errstr);
}


#pragma mark - Push Notification Payload Handling

/*- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
 LOGGER(@"inactive state0");
 // Pass on
 [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
 LOGGER(@"inactive state4");
 }];
 }*/

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    NSString *str = [NSString stringWithFormat:@"user info: %@", notification.request.content.userInfo];
    LOGGER(str);
    
    [self handlePushWithApp:[UIApplication sharedApplication]
                   userInfo:notification.request.content.userInfo
          completionHandler:completionHandler
         notificationCenter:center
                andResponse:nil];
    
    completionHandler(UNNotificationPresentationOptionNone);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    //Called to let your app know which action was selected by the user for a given notification.
    @try {
        NSString *str = [NSString stringWithFormat:@"Receiving notification iOS 10+ %@", response.notification.request.content.userInfo];
        LOGGER(str);
        [self handlePushWithApp:[UIApplication sharedApplication]
                       userInfo:response.notification.request.content.userInfo
              completionHandler:completionHandler
             notificationCenter:center
                    andResponse:response];
        
    } @catch (NSException *exception) {
        NSString *errstr = [NSString stringWithFormat:@"Something happened: %@", exception];
        LOGGER(errstr);
    }
}

- (void)handlePushWithApp:(UIApplication *)application
                 userInfo:(NSDictionary *)userInfo
        completionHandler:(void (^)())completionHandler
       notificationCenter:(UNUserNotificationCenter *)center
              andResponse:(UNNotificationResponse *)response {
    
    //LOGGER(@"Enter");
    
    self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
    self.application = [UIApplication sharedApplication];
    
    NSLog(@"%s - userInfo = %@", __PRETTY_FUNCTION__, self.userInfo);
    NSLog(@"%s - userInfo[type] = %@", __PRETTY_FUNCTION__, self.userInfo[@"type"]);
    //NSLog(@"%s - userInfo[type] = %@", __PRETTY_FUNCTION__, [Push getNotificationNameWithUserInfo:userInfo]);
    //self.userInfo = [NSDictionary dictionaryWithDictionary:userInfo];
    
    // Track App Opens
    if (application.applicationState == UIApplicationStateActive) {
        // Show Overhead alert here
        // Maybe show user voice slide up here and perform the app linking here
        //[self showAlertForPushNotificationWithUserInfo:userInfo];
        
        NSString *url = self.userInfo[@"url"] ? self.userInfo[@"url"] : self.userInfo[@"ab_uri"];
        
        if (!url) {
            url = self.userInfo[@"aps"][@"url"];
        }
        
        LOGGER(userInfo);
        
        if ([Intercom isIntercomPushNotification:userInfo]) {
            LOGGER(@"Intercom push notification while app is active");
            [Intercom handleIntercomPushNotification:userInfo];
    
        } else if(ISVALID(url)) {
            NSURL *alertURL = [NSURL URLWithString:url];
            MessengerVC *mess = self.ctbc.messenger;
            LOGGER(@"has URL");
            LOGGER(mess);
            
            if(mess && [mess isActive]) {
                BFURL *parsedUrl = [BFURL URLWithURL:alertURL];
                LOGGER(@"detected push, while viewing conversation");
                
                if([parsedUrl.targetURL.host isEqualToString:@"conversation"]) {
                    NSString *objectId = [parsedUrl.targetURL.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    
                    if([mess.convo.objectId isEqualToString:objectId]) {
                        LOGGER(@"and it was the same conversation you're watching, reload that shit!");
                        [self.ctbc.messenger activeReload];
                        return;
                    }
                } else if([parsedUrl.targetURL.host isEqualToString:@"vinecast"] && [mess isKindOfClass:[CommentVC class]]) {
                    CommentVC *comm = (CommentVC *)mess;
                    NSString *objectId = [parsedUrl.targetURL.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    
                    if([comm.newsfeed.objectId isEqualToString:objectId]) {
                        LOGGER(@"and it was the same vinecast convo you're watching, reload that shit!");
                        [self.ctbc.messenger activeReload];
                        return;
                    }
                }
            }
            
            if([[self.userInfo allKeys] containsObject:@"aps"] && [[self.userInfo[@"aps"] allKeys] containsObject:@"alert"])
                [self.ctbc showCustomSlideUpWithMessage:self.userInfo[@"aps"][@"alert"] andURL:alertURL];
        } else {
            LOGGER(@"No URL");
            
            if([[self.userInfo allKeys] containsObject:@"aps"] && [[self.userInfo[@"aps"] allKeys] containsObject:@"alert"])
                [self.ctbc showCustomSlideUpWithMessage:self.userInfo[@"aps"][@"alert"] andURL:nil];
        }
    } else if (application.applicationState == UIApplicationStateInactive) {
        NSTimeInterval initial = TIME_STAMP;
        
        LOGGER(@"Analytics could be on the main thread...");
        [Analytics trackPushNotificationReceivedWithUserInfo:userInfo
                                              andApplication:application
                                   andFetchCompletionHandler:completionHandler
                                          notificationCenter:center
                                                 andResponse:response];
        NSLog(@"delay caused by activateApp %@ms, handling url", @(TIME_STAMP - initial));
        initial = TIME_STAMP;

        if ([Intercom isIntercomPushNotification:userInfo]) {
            LOGGER(@"Intercom push notification while app is inactive");
            [Intercom handleIntercomPushNotification:userInfo];
        } else {
            [[MainVC sharedInstance] enqueueProtocolURL:self.userInfo];
        }

        NSLog(@"delay caused by handleProtocolURL %@ms, post handling url", @(TIME_STAMP - initial));
        /*dispatch_async(dispatch_get_main_queue(), ^{
         [self handleProtocolURL:self.userInfo];
         });*/
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    LOGGER(@"Receiving notification Pre iOS 10");
    [self handlePushWithApp:application
                   userInfo:userInfo
          completionHandler:completionHandler
         notificationCenter:nil
                andResponse:nil];
    
    completionHandler(UIBackgroundFetchResultNoData);
}


@end
