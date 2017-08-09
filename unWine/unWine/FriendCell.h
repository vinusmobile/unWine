//
//  FriendCell.h
//  unWine
//
//  Created by Bryce Boesen on 8/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "FriendsTVC.h"
#import "User.h"

#define FRIEND_CELL_HEIGHT 138

@class FriendsTVC;
@interface FriendCell : UITableViewCell

@property (nonatomic) FriendsTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSArray *users;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(NSArray *)users;

@end
