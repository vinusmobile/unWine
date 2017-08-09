//
//  MeritBaseCell.h
//  unWine
//
//  Created by Bryce Boesen on 2/15/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MeritsTVC.h"
#import "Merits.h"

#define MERIT_BASE_CELL_HEIGHT 138

@class MeritsTVC;
@interface MeritBaseCell : UITableViewCell

@property (nonatomic) MeritsTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSArray *merits;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(NSArray *)merits;

@end
