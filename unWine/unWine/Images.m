//
//  Images.m
//  unWine
//
//  Created by Fabio Gomez on 9/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Images.h"
#import <Parse/PFObject+Subclass.h>
#import <Parse/Parse.h>
#import "ParseSubclasses.h"

@interface Images ()<PFSubclassing>

@end

@implementation Images

@dynamic name, image;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Images";
}

+ (BFTask *)getFBInviteImage {
    PFQuery *query = [Images query];
    [query whereKey:@"name" equalTo:@"fb invite"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    return [query getFirstObjectInBackground];
}

@end
