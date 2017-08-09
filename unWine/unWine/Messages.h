//
//  Messages.h
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User;
@interface Messages : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) User                  *sender;
@property (nonatomic, strong) NSString              *message;
@property (nonatomic        ) BOOL                  seen;
@property (nonatomic, strong) NSDate                *seenAt;

- (void)markRead;

@end
