//
//  Messages.m
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Messages.h"
#import "ParseSubclasses.h"

@interface Messages () <MessageDelegate>

@end

@implementation Messages
@dynamic sender, message, seen, seenAt;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Messages";
}

- (void)markRead {
    self.seen = YES;
    self.seenAt = [NSDate new];
    [self saveInBackground];
}

- (User *)getAssociatedUser {
    return self.sender;
}

- (NSString *)getMessage {
    return self.message;
}

- (NSString *)getSenderName {
    return [self.sender getName];
}

@end
