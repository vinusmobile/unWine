//
//  Push.h
//  unWine
//
//  Created by Fabio Gomez on 10/27/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATIONS_ON            @"On"
#define NOTIFICATIONS_EVERYERONE    @"Everyone"
#define NOTIFICATIONS_FRIENDS       @"Friends"
#define NOTIFICATIONS_OFF           @"Off"

@class User, BFTask;

typedef enum NotificationsSetting {
    NotificationsSettingOn,
    NotificationsSettingEveryone,
    NotificationsSettingFriends,
    NotificationsSettingOff
} NotificationsSetting;

typedef enum NotificationType {
    NotificationTypeComment,
    NotificationTypeToast,
    NotificationTypeMessage,
    NotificationTypeCheckin,
    NotificationTypeDailyToast,
    NotificationTypeRecommendations,
    NotificationTypeFriendInvites,
    NotificationTypeMentions
} NotificationType;

@interface PushNotificationObject : NSObject

@property (nonatomic) NotificationType type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *settingOptions;

+ (id)type:(NotificationType)type title:(NSString *)title options:(NSArray *)settingOptions;
- (NSString *)getName;
- (NSArray *)getOptionNames;
- (NotificationsSetting)getDefaultSetting;

@end

@interface Push : NSObject

+ (NSArray *)notifications;
+ (PushNotificationObject *)notificationObject:(NotificationType)type;
+ (NSString *)notificationName:(NotificationType)type;
+ (NSString *)settingName:(NotificationsSetting)setting;
+ (NSString *)getNotificationNameWithUserInfo:(NSDictionary *)userInfo;

+ (BOOL)isRegisteredForPushNotifications;

+ (BFTask *)sendPushNotification:(NotificationType)type toGroup:(BFTask *)group withMessage:(NSString *)message;
+ (BFTask *)sendPushNotification:(NotificationType)type toGroup:(BFTask *)group withMessage:(NSString *)message withURL:(NSString *)url;

+ (BFTask *)sendPushNotification:(NotificationType)type toUser:(User *)user withMessage:(NSString *)message;
+ (BFTask *)sendPushNotification:(NotificationType)type toUser:(User *)user withMessage:(NSString *)message withURL:(NSString *)url;

@end
