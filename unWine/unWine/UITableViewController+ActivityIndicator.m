//
//  UITableViewController+ActivityIndicator.m
//  unWine
//
//  Created by Fabio Gomez on 12/30/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "UITableViewController+ActivityIndicator.h"

@interface UITableViewController () <MBProgressHUDDelegate>

@end

@implementation UITableViewController (ActivityIndicator)

- (void)setUpHUD:(MBProgressHUD *)activityView{
    
    if (activityView != nil) {
        NSLog(@"setUpHUD - gActivityView is still on the screen");
        [activityView hide:YES];
    }
    
    activityView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:activityView];
    
    // Set determinate mode
    activityView.delegate = self;
    activityView.labelText = @"Please Wait";
    [activityView show:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [hud removeFromSuperview];
    hud = nil;
}

@end
