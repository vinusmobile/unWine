//
//  Records.h
//  unWine
//
//  Created by Bryce Boesen on 1/10/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User, unWine;

@interface Records : PFObject <PFSubclassing>

@property (nonatomic, strong) User *editor;
@property (nonatomic, strong) unWine *wine;
@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSArray *value;

+ (NSString *)parseClassName;

@end
