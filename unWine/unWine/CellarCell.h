//
//  CellarCell.h
//  unWine
//
//  Created by Bryce Boesen on 8/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "CellarTVC.h"
#import "unWine.h"

#define CELLAR_CELL_HEIGHT 138

@class CellarTVC;
@interface CellarCell : UITableViewCell

@property (nonatomic) CellarTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSArray *wines;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(NSArray *)wines;

@end
