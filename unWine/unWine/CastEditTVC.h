//
//  CastEditTVC.h
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"
#import "AWEditCell.h"

#define DEFAULT_EDIT_CELL_HEIGHT 44

@interface CastEditTVC : UITableViewController

@property (nonatomic) PFObject *wine;
@property (nonatomic) NSArray *results;

@end
