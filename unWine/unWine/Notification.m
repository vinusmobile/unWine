//
//  Notification.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Notification.h"
#import "NewsFeed.h"
#import "User.h"
#import "Comment.h"
#import "Merits.h"
#import "unWine.h"

@implementation Notification
@dynamic Author, Owner, Name, Type, commentPointer, constant, isComment, newsFeedPointer, winePointer, viewed;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Notification";
}

// This function creates a notification object for the specified user so that it shows in their inbox
+ (BFTask *)createNotificationObjectFor:(NewsFeed *)newsFeedObject usingComment:(Comment *)comment andUser:(User *)user {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"newsFeedPointer"] = newsFeedObject.objectId;
    dictionary[@"Type"] = newsFeedObject.Type;
    dictionary[@"Name"] = [self getNameForNotificationObjectUsingObject:newsFeedObject];
    //dictionary[@"viewed"] = @"NO";
    dictionary[@"isComment"] = (comment != nil) ? @"YES" : @"NO";
    
    if(comment != nil)
        dictionary[@"commentPointer"] = comment.objectId;

    dictionary[@"Owner"] = [user.objectId copy];
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

+ (BFTask *)createCheckinNotification:(NewsFeed *)newsFeedObject andUser:(User *)user {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"newsFeedPointer"] = newsFeedObject.objectId;
    dictionary[@"Type"] = @"Checkin";
    dictionary[@"Name"] = [self getNameForNotificationObjectUsingObject:newsFeedObject];
    dictionary[@"isComment"] = @"NO";
    dictionary[@"Owner"] = user.objectId;
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

+ (BFTask *)createRecommendationNotification:(NewsFeed *)newsFeedObject andUser:(User *)user {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"newsFeedPointer"] = newsFeedObject.objectId;
    dictionary[@"Type"] = @"Recommendation";
    dictionary[@"Name"] = [self getNameForNotificationObjectUsingObject:newsFeedObject];
    dictionary[@"isComment"] = @"NO";
    dictionary[@"Owner"] = user.objectId;
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

+ (BFTask *)createMentionNotification:(NewsFeed *)newsFeedObject andUser:(User *)user atCheckin:(BOOL)atCheckin {

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"newsFeedPointer"] = newsFeedObject.objectId;
    dictionary[@"Type"] = atCheckin ? @"Mention" : @"Mention-Comment";
    dictionary[@"Name"] = [self getNameForNotificationObjectUsingObject:newsFeedObject];
    dictionary[@"isComment"] = @"NO";
    dictionary[@"Owner"] = user.objectId;
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

+ (BFTask *)createRecommendationObjectFor:(unWine *)winePointer andUser:(User *)user {

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"winePointer"] = winePointer.objectId;
    dictionary[@"Type"] = @"Recommendation";
    dictionary[@"Name"] = [winePointer getWineName];
    dictionary[@"isComment"] = @"NO";
    dictionary[@"Owner"] = user.objectId;
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

+ (BFTask *)createRecommendationObjectForWinery:(Winery *)wineryPointer andUser:(User *)user {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"wineryPointer"] = wineryPointer.objectId;
    dictionary[@"Type"] = @"Recommendation";
    dictionary[@"Name"] = [wineryPointer getWineryName];
    dictionary[@"isComment"] = @"NO";
    dictionary[@"Owner"] = user.objectId;
    dictionary[@"Author"] = [[User currentUser] objectId];
    
    return [PFCloud callFunctionInBackground:@"createNotification" withParameters:dictionary];
}

// Helper Stuff
// Utility Functions that help with the above two functions

+ (NSString *)getNameForNotificationObjectUsingObject:(NewsFeed *)newsFeedObject{
    
    NSString *name = nil;
    
    if ([newsFeedObject isMeritType]) {
        name = [newsFeedObject getMeritName];
    } else if ([newsFeedObject isWineType]) {
        name = [newsFeedObject getWineName];
    }
    
    return name;
}

- (NSString *)getAuthorName {
    return [self.Author getName];
}

- (NSString *)getNewsFeedAuthorName {
    return [self.newsFeedPointer.authorPointer getName];
}

