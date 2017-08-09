//
//  LeaderboardCell.h
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CastProfileVC.h"
#import "User.h"
#import "Grapes.h"

@interface LeaderboardCell : UITableViewCell

@property (nonatomic) BOOL hasSetup;
@property (nonatomic) UIViewController *delegate;

@property (nonatomic, strong) NSIndexPath *path;
@property (nonatomic, strong) User *object;

@property (weak, nonatomic) IBOutlet PFImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *grapeLabel;

- (void)configure:(PFObject *)object;
- (void)setup:(NSIndexPath *)path;

@end
