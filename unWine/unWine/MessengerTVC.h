//
//  MessengerTVC.h
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseSubclasses.h"
#import "UITableViewController+Helper.h"

#define SLIM_MESSAGE_CELL_HEIGHT 28
#define DEFAULT_MESSAGE_CELL_HEIGHT 64
#define EXTENDED_MESSAGE_CELL_HEIGHT 20

@interface MessengerTVC : PFQueryTableViewController

@property (nonatomic, retain) Conversations *convo;
@property (nonatomic) BOOL loadQuietly;

- (void)objectsDidLoad:(NSError *)error;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

@end