- (BOOL)ownerIsEqualToNewsFeedAuthor {
    return [self.newsFeedPointer userIsEqualToAuthor:self.Owner];
}

// Utility Stuff
- (NSString *)getNotificationMessage {
    
    NSString *message = @"";
    
    if ([self isCommentNotification]) {
        message = [self getCommentMessage];
    } else if([self isAlertNotification]) {
        message = [self getAlertMessage];
    } else if([self isCheckinNotification]) {
        message = [self getCheckinMessage];
    } else if([self isRecommendationNotification]) {
        message = [self getRecommendationMessage];
    } else if([self isCheckinMentionNotification]) {
        message = [self getCheckinMentionMessage];
    } else if([self isCommentMentionNotification]) {
        message = [self getCommentMentionMessage];
    } else {
        message = [self getToastMessage];
    }
    
    return message;
}

- (NSString *)getToastMessage {
    
    NSString *message = @"";
    if ([self ownerIsEqualToNewsFeedAuthor]) {
        message = [NSString stringWithFormat:@"%@ toasted your %@", [self getAuthorName], self.Type];
    } else {
        message = [NSString stringWithFormat:@"%@ toasted %@'s %@", [self getAuthorName], [self getNewsFeedAuthorName], self.Type];
    }
    
    return message;
}

- (NSString *)getRecommendationMessage {
    
    NSString *message = @"";
    if (self.winePointer != nil) {
        message = [NSString stringWithFormat:@"%@ recommended you a wine!", [self getAuthorName]];
    } else {
        message = [NSString stringWithFormat:@"%@ shared a Check In with you!", [self getAuthorName]];
    }
    
    return message;
}

- (NSString *)getCheckinMessage {
    NSString *message = [NSString stringWithFormat:@"%@ just checked in a %@!", [self getAuthorName], self.Name]; //[NSString stringWithFormat:@"%@ recommended you a wine!", [self getAuthorName]];
    
    return message;
}

- (NSString *)getCheckinMentionMessage {
    NSString *message = [NSString stringWithFormat:@"%@ mentioned you in a Check In!", [self getAuthorName]];
    
    return message;
}

- (NSString *)getCommentMentionMessage {
    NSString *message = [NSString stringWithFormat:@"%@ mentioned you in a Comment!", [self getAuthorName]];
    
    return message;
}

- (NSString *)getCommentMessage {
    
    NSString *message = @"";
    if ([self ownerIsEqualToNewsFeedAuthor]) {
        message = [NSString stringWithFormat:@"%@ commented on your %@", [self getAuthorName], self.Type];
    } else {
        message = [NSString stringWithFormat:@"%@ commented on %@'s %@", [self getAuthorName], [self getNewsFeedAuthorName], self.Type];
    }
    
    return message;
}

- (NSString *)getAlertMessage {
    return self[@"constant"][@"Value"][@"Message"];
}

- (BOOL)isAlertNotification {
    return [self.Type isEqualToString:@"Alert"];
}

- (BOOL)isCheckinNotification {
    return [self.Type isEqualToString:@"Checkin"];
}

- (BOOL)isRecommendationNotification {
    return [self.Type isEqualToString:@"Recommendation"];
}

- (BOOL)isCheckinMentionNotification {
    return [self.Type isEqualToString:@"Mention"];
}

- (BOOL)isCommentMentionNotification {
    return [self.Type isEqualToString:@"Mention-Comment"];
}

- (BOOL)isToastNotification {
    return (!self.isComment && [self.Type isEqualToString:@"Wine"]);
}

- (BOOL)isCommentNotification {
    return (self.isComment && [self.Type isEqualToString:@"Wine"]);
}

- (BOOL)hasSeen {
    return self.viewed;
}

- (BFTask *)markSeen {
    if(!self.viewed) {
        self.viewed = YES;
        return [self saveInBackground];
    }
    
    return [BFTask taskWithResult:@(TRUE)];
}

