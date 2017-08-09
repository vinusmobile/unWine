//
//  Feeling.m
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Feeling.h"
#import <Parse/PFObject+Subclass.h>

@interface Feeling ()<PFSubclassing>

@end

@implementation Feeling

@dynamic name, image;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Feeling";
}
@end
