//
//  MoreResultsTVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/6/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "SearchTVC.h"

@class SearchTVC;
@interface MoreResultsTVC : PFQueryTableViewController

@property (nonatomic) SearchTVCMode mode;
@property (nonatomic) NSString *searchString;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
