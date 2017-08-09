//
//  Friendship.h
//  unWine
//
//  Created by Fabio Gomez on 8/6/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "unWineAlertView.h"
#define FRIENDSHIP_STATE_ACCEPTED @"Accepted"
#define FRIENDSHIP_STATE_PENDING @"Pending"
#define FRIENDSHIP_STATE_IGNORED @"Ignored"
#define FRIENDSHIP_STATE_UNFRIENDED @"Unfriended"

@protocol FriendshipDelegate;

@class User;
@interface Friendship : PFObject
+ (NSString *)parseClassName;

@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, strong) User      *fromUser;
@property (nonatomic, strong) NSString  *fromUserName;
@property (nonatomic, strong) NSString  *state;
@property (nonatomic, strong) User      *toUser;
@property (nonatomic, strong) NSString  *toUserName;
@property (nonatomic,       ) BOOL       viewed;

- (BOOL)isAccepted;
- (BOOL)isPending;
- (BOOL)isIgnored;
- (BOOL)isUnfriended;

- (BOOL)isFriendshipBetween:(User *)user1 and:(User *)user2;
- (User *)getTheFriend:(User *)user;
+ (BFTask *)getFriendshipFor:(User *)user1 and:(User *)user2;
+ (User *)getUserFriendForFriendship:(Friendship *)friendship andUser:(User *)user;
+ (BFTask *)taskForIf:(User *)user1 andAreFriends:(User *)user2;

+ (void)showUnfriendDialogue:(id<unWineAlertViewDelegate>)controller returnTag:(NSInteger)tag;
+ (BFTask *)confirmUnfriend:(User *)user fromController:(id<FriendshipDelegate>)controller;

// Use this from ContactsInviteTVC
+ (BFTask<Friendship *> *)sendFriendRequest:(User *)user ignoreError:(BOOL)ignoreError;
+ (BFTask<Friendship *> *)sendFriendRequest:(User *)user fromController:(id<FriendshipDelegate>)controller;

// Create function that finds Friendship objects from users
// If mix of found and nonexisting friendships, find a way to track, maybe create empty ones?
// Or maybe (in ContactsInviteTVC) match returned Friendship objects with APContact

@end

@protocol FriendshipDelegate <NSObject>

@required - (BFTask *)updateFriendshipStatus:(User *)user;
@required - (UIView *)getPresentationView;

@end
