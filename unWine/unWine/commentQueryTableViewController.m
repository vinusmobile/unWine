//
//  commentQueryTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 5/20/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController.h"
#import "commentQueryTableViewController+commentBox.h"
#import "commentQueryTableViewController+tableViewSetup.h"
#import "commentQueryTableViewController+buttonMethods.h"

#import "commentCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+NVTimeAgo.h"
#import "commentFooterView.h"
#import "PHFComposeBarView.h"
#import "UITableViewController+Helper.h"

#import "FooterCell.h"
#import "MBProgressHUD.h"
#import "commentCell.h"

@interface commentQueryTableViewController () <UITextFieldDelegate, MBProgressHUDDelegate>

@end

@implementation commentQueryTableViewController

@synthesize object, newsFeedId, comments, instance;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Footer View
    self.tableView.tableFooterView = [self makeComposeBarView];
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [self addUnWineTitleView];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    comments = [[NSMutableArray alloc] init];
    instance = (UITableView *)self.tableView;
    //[self.tableView registerClass:[commentCell class] forCellReuseIdentifier:@"commentCell"];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isLoading]) {
        [self loadObjects];
    }
}

/*- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [self.parent configureCommentButton:self.parent.object];
    }
}*/

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)setNewsFeed:(PFObject *)newsfeed {
    self.object = newsfeed;
    self.newsFeedId = [newsfeed objectId];
    //LOGGER(@"wellllll what the fuck");
}


@end

