//
//  Friendship.m
//  unWine
//
//  Created by Fabio Gomez on 8/6/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Friendship.h"
#import <Parse/PFObject+Subclass.h>
#import <Parse/Parse.h>
#import "ParseSubclasses.h"
#import <Bolts/Bolts.h>

@interface Friendship ()<PFSubclassing>

@end

@implementation Friendship

@dynamic date, fromUser, fromUserName, state, toUser, toUserName, viewed;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Friendship";
}

- (User *)getTheFriend:(User *)user {
    return [user isEqualToUser:self.toUser] ? self.fromUser : self.toUser;
}

- (BOOL)isAccepted {
    return [self.state isEqualToString:FRIENDSHIP_STATE_ACCEPTED];
}

- (BOOL)isPending {
    return [self.state isEqualToString:FRIENDSHIP_STATE_PENDING];
}

- (BOOL)isIgnored {
    return [self.state isEqualToString:FRIENDSHIP_STATE_IGNORED];
}

- (BOOL)isUnfriended {
    return [self.state isEqualToString:FRIENDSHIP_STATE_UNFRIENDED];
}

- (BOOL)isFriendshipBetween:(User *)user1 and:(User *)user2 {
    return ([self.toUser isEqual:user1] && [self.fromUser isEqual:user2]) || ([self.toUser isEqual:user2] && [self.fromUser isEqual:user1]);
}

+ (User *)getUserFriendForFriendship:(Friendship *)friendship andUser:(User *)user {
    return [user.objectId isEqualToString: friendship.toUser.objectId] ? friendship.fromUser : friendship.toUser;
}

+ (BFTask *)taskForIf:(User *)user1 andAreFriends:(User *)user2 {
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:user1];
    [friendsQuery1 whereKey:@"fromUser" equalTo:user2];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"toUser" equalTo:user2];
    [friendsQuery2 whereKey:@"fromUser" equalTo:user1];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery whereKey:@"state" equalTo:@"Accepted"];
    [friendQuery orderByAscending:@"date"];
    
    return [friendQuery findObjectsInBackground];
}

+ (BFTask *)getFriendshipFor:(User *)user1 and:(User *)user2 {
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:user1];
    [friendsQuery1 whereKey:@"fromUser" equalTo:user2];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"toUser" equalTo:user2];
    [friendsQuery2 whereKey:@"fromUser" equalTo:user1];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery orderByAscending:@"date"];
    friendQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    return [friendQuery getFirstObjectInBackground];
}

+ (Friendship *)composeRequest:(User *)from toUser:(User *)to {
    if(from == nil || to == nil)
        return nil;
    
    Friendship *request = [Friendship object];
    request.fromUser = from;
    request.fromUserName = [from.canonicalName capitalizedString];
    request.toUser = to;
    request.toUserName = [to.canonicalName capitalizedString];
    request.state = @"Pending";
    request.viewed = @(NO);
    request.date = [NSDate date];
    
    return request;
}

+ (void)showUnfriendDialogue:(id<unWineAlertViewDelegate>)controller returnTag:(NSInteger)tag {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Are you sure you want to unfriend this person?"];
    alert.delegate = controller;
    alert.theme = unWineAlertThemeRed;
    alert.title = @"Hold up!";
    alert.leftButtonTitle = @"No";
    alert.rightButtonTitle = @"Yes";
    alert.tag = tag;
    [alert show];
}


