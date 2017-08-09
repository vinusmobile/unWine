//
//  CommentTVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerTVC.h"
#import "ParseSubclasses.h"
#import "UITableViewController+Helper.h"

@class CommentVC;
@interface CommentTVC : MessengerTVC

@property (nonatomic) CommentVC *parent;
@property (nonatomic, retain) NewsFeed *newsfeed;

@end
