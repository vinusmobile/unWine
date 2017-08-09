//
//  Occasion.m
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Occasion.h"
#import <Parse/PFObject+Subclass.h>

@interface Occasion ()<PFSubclassing>

@end

@implementation Occasion

@dynamic name, image, user;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Occasion";
}
@end