+ (BFTask *)sendMentionNotificationsFromMentions:(NSArray *)mentions forCheckin:(NewsFeed *)checkin atCheckin:(BOOL)atCheckin {
    LOGGER(@"Enter");
    if(mentions == nil || [mentions count] == 0) {
        LOGGER(@"no mentions");
        return [BFTask taskWithResult:@(true)];
    }
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];
    NSString *msg = [NSString stringWithFormat:@"%@ mentioned you in a %@!", [user getName], atCheckin ? @"Check In" : @"Comment"];
    
    NSMutableArray<User *> *mentionUsers = [[NSMutableArray alloc] init];
    for(MentionObject *object in mentions)
        [mentionUsers addObject:object.user];
    __block int num_objects = 0;
    
    LOGGER(@"Sending push notifications");
    
    [[[Push sendPushNotification:NotificationTypeMentions toGroup:[BFTask taskWithResult:mentionUsers] withMessage:msg] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Finished sending push notifications");
        //LOGGER(task.result);
        NSArray *childTasks = task.result;
        NSMutableArray *notificationObjectTasks = [[NSMutableArray alloc] init];
        
        for(id child in childTasks) {
            if(child && [child isKindOfClass:[User class]]) {
                NSLog(@"adding notification %@", [(User *)child objectId]);
                
                [notificationObjectTasks addObject:[Notification createMentionNotification:checkin andUser:(User *)child atCheckin:atCheckin]];
                num_objects++;
            }
        }
        
        LOGGER(@"Creating notification objects");
        return [BFTask taskForCompletionOfAllTasks:notificationObjectTasks];
        
    }] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            LOGGER(@"Something happened");
            LOGGER(task.error);
            [theTask setError:task.error];
        }
        
        NSString *s = [NSString stringWithFormat:@"Created %i notification objects", num_objects];
        LOGGER(s);
        [theTask setResult:@(num_objects)];
        
        return nil;
    }];
    
    return theTask.task;
}

+ (BFTask *)sendCheckinNotificationsToFriendsExcept:(NSMutableArray<User *> *)mentionUsers forCheckin:(NewsFeed *)checkin andWine:(unWine *)wine {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];
    __block NSMutableArray<User *> *friends = nil;
    
    LOGGER(@"Getting Friends");
    [[[[user getFriendUsers] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<User *> *> * _Nonnull task) {
        LOGGER(@"Got Friends");
        friends = [task.result mutableCopy];
        
        for(User *mUser in mentionUsers) {
            for(User *aUser in friends) {
                if([aUser.objectId isEqualToString:mUser.objectId]) {
                    LOGGER(@"Removing mention user from friends");
                    [friends removeObject:aUser];
                    break;
                }
            }
        }
        
        NSString *msg = [NSString stringWithFormat:@"%@ just checked in a %@!", [user getName], [wine getWineName]];
        NSString *s = [NSString stringWithFormat:@"Sending %lu push notifications", (unsigned long)friends.count];
        LOGGER(s);

        return (friends && friends.count > 0) ? [Push sendPushNotification:NotificationTypeCheckin toGroup:[BFTask taskWithResult:friends] withMessage:msg]: [BFTask taskWithResult:@(true)];
        
    }] continueWithSuccessBlock:^id(BFTask *task) {
        LOGGER(@"Sent all the push notifications");
        NSMutableArray *notificationObjectTasks = [[NSMutableArray alloc] init];
        LOGGER(@"Enumerating child tasks");

        for(id child in friends) {
            if(child && [child isKindOfClass:[User class]]) {
                NSString *s = [NSString stringWithFormat:@"adding notification %@", [(User *)child objectId]];
                LOGGER(s);
                [notificationObjectTasks addObject:[Notification createCheckinNotification:checkin andUser:(User *)child]];
            }
        }

        NSString *s = [NSString stringWithFormat:@"Creating %lu Notification Objects", (unsigned long)notificationObjectTasks.count];
        LOGGER(s);

        return notificationObjectTasks.count > 0 ? [BFTask taskForCompletionOfAllTasks:notificationObjectTasks]: [BFTask taskWithResult:@(true)];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Done!");
            [theTask setResult:@(true)];
        }
        return nil;
    }];
    
    return theTask.task;
}

@end
