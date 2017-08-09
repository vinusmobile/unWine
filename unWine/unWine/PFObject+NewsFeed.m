//
//  PFObject+NewsFeed.m
//  unWine
//
//  Created by Fabio Gomez on 10/1/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "PFObject+NewsFeed.h"
#import "ParseSubclasses.h"
#define EXIT_IF_NOT_NEWSFEED    if (![self.parseClassName isEqualToString:NewsFeedClass]) { \
                                    NSLog(@"This is not a NewsFeed Object");                \
                                    return nil;                                             \
                                }


@implementation PFObject (NewsFeed)

- (NSString *)getAuthorName{
    
    EXIT_IF_NOT_NEWSFEED
    
    User *user = self[@"authorPointer"];
    
    if (!user) {
        user = (User *)[PFQuery getUserObjectWithId:self[@"Author"]];
    }

    return [user getName];
}

- (NSString *)getType{
    
    EXIT_IF_NOT_NEWSFEED
    
    return self[@"Type"];
}

- (BOOL)isMeritType{
    return [[self getType] isEqualToString:@"Merit"];
}

- (BOOL)isWineType{
    return [[self getType] isEqualToString:@"Wine"];
}

@end
