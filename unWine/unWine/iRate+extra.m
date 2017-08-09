//
//  iRate+extra.m
//  unWine
//
//  Created by Fabio Gomez on 9/4/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "iRate+extra.h"

@implementation iRate (extra)
- (void)promptForRatingIfUserHasNotDeclinedCurrentVersion{
    if (self.declinedThisVersion == NO) {
        NSLog(@"User hasn't rated this version");
        [self promptIfNetworkAvailable];
    } else {
        NSLog(@"User declined this version");
    }
}
@end
