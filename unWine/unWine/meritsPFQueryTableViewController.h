//
//  meritsPFQueryTableViewController.h
//  unWine
//
//  Created by Fabio Gomez on 4/25/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "UITableViewController+Helper.h"

@class User;

@interface meritsPFQueryTableViewController : PFQueryTableViewController

@property (strong, nonatomic) User *gUser;

@end
