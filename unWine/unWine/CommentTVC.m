//
//  CommentTVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "CommentTVC.h"
#import "MessengerCell.h"
#import "MessengerSelfCell.h"
#import "MessengerUserCell.h"
#import "MentionTVC.h"
#import "CommentVC.h"

@interface CommentTVC () <MessageCellDelegate>

@end

@implementation CommentTVC {
    BOOL didLoadOnce;
    BOOL didAppear;
    BOOL isDeleting;
}
@synthesize newsfeed, groups, focusPath;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(didLoadOnce && [self.objects count] == 0) {
        [self.parent presentComposeBarView];
    }
    didAppear = YES;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [Comment query];
    [query whereKey:@"NewsFeed" equalTo:self.newsfeed.objectId];
    [query whereKey:@"hidden" notEqualTo:@(YES)];
    [query includeKey:@"newsfeedPointer"];
    [query includeKey:@"Author"];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if([self.newsfeed.commentIds count] < [self.objects count]) {
        for(Comment *obj in self.objects)
            [self.newsfeed addComment:obj];
        
        //[self.newsfeed saveInBackground];
    } else if([self.newsfeed.commentIds count] > [self.objects count]) {
        NSMutableArray *blacklist = [self.newsfeed.commentIds mutableCopy];
        for(Comment *obj in self.objects)
            [blacklist removeObject:obj.objectId];
        
        for(NSString *objectId in blacklist)
            [self.newsfeed removeCommentId:objectId];
        
        //[self.newsfeed saveInBackground];
    }
    
    if(didAppear && [self.objects count] == 0) {
        [self.parent presentComposeBarView];
    }
    didLoadOnce = YES;
}

- (BOOL)isLastInGroup:(NSIndexPath *)path {
    NSArray *subgroup = [self.groups objectAtIndex:path.section];
    return [subgroup count] - 1 == path.row;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //Comment *object = [self.objects objectAtIndex:indexPath.row];
    return NO;//[object.Author isEqual:[User currentUser]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger c = [super tableView:tableView numberOfRowsInSection:section];
    return isDeleting ? c - 1 : c;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment *object = [self.objects objectAtIndex:indexPath.row];
        if([object.Author isEqual:[User currentUser]]) {
            [self.newsfeed removeComment:object];
            //[[[self.newsfeed saveInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
            object.hidden = YES;
            [[object saveInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
                //[self.groups removeAllObjects];
                if(!task.error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadObjects];
                    });
                }
                
                return nil;
            }];
        }
    }
}

@end
