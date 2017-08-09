//
//  SlackHelper.m
//  unWine
//
//  Created by Bryce Boesen on 12/15/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SlackHelper.h"
#import <AFNetworking/AFNetworking.h>

#define CHANNEL_NOTIFICATIONS @"https://hooks.slack.com/services/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"
#define CHANNEL_DEBUGGING_PROD @"https://hooks.slack.com/services/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"
#define CHANNEL_DEBUGGING_DEV @"https://hooks.slack.com/services/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"

#define CHANNEL_CLOUDSIGHT_PROD @"https://hooks.slack.com/services/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"
#define CHANNEL_CLOUDSIGHT_DEV @"https://hooks.slack.com/services/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"

#define CHANNEL_RECOMMENDATIONS_PROD @"https://hooks.slack.com/services/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"
#define CHANNEL_RECOMMENDATIONS_DEV @"https://hooks.slack.com/services/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"

#define IS_PROD ((GET_APP_DELEGATE).environment == PRODUCTION)

@interface SlackHelper ()

@end

@implementation SlackHelper

+ (void)notifyNewSuperUser:(User *)user {
    NSString *env = (GET_APP_DELEGATE).environment == PRODUCTION ? @"Production" : @"Development";
    NSString *payload = [NSString stringWithFormat:@"<!channel> Congratulations unWine, we have a new super user on %@, <unwineapp://user/%@|%@>!", env, [user objectId], [user getName]];
    [SlackHelper sendSlackNotification:payload toChannel:CHANNEL_NOTIFICATIONS];
}

+ (void)notifyPhotoFiltersPurchased:(User *)user withMoney:(BOOL)withMoney {
    NSString *payload = [NSString stringWithFormat:@"<!channel> Yay! <unwineapp://user/%@|%@> just purchased Photo Filters with %@!", [user objectId], [user getName], withMoney ? @"money" : @"grapes"];
    [SlackHelper sendSlackNotification:payload toChannel:CHANNEL_NOTIFICATIONS];
}

+ (void)sendRecommendationMessage:(NSString *)text {
    User *user = [User currentUser];
    NSString *payload = [NSString stringWithFormat:@"%@:\n<unwineapp://user/%@|%@>!", text, [user objectId], [user getName]];
    [SlackHelper sendSlackNotification:payload toChannel:IS_PROD ? CHANNEL_RECOMMENDATIONS_PROD : CHANNEL_RECOMMENDATIONS_DEV];
}

+ (void)sendSlackNotificationToDebugChannel:(NSString *)text {
    NSString *channel = IS_PROD ? CHANNEL_DEBUGGING_PROD : CHANNEL_DEBUGGING_DEV;
    [SlackHelper sendSlackNotification:text toChannel:channel];
}


// Generic calls
+ (void)sendCloudSightMessage:(NSString *)text withColor:(NSString *)color {
    NSString *channel = IS_PROD ? CHANNEL_CLOUDSIGHT_PROD : CHANNEL_CLOUDSIGHT_DEV;
    NSDictionary *data = @{
                           @"text": @"CloudSight Debugging",
                           @"attachments":@[
                                   @{
                                       @"color": color,
                                       @"fields": @[
                                               @{
                                                   @"title": @"Cloudsight Query",
                                                   @"value": text,
                                                   @"short": @(false)
                                                   }
                                               ]
                                       }   
                                   ]
                           };
    
    [SlackHelper sendSlackRequestToChannel:channel andData:data];
}

+ (void)sendSlackNotification:(NSString *)text toChannel:(NSString *)channel {
    NSDictionary *data = @{@"text": text};
    
    [SlackHelper sendSlackRequestToChannel:channel andData:data];
}

+ (void)sendSlackRequestToChannel:(NSString *)channel andData:(NSDictionary *)data {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:channel
       parameters:data
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"SH JSON: %@", responseObject);
          } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"SH Error: %@", error);
          }];
}

@end
