//
//  Conversations.h
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User, Messages;
@interface Conversations : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, retain) User                  *user1;
@property (nonatomic, retain) User                  *user2;
@property (nonatomic, retain) PFRelation            *messages;
@property (nonatomic, retain) Messages              *lastMessage;
@property (nonatomic        ) BOOL                  hidden;

+ (BFTask *)getConvoObjectTask:(NSString *)objectId;
+ (PFQuery *)queryEither:(User *)user;
+ (PFQuery *)psuedoQuery:(NSString *)objectId;
- (User *)getOtherUser;
- (BOOL)isUnread;
- (void)markRead;
- (BOOL)isBlocked;

@end
