//
//  Level.m
//  unWine
//
//  Created by Bryce Boesen on 8/6/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Level.h"

@implementation Level
@dynamic name, canonicalName, merit, postCount;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Level";
}

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[Level class]]) {
        return [self.objectId isEqualToString:((Level *)object).objectId];
    } else
        return NO;
}

@end
