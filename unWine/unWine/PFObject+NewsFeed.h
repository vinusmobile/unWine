//
//  PFObject+NewsFeed.h
//  unWine
//
//  Created by Fabio Gomez on 10/1/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#define NewsFeedClass @"NewsFeed"

@interface PFObject (NewsFeed)

- (NSString *)getAuthorName;
- (NSString *)getType;
- (BOOL)isMeritType;
- (BOOL)isWineType;

@end
