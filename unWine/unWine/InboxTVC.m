//
//  InboxTVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "InboxTVC.h"
#import "VineCastTVC.h"
#import "MessengerVC.h"
#import "CheckinInterface.h"

#define DEFAULT_INBOX_CELL_HEIGHT 64
#define SUCCESS_ALERT_TAG 443123

@interface InboxTVC () <unWineAlertViewDelegate>

@end

@implementation InboxTVC {
    NSMutableSet *seenCells;
    UITableViewCell *emptyCell;
    UIView *markAll;
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadObjects];
    
    if(self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor clearColor];
        //self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(loadObjects)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    [self basicAppeareanceSetup];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.estimatedRowHeight = DEFAULT_INBOX_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkVisibilityOfCell:(CastNotificationCell *)cell inScrollView:(UIScrollView *)aScrollView {
    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
    
    if(CGRectContainsRect(aScrollView.frame, cellRect))
        [seenCells addObject:cell.object.objectId];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray<UITableViewCell *> *cells = self.tableView.visibleCells;
    
    for (NSUInteger i = 0; i < [cells count]; i++) {
        UITableViewCell *cell = [cells objectAtIndex:i];
        if(cell != nil && [cell isKindOfClass:[CastNotificationCell class]]) {
            CastNotificationCell *nCell = (CastNotificationCell *)cell;
            if(![nCell.object hasSeen])
                [self checkVisibilityOfCell:nCell inScrollView:scrollView];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects == nil || [self.objects count] == 0 ? 1 : [self.objects count];
}

+ (NSArray *)getInboxTasks:(BOOL)filterOutViewed {
    return [[InboxTVC getNotificationTask:filterOutViewed] arrayByAddingObjectsFromArray:[InboxTVC getConversationTask:filterOutViewed]];
}

+ (NSDate *)getThirtyDaysAgo {
    NSDate *now = [NSDate date];
    return [now dateByAddingTimeInterval:-30 * 24 * 60 * 60];
}

+ (NSArray *)getNotificationTask:(BOOL)filterOutViewed {
    PFQuery *friendQuery = [Friendship query];
    [friendQuery whereKey:@"toUser" equalTo:[User currentUser]];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery whereKey:@"state" equalTo:@"Pending"];
    [friendQuery orderByDescending:@"createdAt"];
    BFTask *friendTask = [friendQuery findObjectsInBackground];
    
    PFQuery *nq1 = [Notification query];
    [nq1 whereKeyExists:@"newsFeedPointer"];
    
    PFQuery *nq2 = [Notification query];
    [nq2 whereKeyExists:@"winePointer"];
    
    PFQuery *nq3 = [Notification query];
    [nq3 whereKeyExists:@"wineryPointer"];
    
    PFQuery *notificationQuery = [PFQuery orQueryWithSubqueries:@[nq1, nq2, nq3]];
    [notificationQuery whereKey:@"Owner" equalTo:[User currentUser]];
    [notificationQuery whereKey:@"createdAt" greaterThan:[self getThirtyDaysAgo]];
    if(filterOutViewed)
        [notificationQuery whereKey:@"viewed" equalTo:[NSNumber numberWithBool:NO]];
    [notificationQuery includeKey:@"Owner"];
    [notificationQuery includeKey:@"Author"];
    [notificationQuery includeKey:@"newsFeedPointer.authorPointer"];
    [notificationQuery includeKey:@"newsFeedPointer.authorPointer.level"];
    [notificationQuery includeKey:@"newsFeedPointer.unWinePointer"];
    [notificationQuery includeKey:@"wineryPointer"];
    [notificationQuery includeKey:@"winePointer"];
    [notificationQuery includeKey:@"winePointer.partner"];
    [notificationQuery includeKey:@"constant"];
    [notificationQuery orderByDescending:@"createdAt"];
    BFTask *notificationTask = [notificationQuery findObjectsInBackground];
    
    return @[friendTask, notificationTask];
}

