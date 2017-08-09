//
//  commentQueryTableViewController+buttonMethods.m
//  unWine
//
//  Created by Fabio Gomez on 8/31/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController+buttonMethods.h"
#import "commentQueryTableViewController+commentBox.h"
#import "commentQueryTableViewController+tableViewSetup.h"
#import "PHFComposeBarView.h"
#import "MBProgressHUD.h"
#import "CastProfileVC.h"
#import "ParseSubclasses.h"

@implementation commentQueryTableViewController (buttonMethods)

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PHFComposeBarView *view = (PHFComposeBarView *)self.tableView.tableFooterView;
    
    [view resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)deleteComment:(NSIndexPath *)indexPath{
    //Only get here if the post is their own
    
    [self removeObjectAtIndexPath:indexPath];
    
    PFObject *object = [comments objectAtIndex:indexPath.row];
    
    SHOW_HUD;
    
    [PFCloud callFunctionInBackground:@"deleteCommentWithNotifications"
                       withParameters:@{@"commentID" : object.objectId, @"currentUser": [User currentUser].objectId}
                                block:^(id result, NSError *error){
        HIDE_HUD;
        
        if(!error) {
            NSLog(@"Comment deleted successfully");
            self.tabBarController.view.tag = REFRESH_NEWSFEED;
            [self updateCommentCount];
        } else {
            
            [unWineAlertView showAlertViewWithTitle:nil error:error];
        }
    }];
    
     
}

// When this method is called, it will segue the user to a user's profile
- (void)commentToProfileSegue:(id)sender{
    //NSUInteger indexPath = (NSUInteger)[sender tag];
    
    NSLog(@"user tapped the user image");
    
    NSInteger indexPath = [(UIGestureRecognizer *)sender view].tag;
    
    PFObject *tempDict = [self.objects objectAtIndex:indexPath];
    
    //NSMutableString *objectId = (NSMutableString *)[[tempDict objectForKey:@"Author"] objectId];
    User *user = [tempDict objectForKey:@"Author"];
    
    
    NSLog(@"%@  !!!!!!!!!!!!", user.objectId);
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    [profile setProfileUser:user];
    
    [self.navigationController pushViewController: profile animated:YES];
    
}



// HUD Code

- (void)setUpHUD{
    
    if (gActivityView != nil) {
        NSLog(@"setUpHUD - gActivityView is still on the screen");
        [gActivityView hide:YES];
    }
    
    gActivityView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:gActivityView];
    
    // Set determinate mode
    gActivityView.delegate = self;
    gActivityView.labelText = @"Please Wait";
    [gActivityView show:YES];
}



@end
