//
//  UITableViewController+TabBar.h
//  unWine
//
//  Created by Fabio Gomez on 2/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (TabBar)

/*! Update tab badge at current index
 */
- (int)getCurrentTabItemBadgeValue;
- (void)updateTabBadgeWithValue:(int)value;
- (void)incrementTabBadgeValueByAmount:(int)amount;
- (void)decrementTabBadgeValueByAmount:(int)amount;
- (void)clearTabItemBadgeValue;
@end
