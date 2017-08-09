//
//  UniqueWinesTVC.h
//  unWine
//
//  Created by Bryce Boesen on 8/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "UITableViewController+Helper.h"
#import "MultiWinesCell.h"
#import "ProfileTVC.h"

@class ProfileTVC;
@interface UniqWinesTVC : UITableViewController

@property (nonatomic) User *user;
@property (nonatomic) ProfileTVC *profileTVC;

- (NSInteger)uniqueCount;

@end
