//
//  Conversations.m
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Conversations.h"
#import "User.h"
#import "Messages.h"

@implementation Conversations
@dynamic user1, user2, lastMessage, hidden;
@synthesize messages = _messages;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Conversations";
}

+ (BFTask *)getConvoObjectTask:(NSString *)objectId {
    PFQuery *query = [Conversations query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query whereKeyExists:@"user1"];
    [query whereKeyExists:@"user2"];
    [query includeKey:@"user1"];
    [query includeKey:@"user1.level"];
    [query includeKey:@"user2"];
    [query includeKey:@"user2.level"];
    [query includeKey:@"lastMessage"];
    
    return [query getFirstObjectInBackground];
}

- (PFRelation *)messages {
    if(_messages == nil)
        _messages = [self relationForKey:@"messages"];
    
    return _messages;
}

- (void)setMessages:(PFRelation *)messages {
    _messages = messages;
}

- (User *)getOtherUser {
    if([self.user1 isEqualToUser:[User currentUser]])
        return self.user2;
    else
        return self.user1;
}

+ (PFQuery *)queryEither:(User *)user {
    PFQuery *query1 = [self query];
    [query1 whereKey:@"user1" equalTo:user];
    
    PFQuery *query2 = [self query];
    [query2 whereKey:@"user2" equalTo:user];
    
    PFQuery *cQuery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [cQuery whereKeyExists:@"user1"];
    [cQuery whereKeyExists:@"user2"];
    [cQuery whereKey:@"hidden" notEqualTo:@YES];
    [cQuery includeKey:@"user1"];
    [cQuery includeKey:@"user1.level"];
    [cQuery includeKey:@"user2"];
    [cQuery includeKey:@"user2.level"];
    [cQuery includeKey:@"lastMessage"];
    
    return cQuery;
}

+ (PFQuery *)psuedoQuery:(NSString *)objectId {
    PFQuery *psuedoQuery = [PFQuery queryWithClassName:@"Conversations"];
    [psuedoQuery whereKey:@"objectId" equalTo:objectId];
    [psuedoQuery includeKey:@"user1"];
    [psuedoQuery includeKey:@"user1.level"];
    [psuedoQuery includeKey:@"user2"];
    [psuedoQuery includeKey:@"user2.level"];
    [psuedoQuery includeKey:@"lastMessage"];
    
    return psuedoQuery;
}

- (BOOL)isUnread {
    if(self.lastMessage == nil || self.lastMessage.sender == nil)
        return NO;
    
    return !self.lastMessage.seen && ![self.lastMessage.sender isTheCurrentUser];
}

- (void)markRead {
    if(self.lastMessage == nil || self.lastMessage.sender == nil)
        return;
    
    [self.lastMessage markRead];
}

- (BOOL)isBlocked {
    User *other = [self getOtherUser];
    return [other hasUserBlocked:[User currentUser]] || [[User currentUser] hasUserBlocked:other];
}

@end
