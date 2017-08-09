//
//  commentQueryTableViewController+buttonMethods.h
//  unWine
//
//  Created by Fabio Gomez on 8/31/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController.h"

@interface commentQueryTableViewController (buttonMethods)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteComment:(NSIndexPath *)indexPath;
// When this method is called, it will segue the user to a user's profile
- (void)commentToProfileSegue:(id)sender;
@end
