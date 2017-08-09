//
//  Level.h
//  unWine
//
//  Created by Bryce Boesen on 8/6/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class Merits;
@interface Level : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *canonicalName;
@property (nonatomic,       ) NSInteger             postCount;
@property (nonatomic,       ) Merits                *merit;

+ (NSString *)parseClassName;

- (BOOL)isEqual:(id)object;

@end
