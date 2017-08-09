//
//  meritsTableViewController+fetching.m
//  unWine
//
//  Created by Fabio Gomez on 2/25/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//////

#import "meritsTableViewController+fetching.h"

#import "UIImageView+AFNetworking.h"
#import "meritsTableViewController+fetching_LevelMerits.h"
#import "meritsTableViewController+fetching_SpecialMerits.h"
#import "meritsTableViewController+fetching_OtherMerits.h"
#import "meritsTableViewController+fetching_ExclusiveMerits.h"

@implementation meritsTableViewController (fetching)

- (void)fetchMerits{
    
    [self fetchLevelMerits];
    
}

@end
