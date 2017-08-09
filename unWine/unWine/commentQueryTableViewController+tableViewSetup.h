//
//  commentQueryTableViewController+tableViewSetup.h
//  unWine
//
//  Created by Fabio Gomez on 6/26/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController.h"

@interface commentQueryTableViewController (tableViewSetup)
- (void)objectsWillLoad;
- (void)objectsDidLoad:(NSError *)error;
- (PFQuery *)queryForTable;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)numberOfLinesForText: (NSString *)string;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateCommentCount;
@end
