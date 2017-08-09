//
//  commentQueryTableViewController.h
//  unWine
//
//  Created by Fabio Gomez on 5/20/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>

#define FONT_SIZE 14.0f
#define LABEL_WIDTH 261.0f
#define LABEL_HEIGHT 21.0f

@class PFQueryTableViewController, MBProgressHUD, FooterCell;

@interface commentQueryTableViewController : PFQueryTableViewController {
    NSString *newsFeedId;
    NSMutableArray *comments;
    UITableView *instance;
    // Other Stuff
    MBProgressHUD *gActivityView;
}

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) FooterCell *parent;
@property (nonatomic, strong) NSString *newsFeedId;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) UITableView *instance;

- (void)setNewsFeed:(PFObject *)newsfeed;

@end
