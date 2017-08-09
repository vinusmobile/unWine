//
//  CellarTVC.h
//  unWine
//
//  Created by Bryce Boesen on 8/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ImageFullVC.h"
#import "UITableViewController+Helper.h"
#import "ProfileTVC.h"
#import "CellarCell.h"

@class ProfileTVC, User;
@interface CellarTVC : UITableViewController

@property (nonatomic) User *user;
@property (nonatomic) ProfileTVC *profileTVC;

- (BFTask *)getCellarTask;
- (NSInteger)cellarCount;
- (void)loadObjects;

@end
