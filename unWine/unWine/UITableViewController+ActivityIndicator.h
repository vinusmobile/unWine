//
//  UITableViewController+ActivityIndicator.h
//  unWine
//
//  Created by Fabio Gomez on 12/30/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UITableViewController (ActivityIndicator)

- (void)setUpHUD:(MBProgressHUD *)activityView;

@end
