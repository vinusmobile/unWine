//
//  commentQueryTableViewController+commentBox.m
//  unWine
//
//  Created by Fabio Gomez on 6/26/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController+commentBox.h"
#import "commentQueryTableViewController+tableViewSetup.h"
#import "commentQueryTableViewController+buttonMethods.h"
#import "PHFComposeBarView.h"
#import "ParseSubclasses.h"

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

@interface commentQueryTableViewController () <PHFComposeBarViewDelegate>

@end

@implementation commentQueryTableViewController (commentBox)

- (PHFComposeBarView *)makeComposeBarView{
    
    CGRect frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, PHFComposeBarViewInitialHeight);
    PHFComposeBarView *composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    
    [composeBarView setMaxCharCount:200];
    [composeBarView setMaxLinesCount:5];
    [composeBarView setPlaceholder:@"Type something..."];
    [composeBarView setDelegate:self];
    composeBarView.buttonTitle = @"Post";
    composeBarView.buttonTintColor = UNWINE_RED;
    
    return composeBarView;
    
}



- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame{
    
    printf("\n\n");
    NSLog(@"start frame");
    NSLog(@"x      = %f", startFrame.origin.x);
    NSLog(@"y      = %f", startFrame.origin.y);
    NSLog(@"width  = %f", startFrame.size.width);
    NSLog(@"height = %f\n\n", startFrame.size.height);
    
    NSLog(@"end frame");
    NSLog(@"x      = %f", endFrame.origin.x);
    NSLog(@"y      = %f", endFrame.origin.y);
    NSLog(@"width  = %f", endFrame.size.width);
    NSLog(@"height = %f\n\n", endFrame.size.height);
    
    if (startFrame.size.height < endFrame.size.height) {
        composeBarView.frame = CGRectMake(endFrame.origin.x, composeBarView.frame.origin.y + 20.0f, endFrame.size.width, endFrame.size.height);
        NSLog(@"changed frame asdfasdfa");
        
        [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
    } else if (startFrame.size.height > endFrame.size.height){
        composeBarView.frame = CGRectMake(endFrame.origin.x, composeBarView.frame.origin.y - 20.0f, endFrame.size.width, endFrame.size.height);
        NSLog(@"changed 2");
    }
    
    self.tableView.tableFooterView = composeBarView;
    
}



- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView{
    
    NSString *string = composeBarView.text;
    
    NSLog(@"string = %@", string);
    
    if (string.length <= 200) {
        [self postComment:string];
        
        [composeBarView.textView resignFirstResponder];
        composeBarView.text = @"";
        
    } else {
        [unWineAlertView showAlertViewWithTitle:nil message:@"Please enter a message smaller than 200 characters."];
    }
    
}


// This is to scroll the the tableview to allow the comment box to be seen
- (void)keyboardWillShow:(NSNotification*)note {
    
    printf("\n\n");
    NSLog(@"keyboardWillShow\n\n");
    
    
    NSDictionary* info = [note userInfo];
    
    CGSize kbSize =    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGPoint kbOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    CGFloat sbHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat nbHeight = self.navigationController.navigationBar.frame.size.height;
    //CGFloat cHeight = PHFComposeBarViewInitialHeight;
    CGFloat tbHeight = self.tabBarController.tabBar.frame.size.height;
    
    NSLog(@"kbOrigin.x    = %f", kbOrigin.x);
    NSLog(@"kbOrigin.y    = %f  , tableViewHeight + sbHeight + nbHeight = %f", kbOrigin.y, (self.tableView.contentSize.height + sbHeight + nbHeight));
    NSLog(@"kbSize.width  = %f", kbSize.width);
    NSLog(@"kbSize.height = %f", kbSize.height);
    
    if ((self.tableView.contentSize.height + sbHeight + nbHeight) < kbOrigin.y) {
        return;
    }
    
    CGFloat screenOffset = 0;
    
    if (IS_IPHONE_4) {
        screenOffset = 86;
    }
    
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height - kbSize.height - tbHeight - sbHeight + screenOffset) animated:YES];
    
}



- (void)postComment:(NSString *)commentString{
    
    //NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
    
    Comment *comment = [Comment object];
    
    comment.Author = [User currentUser];
    comment.NewsFeed = self.newsFeedId;
    comment.Comment = commentString;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //[timer invalidate];
        
        if (succeeded) {
            // Increase the comment count in the newsfeed object
            self.tabBarController.view.tag = REFRESH_NEWSFEED;
            
            PFQuery *commentQuery = [Comment query];
            [commentQuery whereKey:@"hidden" notEqualTo:@(YES)];
            [commentQuery whereKey:@"NewsFeed" equalTo:self.newsFeedId];
            NSInteger commentCount = [commentQuery countObjects];
            
            PFQuery *newsFeedQuery = [NewsFeed query];
            [newsFeedQuery includeKey:@"authorPointer"];
            [newsFeedQuery includeKey:@"authorPointer.level"];
            [newsFeedQuery includeKey:@"unWinePointer"];
            [newsFeedQuery includeKey:@"unWinePendingPointer"];
            [newsFeedQuery includeKey:@"meritPointer"];
            
            NewsFeed *newsFeedObject = [newsFeedQuery getObjectWithId:self.newsFeedId];
            
            newsFeedObject[@"Comments"] = [NSNumber numberWithInteger:commentCount];
            [newsFeedObject saveInBackground];
            
            [newsFeedObject sendPushNotificationWithComment:comment except:nil];
            
        }
        else {
            [unWineAlertView showAlertViewWithTitle:nil error:error];
        }
        
        [self loadObjects];
        
    }];
    
}


@end