+ (NSArray *)getConversationTask:(BOOL)filterOutViewed {
    PFQuery *conversationQuery = [Conversations queryEither:[User currentUser]];
    [conversationQuery whereKeyExists:@"lastMessage"];
    [conversationQuery orderByDescending:@"updatedAt"];
    BFTask *conversationTask = [conversationQuery findObjectsInBackground];
    
    return @[conversationTask];
}

- (Notification *)getNotificationWithObjectId:(NSString *)objectId {
    for(PFObject *object in self.objects)
        if([[object parseClassName] isEqualToString:[Notification parseClassName]])
            if([object.objectId isEqualToString:objectId]) {
                return (Notification *)object;
            }
    
    return nil;
}

- (CastNotificationCell *)getNotificationCell:(NSString *)objectId {
    for(UITableViewCell *cell in self.tableView.visibleCells)
        if([cell isKindOfClass:[CastNotificationCell class]]) {
            CastNotificationCell *nCell = (CastNotificationCell *)cell;
            if([nCell.object.objectId isEqualToString:objectId])
                return nCell;
        }
    
    return nil;
}

static BOOL refreshing = NO;
- (void)loadObjects {
    if(self.refreshControl != nil && ![self.refreshControl isRefreshing])
        SHOW_HUD_FOR_VIEW(self.navigationController.view);
    
    if(seenCells == nil) {
        seenCells = [[NSMutableSet alloc] init];
    } else {
        for(NSString *objectId in seenCells) {
            Notification *note = [self getNotificationWithObjectId:objectId];
            
            if(note)
                [note markSeen];
        }
    }
    
    refreshing = YES;
    if(self.mode == CastInboxModeNotifications) {
        NSArray *tasks = [InboxTVC getNotificationTask:NO];
        [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            HIDE_HUD_FOR_VIEW(self.navigationController.view);
            BFTask *friendTask = [tasks objectAtIndex:0];
            BFTask *notificationTask = [tasks objectAtIndex:1];
            
            if(!friendTask.error || !notificationTask.error) {
                NSMutableArray *preprocess = [[NSMutableArray alloc] init];
                if(friendTask.result != nil && [friendTask.result count] > 0)
                    [preprocess addObjectsFromArray:friendTask.result];
                
                if(notificationTask.result != nil && [notificationTask.result count] > 0)
                    [preprocess addObjectsFromArray:notificationTask.result];
                
                self.objects = preprocess;
                
                if(!markAll) {
                    markAll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 52)];
                    
                    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 4, SCREENWIDTH, 44)];
                    container.backgroundColor = [UIColor whiteColor];
                    [markAll addSubview:container];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 120, 36)];
                    [label setText:@"Mark all read"];
                    [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
                    [container addSubview:label];
                    
                    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 51 - 8, 7, 51, 40)];
                    [switcher addTarget:self action:@selector(markAllRead:) forControlEvents:UIControlEventValueChanged];
                    [container addSubview:switcher];
                }
                
                if([self.objects count] > 0)
                    self.tableView.tableHeaderView = markAll;
                else
                    self.tableView.tableHeaderView = nil;
            }
            
            refreshing = NO;
            [self updateVinecastBadge];
            
            return nil;
        }];
    } else {
        NSArray *tasks = [InboxTVC getConversationTask:NO];
        [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            HIDE_HUD_FOR_VIEW(self.navigationController.view);
            BFTask *conversationTask = [tasks objectAtIndex:0];
            
            if(!conversationTask.error)
                self.objects = conversationTask.result;
            
            refreshing = NO;
            [self updateVinecastBadge];
            
            return nil;
        }];
    }
}

