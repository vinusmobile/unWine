//
//  LeaderboardTVC.h
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bolts/Bolts.h>

#import "Grapes.h"

#import "LeaderboardCell.h"
#import "UITableViewController+Helper.h"

@interface LeaderboardTVC : UITableViewController <GrapesViewDelegate>

@property (retain, nonatomic) UIBarButtonItem *grapesButton;

@end
