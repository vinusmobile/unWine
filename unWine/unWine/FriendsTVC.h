//
//  FriendsTVC.h
//  unWine
//
//  Created by Bryce Boesen on 8/8/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Bolts/Bolts.h>
#import "ImageFullVC.h"
#import "UITableViewController+Helper.h"
#import "ProfileTVC.h"
#import "FriendCell.h"

@class ProfileTVC, User;
@interface FriendsTVC : UITableViewController

@property (nonatomic) User *user;
@property (nonatomic) ProfileTVC *profileTVC;
@property (nonatomic) ImageFullVC *imageFullVC;

@property (strong, nonatomic) IBOutlet UITableView *profileView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;

- (BFTask *)getFriendsTask;

@end
