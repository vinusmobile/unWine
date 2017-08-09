//
//  Push.m
//  unWine
//
//  Created by Fabio Gomez on 10/27/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Push.h"
#import "Friendship.h"
#import "User.h"

@implementation Push

+ (NSArray *)settings {
    static NSMutableArray * _settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _settings = [[NSMutableArray alloc] init];
        [_settings insertObject:NOTIFICATIONS_ON         atIndex:NotificationsSettingOn];
        [_settings insertObject:NOTIFICATIONS_EVERYERONE atIndex:NotificationsSettingEveryone];
        [_settings insertObject:NOTIFICATIONS_FRIENDS    atIndex:NotificationsSettingFriends];
        [_settings insertObject:NOTIFICATIONS_OFF        atIndex:NotificationsSettingOff];
    });
    
    return _settings;
}

+ (NSString *)settingName:(NotificationsSetting)setting {
    return [[self settings] objectAtIndex:setting];
}

+ (NSArray *)notifications {
    static NSMutableArray *_push = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _push = [[NSMutableArray alloc] init];
        [_push insertObject:[PushNotificationObject type:NotificationTypeComment
                                                   title:@"Comments"
                                                 options:@[@(NotificationsSettingEveryone), @(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeComment];
        [_push insertObject:[PushNotificationObject type:NotificationTypeToast
                                                   title:@"Toasts (Likes)"
                                                 options:@[@(NotificationsSettingEveryone), @(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeToast];
        [_push insertObject:[PushNotificationObject type:NotificationTypeMessage
                                                   title:@"Messages"
                                                 options:@[@(NotificationsSettingEveryone), @(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeMessage];
        [_push insertObject:[PushNotificationObject type:NotificationTypeCheckin
                                                   title:@"Checkins"
                                                 options:@[@(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeCheckin];
        [_push insertObject:[PushNotificationObject type:NotificationTypeDailyToast
                                                   title:@"Daily Toast"
                                                 options:@[@(NotificationsSettingOn), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeDailyToast];
        [_push insertObject:[PushNotificationObject type:NotificationTypeRecommendations
                                                   title:@"Wine Recommendations"
                                                 options:@[@(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeRecommendations];
        [_push insertObject:[PushNotificationObject type:NotificationTypeFriendInvites
                                                   title:@"Friend Invites"
                                                 options:@[@(NotificationsSettingOn), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeFriendInvites];
        [_push insertObject:[PushNotificationObject type:NotificationTypeMentions
                                                   title:@"Mentions"
                                                 options:@[@(NotificationsSettingEveryone), @(NotificationsSettingFriends), @(NotificationsSettingOff)]]
                    atIndex:NotificationTypeMentions];
    });
    
    return _push;
}

+ (PushNotificationObject *)notificationObject:(NotificationType)type {
    return [[self notifications] objectAtIndex:type];
}

+ (NSString *)notificationName:(NotificationType)type {
    return [[Push notificationObject:type] getName];
}

+ (NSString *)getNotificationNameWithUserInfo:(NSDictionary *)userInfo {
    return [[Push notificationName:(NotificationType)[userInfo[@"type"]integerValue]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (BOOL)isRegisteredForPushNotifications {
    UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    return (types & UIUserNotificationTypeAlert);
}

+ (BFTask *)sendPushNotification:(NotificationType)type toUser:(User *)user withMessage:(NSString *)message {
    return [Push sendPushNotification:(NotificationType)type toUser:user withMessage:message withURL:nil];
}

+ (BFTask *)sendPushNotification:(NotificationType)type toGroup:(BFTask *)group withMessage:(NSString *)message {
    return [Push sendPushNotification:(NotificationType)type toGroup:group withMessage:message withURL:nil];
}

+ (BFTask *)sendPushNotification:(NotificationType)type toGroup:(BFTask *)group withMessage:(NSString *)message withURL:(NSString *)url {
    return [group continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            NSMutableArray *groupTask = [[NSMutableArray alloc] init];
            
            NSArray *groupies = group.result;
            for(PFObject *member in groupies) {
                if([member.parseClassName isEqualToString:[Friendship parseClassName]]) {
                    Friendship *friendship = (Friendship *)member;
                    User *friend = [friendship getTheFriend:[User currentUser]];
                    [groupTask addObject:[Push sendPushNotification:type toUser:friend withMessage:message withURL:url]];
                } else if([member.parseClassName isEqualToString:[User parseClassName]]) {
                    [groupTask addObject:[Push sendPushNotification:type toUser:(User *)member withMessage:message withURL:url]];
                }
            }
            
            return [BFTask taskForCompletionOfAllTasksWithResults:groupTask];
        } else {
            LOGGER(task.error);
        }
        
        return nil;
    }];
}

+ (BFTask *)sendPushNotification:(NotificationType)type toUser:(User *)user withMessage:(NSString *)message withURL:(NSString *)url {
    //printf("\n\n\n**********\n");
    
    if (!ISVALID(message)) {
        LOGGER(@"Won't send Push Notification - Invalid Message");
        return [BFTask taskWithError:[unWineError createPushErrorWithMessage:@"No message provided."]];
    }
    
    if (!user || !ISVALID(user.objectId)) {
        LOGGER(@"Won't send Push Notification - No User");
        return [BFTask taskWithError:[unWineError createPushErrorWithMessage:@"No user provided."]];
    }
    
    return [[user canReceiveNotification:type] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(!task.error) {
            if([task.result boolValue] == YES) {
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                
                data[@"alert"] = message;
                data[@"badge"] = @"Increment";
                data[@"sound"] = @"default";
                data[@"type"]  = @(type);
                data[@"sender"] = [[User currentUser] objectId];
                data[@"target"] = [user objectId];
                if(ISVALID(url))
                    data[@"url"] = url;
                
                // ****** Actual Push Stuff ******
                
                // Create our installation query
                /*PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:user];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our installation query
                [push setData:data];*/
                
                LOGGER(@"About to send Push Notification");
                NSLog(@"Target user: %@, %@", [user objectId], [user getName]);
                
                return [[PFCloud callFunctionInBackground:@"genericPush" withParameters:data] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSString *str = [NSString stringWithFormat:@"Failed to send push notification to User: %@: %@\n%@",
                                         user.objectId,
                                         user.canonicalName,
                                         task.error];
                        LOGGER(str);
                    } else {
                        NSString *str = [NSString stringWithFormat:@"SUCCESSFULLY sent push notification to User: %@: %@",
                                         user.objectId,
                                         user.canonicalName];
                        LOGGER(str);
                    }
                    return [BFTask taskWithResult:user];
                }];
            } else {
                LOGGER(@"Target user has this type of notification disabled!");
                NSLog(@"Target user: %@, %@", [user objectId], [user getName]);
                return [BFTask taskWithResult:user];
            }
        } else
            return [BFTask taskWithError:task.error];
    }];
}

@end

@implementation PushNotificationObject

+ (id)type:(NotificationType)type title:(NSString *)title options:(NSArray *)settingOptions {
    PushNotificationObject *obj = [[PushNotificationObject alloc] init];
    obj.type = type;
    obj.title = title;
    obj.settingOptions = settingOptions;
    return obj;
}

- (NSString *)getName {
    return self.title;
}

- (NSArray *)getOptionNames {
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    for(id opt in self.settingOptions)
        [names addObject:[Push settingName:(NotificationsSetting)[opt integerValue]]];
    
    return names;
}

- (NotificationsSetting)getDefaultSetting {
    return (NotificationsSetting)[[self.settingOptions firstObject] integerValue];
}

@end