+ (BFTask<Friendship *> *)sendFriendRequest:(User *)user ignoreError:(BOOL)ignoreError {
    if([user isTheCurrentUser]) {
        LOGGER(@"Cannot send friend invite to self");
        return [BFTask taskWithError:[NSError errorWithDomain:@"Current User"
                                                         code:500
                                                     userInfo:nil]];
    }
    
    NSString *s = [NSString stringWithFormat:@"ignoreError = %@", ignoreError ? @"YES" : @"NO"];
    LOGGER(s);
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [[[PFCloud callFunctionInBackground:@"sendFriendInvites"
                         withParameters:@{@"userID": user.objectId, @"currentUser": [User currentUser].objectId}]
      continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<id> *task) {
          BFTask *t = [Friendship getFriendshipFor:user and:[User currentUser]];
          
          if ((task.error && ignoreError) || task.error == nil) {
              LOGGER(@"Successfully sent invite. Getting friendship for user");
              t = [Friendship getFriendshipFor:user and:[User currentUser]];
              
          } else {
              LOGGER(@"Erroring out");
              LOGGER(task.error);
              t = [BFTask taskWithError:task.error];
          }
          
          return t;
          
      }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<id> *task) {
          
          if(task.error) {
              LOGGER(@"Something happened either sending friend request or getting Friendship Object");
              LOGGER(task.error);
              [theTask setError:task.error];
          } else {
              LOGGER(@"Successfully sent Friend Invite and queried Friendship object");
              [Analytics trackNewFriendInviteWithUser:user];
              [theTask setResult:task.result];
          }
          
          return nil;
      }];
    
    return theTask.task;
}

+ (BFTask<Friendship *> *)sendFriendRequest:(User *)user fromController:(id<FriendshipDelegate>)controller {
    if([user isTheCurrentUser])
        return nil;
    
    if([controller getPresentationView])
        SHOW_HUD_FOR_VIEW([controller getPresentationView]);
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [[[PFCloud callFunctionInBackground:@"sendFriendInvites" withParameters:@{@"userID": user.objectId, @"currentUser": [User currentUser].objectId}] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<id> *task) {
        if([controller getPresentationView])
            HIDE_HUD_FOR_VIEW([controller getPresentationView]);
        
        if (!task.error) {
            [Analytics trackNewFriendInviteWithUser:user];
            [unWineAlertView showAlertViewWithBasicSuccess:task.result];
            
            return [Friendship getFriendshipFor:user and:[User currentUser]]; //[user isFriendsWithUser:[User currentUser]];
        } else {
            LOGGER(task.error);
            [source setError:task.error];
            [unWineAlertView showAlertViewWithTitle:nil error:task.error];
            
            return nil;
        }
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<id> *task) {
        if(task.error) {
            [source setError:task.error];
            [unWineAlertView showAlertViewWithTitle:nil error:task.error];
        } else {
            Friendship *friendship = task.result;
            if([friendship isPending]) {
                /*[Push sendPushNotification:NotificationTypeFriendInvites
                 toUser:user
                 withMessage:[NSString stringWithFormat:@"%@ has sent you a friend request!", [[User currentUser] getName]]
                 withURL:@"unwineapp://inbox"];*/
                
                [source setResult:friendship];//return [BFTask taskWithResult:friendship];
            } else if([friendship isAccepted]) {
                [source setResult:friendship];
                //return [BFTask taskWithResult:friendship];
            }
        }
        
        return nil;
    }];
    
    return source.task;
}

+ (BFTask *)confirmUnfriend:(User *)user fromController:(id<FriendshipDelegate>)controller {
    if([user isTheCurrentUser])
        return nil;
    if([controller getPresentationView])
        SHOW_HUD_FOR_VIEW([controller getPresentationView]);
    
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [source setResult:[[PFCloud callFunctionInBackground:@"unfriend" withParameters:@{@"currentUser": [User currentUser].objectId, @"friends": @[user.objectId]}] continueWithBlock:^id(BFTask<id> *task) {
            if([controller getPresentationView])
                HIDE_HUD_FOR_VIEW([controller getPresentationView]);
            
            if (!task.error) {
                [Analytics trackUserUnfriendedFriendWithUser:user];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller updateFriendshipStatus:user];
                });
                
                return [BFTask taskWithResult:user];
            } else{
                LOGGER(task.error);
                [unWineAlertView showAlertViewWithTitle:nil error:task.error];
                
                return nil;
            }
        }]];
    });
    
    return source.task;
}

@end
