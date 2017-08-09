//
//  SlackHelper.h
//  unWine
//
//  Created by Bryce Boesen on 12/15/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#define SLACK_GOOD @"good"
#define SLACK_WARNING @"warning"
#define SLACK_DANGER @"danger"

@interface SlackHelper : NSObject

/*!
 * Sends an integrated slack notification, returns true if the notification was sent successfully.
 */

+ (void)notifyNewSuperUser:(User *)user;
+ (void)notifyPhotoFiltersPurchased:(User *)user withMoney:(BOOL)withMoney;
+ (void)sendCloudSightMessage:(NSString *)text withColor:(NSString *)color;
+ (void)sendRecommendationMessage:(NSString *)text;
+ (void)sendSlackNotificationToDebugChannel:(NSString *)text;

@end