- (void)markAllRead:(UISwitch *)switcher {
    NSLog(@"markAllRead - %@", switcher.isOn ? @"YES" : @"NO");
    if([switcher isOn]) {
        [self performSelector:@selector(toggleSwitcher:) withObject:switcher afterDelay:1.f];
        
        for(PFObject *object in self.objects) {
            if([[object parseClassName] isEqualToString:[Notification parseClassName]]) {
                Notification *note = (Notification *)object;
                if(![note hasSeen]) {
                    [note markSeen];
                    CastNotificationCell *cell = [self getNotificationCell:note.objectId];
                    if(cell)
                        [cell configure:note];
                }
            }
        }
        
        [[self markAllNotificationsAsRead] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            [self updateVinecastBadge];
            return nil;
        }];
    }
}
- (BFTask *)markAllNotificationsAsRead {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *query = [Notification query];
    [query whereKey:@"Owner" equalTo:[User currentUser]];
    [query whereKey:@"viewed" equalTo:[NSNumber numberWithBool:false]];
    query.limit = 1000;
    
    [[[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        NSMutableArray *notifications = (NSMutableArray *)t.result;
        
        if (notifications && notifications.count > 0) {
            NSString *s = [NSString stringWithFormat:@"Got %lu notifications", notifications.count];
            LOGGER(s);
        } else {
            NSString *s = [NSString stringWithFormat:@"Got 0 notifications"];
            LOGGER(s);
        }
        
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        for (Notification *n in notifications) {
            NSString *s = [NSString stringWithFormat:@"Marking notification \"%@\" as seen.", n.objectId];
            LOGGER(s);
            [tasks addObject:[n markSeen]];
        }
        
        return [BFTask taskForCompletionOfAllTasks:tasks];

    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(t.error.localizedDescription);
            [theTask setError:t.error];
        } else {
            LOGGER(@"Saved all the notifications");
            [theTask setResult:@(TRUE)];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

- (void)toggleSwitcher:(UISwitch *)switcher {
    NSLog(@"toggling switcher %@", switcher.isOn ? @"ON" : @"OFF");
    [switcher setOn:NO animated:YES];
}

- (void)updateVinecastBadge {
    NSLog(@"about to updateVinecastBadge %@", self.delegate);
    [self.delegate updateVinecastBadge];
    
    if(self.refreshControl != nil && [self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
    [self.tableView reloadInputViews];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.objects == nil || [self.objects count] == 0) {
        if(emptyCell == nil)
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"Empty"];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [emptyCell.textLabel setText:@"You have no notifications"];
        [emptyCell.textLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
        emptyCell.alpha = 1;
        return emptyCell;
    } else {
        emptyCell.alpha = 0;
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if([[object parseClassName] isEqualToString:[Notification parseClassName]]) {
            CastNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.delegate = self;
            Notification *note = (Notification *)object;
            
            [cell setup:indexPath];
            [cell configure:note];
            
            return cell;
        } else if([[object parseClassName] isEqualToString:[Friendship parseClassName]]) {
            CastRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
            [cell setup:indexPath];
            [cell configure:(Friendship *)object];
            
            return cell;
        } else if([[object parseClassName] isEqualToString:[Conversations parseClassName]]) {
            CastConvoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConvoCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
            [cell setup:indexPath];
            [cell configure:(Conversations *)object];
            
            return cell;
        } else {
            return [[UITableViewCell alloc] init];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.objects == nil || [self.objects count] == 0)
        return;
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if([[object parseClassName] isEqualToString:[Notification parseClassName]]) {
        Notification *note = (Notification *)object;
        CastNotificationCell *cell = (CastNotificationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(note.newsFeedPointer != nil) {
            UIStoryboard *newsFeed = [UIStoryboard storyboardWithName:@"VineCast" bundle:nil];
            VineCastTVC *feed = [newsFeed instantiateViewControllerWithIdentifier:@"feed"];
            //[feed adjustFrame];
            [feed setVineCastSingleObject:note.newsFeedPointer];
            
            if(![note hasSeen]) {
               [note markSeen];
                [cell configure:note];
            }
            
            if ([note isRecommendationNotification]) {
                [Analytics trackGenericEvent:EVENT_USER_OPENED_CHECKIN_RECOMMENDATION];
            }

            [self.navigationController pushViewController:feed animated:YES];
        } else if(note.winePointer != nil) {
            LOGGER(@"clicked recommended wine");
            
            WineContainerVC *container = [[WineContainerVC alloc] init];
            container.wine = note.winePointer;
            container.isNew = NO;
            container.cameFrom = CastCheckinSourceInbox;
            
            if(![note hasSeen]) {
                [note markSeen];
                [cell configure:note];
            }
            
            if ([note isRecommendationNotification]) {
                [Analytics trackGenericEvent:EVENT_USER_OPENED_WINE_RECOMMENDATION];
            }
            
            [self.navigationController pushViewController:container animated:YES];
        } else if(note.wineryPointer != nil) {
            LOGGER(@"clicked recommended winery");
            
            WineryContainerVC *container = [[WineryContainerVC alloc] init];
            container.winery = note.wineryPointer;
            
            if(![note hasSeen]) {
                [note markSeen];
                [cell configure:note];
            }
            
            [self.navigationController pushViewController:container animated:YES];
        }
    } else if([[object parseClassName] isEqualToString:[Conversations parseClassName]]) {
        Conversations *convo = (Conversations *)object;
        CastConvoCell *cell = (CastConvoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        MessengerVC *mess = [[MessengerVC alloc] initWithConversation:convo];
        
        if([convo isUnread]) {
            [convo markRead];
            [cell configure:convo];
        }
        
        [self.navigationController pushViewController:mess animated:YES];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.objects != nil && [self.objects count] > 0) {
        if(refreshing || [self.objects count] <= indexPath.row)
            return NO;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        return [[object parseClassName] isEqualToString:[Notification parseClassName]];
    } else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        /*[[PFCloud callFunctionInBackground:@"deleteNotification" withParameters:@{@"objectId": object.objectId}] continueWithBlock:^id _Nullable(BFTask<id> * _Nonnull task) {
            
            return nil;
        }];*/
        
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self loadObjects];
        }];
    }
}

- (NSInteger) getBadgeCount {
    LOGGER(@"Enter");
    if (!(self.objects != nil && [self.objects count] > 0)) {
        LOGGER(@"Returning 0");
        return 0;
    }
    
    NSInteger count = 0;
    for(PFObject *object in self.objects) {
        if([[object parseClassName] isEqualToString:[Notification parseClassName]]) {
            Notification *note = (Notification *)object;
            if(!note.viewed)
                count++;
        } else if([[object parseClassName] isEqualToString:[Conversations parseClassName]]) {
            Conversations *convo = (Conversations *)object;
            if([convo isUnread] && !convo.hidden)
                count++;
        } else
            count++;
    }
    NSString *s = [NSString stringWithFormat:@"getBadgeCount %li", (long)count];
    LOGGER(s);
    return count;
}

- (void)acceptFriendship:(Friendship *)object {
    NSDictionary *data = @{@"currentUser": [User currentUser].objectId, @"friendshipAction": @"accept", @"fromUserID": object.fromUser.objectId};
    
    SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
    [[PFCloud callFunctionInBackground:@"acceptFriendRequests" withParameters:data] continueWithBlock: ^id(BFTask *task) {
        HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = task.error;
            if (error) {
                [self showErrorAlert:error];
            } else {
                [self showAlertWithTitle:@"Friend request accepted!"];
            }
        });
        return nil;
    }];
}

- (void)declineFriendship:(Friendship *)object {
    object.state = @"Ignored";
    object.date = [NSDate date];
    
    SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
    [[object saveInBackground] continueWithBlock:^id(BFTask *task) {
        HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = task.error;
            if (error) {
                [self showErrorAlert:error];
            } else {
                [self showAlertWithTitle:@"Friend request ignored!"];
            }
        });
        return nil;
    }];
}

- (void)showAlertWithTitle:(NSString *)title {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:title];
    alert.delegate = self;
    alert.tag = SUCCESS_ALERT_TAG;
    alert.centerButtonTitle = @"Ok";
    alert.disableDispatch = YES;
    [alert show];
}

- (void)centerButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == SUCCESS_ALERT_TAG) {
        [self loadObjects];
    }
}

- (void)showErrorAlert:(NSError *)error {
    [unWineAlertView showAlertViewWithoutDispatchWithTitle:nil error:error];
}

@end
