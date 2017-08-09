//
//  InboxTVC.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ParseSubclasses.h"

#import "UITableViewController+Helper.h"
#import "CastNotificationCell.h"
#import "CastRequestCell.h"
#import "CastConvoCell.h"
#import "CastInboxVC.h"

typedef enum CastInboxMode {
    CastInboxModeNotifications,
    CastInboxModeConversations
} CastInboxMode;

@class CastInboxVC;
@interface InboxTVC : UITableViewController

@property (nonatomic) CastInboxVC *delegate;
@property (nonatomic) NSMutableArray *objects;
@property (nonatomic) CastInboxMode mode;

- (void)loadObjects;
- (NSInteger)getBadgeCount;
+ (NSArray *)getInboxTasks:(BOOL)filterOutViewed;
- (void)acceptFriendship:(Friendship *)object;
- (void)declineFriendship:(Friendship *)object;

@end
