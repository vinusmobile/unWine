//
//  DiscoverCell.h
//  unWine
//
//  Created by Bryce Boesen on 3/4/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverTVC.h"

#define DISCOVER_CELL_HEIGHT 60

@interface DiscoverCell : UITableViewCell <Themeable> {
    BOOL _hasSetup;
}

@property (nonatomic) DiscoverTVC *delegate;
@property (nonatomic) UIImage *icon;
@property (nonatomic) NSIndexPath *indexPath;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle;

@end
