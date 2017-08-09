//
//  UITableViewController+Helper.m
//  unWine
//
//  Created by Fabio Gomez on 8/22/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "UITableViewController+Helper.h"
#import "UVStyleSheet.h"

@implementation UITableViewController (Helper)

- (void)basicAppeareanceSetup{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.title = @"Back";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tabBarController.tabBar.translucent = NO;
    
    // White Status Bar for controllers inside Navigation Controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // Not sure why this works lol
    
    [self addUnWineTitleView];
}

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}



// Custom method to modify the headerView for each tableView
- (UIView *)headerViewWithText:(NSString *)text andHeight:(CGFloat)headerHeightO{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., headerHeightO)];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.7;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10., 0., 300., headerHeightO)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:20.];
    
    [view addSubview:label];
    return view;
}

- (NSString *)getStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    return [formatter stringFromDate:date];
}



@end
