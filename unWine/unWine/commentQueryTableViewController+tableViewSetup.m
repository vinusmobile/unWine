//
//  commentQueryTableViewController+tableViewSetup.m
//  unWine
//
//  Created by Fabio Gomez on 6/26/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController+tableViewSetup.h"
#import "commentQueryTableViewController+commentBox.h"
#import "commentQueryTableViewController+buttonMethods.h"

#import <Parse/Parse.h>
#import "commentCell.h"
#import <ParseUI/ParseUI.h>
#import "UIImageView+AFNetworking.h"
#import "NSDate+NVTimeAgo.h"
#import "ParseSubclasses.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface commentQueryTableViewController() <TTTAttributedLabelDelegate>

@end

@implementation commentQueryTableViewController (tableViewSetup)

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    if(error)
        return;
    
    [self updateCommentCount];
}

- (void)updateCommentCount {
    NSInteger count = self.objects == nil ? 0 : [self.objects count];
    if(self.object != nil) {
        //LOGGER(@"updating comments count...");
        self.object[@"Comments"] = [NSNumber numberWithInteger:count];
        [self.object saveInBackground];
        //LOGGER(@"updated comments count.");
    }
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    
    [query whereKey:@"NewsFeed" equalTo: self.newsFeedId];
    [query includeKey:@"Author"];
    
    [query orderByAscending:@"createdAt"];
    
    return query;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    @try {
        NSString *userName = ((User *)[comments objectAtIndex:indexPath.row][@"Author"]).username.lowercaseString;
        BOOL ret = [userName isEqualToString:[User currentUser].username.lowercaseString];
        return ret;
    } @catch(NSException *e) {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        if (editingStyle == UITableViewCellEditingStyleDelete && [comments count] > indexPath.row) {
            [self deleteComment:indexPath];
            //[tableView setEditing:YES animated:YES];
        }
    } @catch(NSException *e) {
        NSLog(@"Fail2");
    }
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"commentCell";
    UIColor* imageBorderColor = [UIColor colorWithRed:43.0/255 green:90.0/255 blue:131.0/255 alpha:0.4];
    commentCell *cell = (commentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    User *user = object[@"Author"];
    
    if (cell == nil) {
        cell = [[commentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // User Image
    [user setUserImageForImageView:cell.userImage];
    
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.userImage.clipsToBounds = YES;
    cell.userImage.layer.cornerRadius = 15.f/*29.71f*/;
    cell.userImage.layer.borderWidth = .5f;
    cell.userImage.layer.borderColor = imageBorderColor.CGColor;
    cell.userImage.userInteractionEnabled = YES;
    cell.userImage.tag = indexPath.row;
    
    // Create gestureRecognizer to recoognize if a user taps a profile image so you can
    // get ready to segue that profile
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentToProfileSegue:)];
    [cell.userImage addGestureRecognizer:tap1];
    
    // User Name
    cell.userNameLabel.text = [user getName];
    cell.userNameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    @try {
        if([comments count] > indexPath.row)
            [comments replaceObjectAtIndex:indexPath.row withObject:object];
        else
            [comments addObject:object];
    } @catch(NSException *e) {
        NSLog(@"Fail1");
    }
    
    // Text View
    cell.commentLabel.text = object[@"Comment"];
    cell.commentLabel.numberOfLines = 0;//[self numberOfLinesForText:object[@"Comment"]];
    cell.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.commentLabel.tintColor = UNWINE_RED;
  
    dispatch_async(dispatch_get_main_queue(), ^{
        //cell.commentLabel.delegate = self;
        [cell.commentLabel setFrame:CGRectMake(X2(cell.commentLabel), Y2(cell.commentLabel), WIDTH(cell.contentView) - X2(cell.commentLabel) - 10, ( [self numberOfLinesForText:object[@"Comment"]] * 21.))];
        //[cell.commentLabel setLinkAttributes:@{(id)kCTForegroundColorAttributeName: UNWINE_RED, (id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone]}];
        //[cell.commentLabel setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
        //[cell.commentLabel setFrame:CGRectMake(49., 29., 261, ( [self numberOfLinesForText:object[@"Comment"]] * 21.))];
    });
    
    /* 
     // This is to view the actual frame
    cell.commentLabel.layer.borderColor = [UIColor greenColor].CGColor;
    cell.commentLabel.layer.borderWidth = 1.0;
     */
    //cell.commentView.text = object[@"Comment"];
    
     
    // Date Label
    cell.timeLabel.text = [object.createdAt formattedAsTimeAgo];
    
    // Disable Selection
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text = (NSString *)[self.objects objectAtIndex:indexPath.row][@"Comment"];
    
    return 37 + ([self numberOfLinesForText:text] * LABEL_HEIGHT);
    
}


- (CGFloat)numberOfLinesForText: (NSString *)string{
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"TrebuchetMS-Bold" size:14]}];
    
    //NSLog(@"text width = %f, text height = %f", size.width, size.height);
    
    // Lines
    int numberOfLines = size.width / LABEL_WIDTH;
    CGFloat remainder = fmod(size.width, LABEL_WIDTH);
    
    if (remainder > 0) {
        numberOfLines++;
    }
    
    numberOfLines += [[string componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] count] - 1;
    // Sanity check
    if (numberOfLines == 0) {
        numberOfLines ++;
    }
    
    return numberOfLines;
    
}


// Override to customize the look of the cell that allows the user to load the next page of objects.
// The default implementation is a UITableViewCellStyleDefault cell with simple labels.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NextPage";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Load more...";
    
    return cell;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    SFSafariViewController *view = [[SFSafariViewController alloc] initWithURL:url];
    view.view.tintColor = UNWINE_RED;
    [self presentViewController:view animated:YES completion:nil];
}

@end
