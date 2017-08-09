//
//  UITableViewController+Helper.h
//  unWine
//
//  Created by Fabio Gomez on 8/22/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#define ELIMINATE_TABLE_FOOTER_VIEW self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

@interface UITableViewController (Helper)

- (void)basicAppeareanceSetup;
- (UIView *)headerViewWithText:(NSString *)text andHeight:(CGFloat)headerHeightO;
- (void)addUnWineTitleView;

@end
