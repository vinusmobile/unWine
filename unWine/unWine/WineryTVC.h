//
//  WineryTVC.h
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineryContainerVC.h"
#import <ParseUI/ParseUI.h>

@class WineryContainerVC;

@interface WineryTVC : PFQueryTableViewController <Themeable>

@property (nonatomic) WineryContainerVC *parent;
@property (nonatomic) Winery *winery;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
