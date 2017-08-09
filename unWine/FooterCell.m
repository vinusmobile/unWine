//
//  WineDetailCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "FooterCell.h"
#import "VineCastTVC.h"
#import "ParseSubclasses.h"
#import "VCWineCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MediaHelper.h"
#import "CommentVC.h"

@implementation FooterCell {
    NSMutableArray<UIView *> *views;
    NewsFeed *checkin;
}

static NSInteger viewTopBuffer = 8;
static NSInteger viewBuffer = 8;
static NSInteger viewHeight = 54;
static NSInteger viewWidth = 54;
static NSInteger viewWidthExtended = 64;

- (void)setup {
    [super setup];
    views = [[NSMutableArray alloc] init];

    self.toastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toastButton setFrame:(CGRect){0, viewTopBuffer, {viewWidthExtended, viewHeight}}];
    self.toastButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.toastButton setImageEdgeInsets:UIEdgeInsetsMake(4, 6, 0, 0)];
    [self.toastButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 8, 0, 0)];
    [self.toastButton setImage:[UIImage imageNamed:@"breadsmall"] forState:UIControlStateNormal];
    [self.toastButton.imageView setContentMode:UIViewContentModeLeft];
    [self.toastButton setTitle:@"" forState:UIControlStateNormal];
    [self.toastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.toastButton addTarget:self action:@selector(toastPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setFrame:(CGRect){0, viewTopBuffer, {viewWidthExtended, viewHeight}}];
    self.commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.commentButton setImageEdgeInsets:UIEdgeInsetsMake(4, 6, 0, 0)];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 10, 0, 0)];
    [self.commentButton setImage:[UIImage imageNamed:@"commentIcon"] forState:UIControlStateNormal];
    [self.commentButton.imageView setContentMode:UIViewContentModeLeft];
    [self.commentButton setTitle:@"" forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.reactionView = [ReactionView reactWithFrame:(CGRect){0, viewTopBuffer, {viewWidth, viewHeight}} type:ReactionType0None];
    [self.reactionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reactionPressed)]];
    self.reactionView.descLabel.alpha = 0;
    self.reactionView.delegate = self;
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setFrame:(CGRect){0, viewTopBuffer, {viewWidth, viewHeight}}];
    [self.shareButton setImage:[UIImage imageNamed:@"shareIconGray"] forState:UIControlStateNormal];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
    [self.shareButton addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flagButton setFrame:(CGRect){0, viewTopBuffer - 3, {viewWidth, viewHeight}}];
    [self.flagButton setTitle:@"···" forState:UIControlStateNormal];
    [self.flagButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:54]];
    self.flagButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.flagButton.titleLabel.minimumScaleFactor = .5;
    [self.flagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.flagButton addTarget:self action:@selector(flagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:[self container:self.toastButton label:@"Toast"]];
    [self.contentView addSubview:[self container:self.commentButton label:@"Comment"]];
    [self.contentView addSubview:[self container:self.reactionView label:@"Reaction"]];
    [self.contentView addSubview:[self container:self.shareButton label:@"Share"]];
    [self.contentView addSubview:[self container:self.flagButton label:@""]];
}

- (void)addLabel:(UIView *)view text:(NSString *)text {
    UILabel *descLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 2, {WIDTH(view), 14}}];
    [descLabel setTextAlignment:NSTextAlignmentCenter];
    [descLabel setTextColor:UNWINE_GRAY];
    [descLabel setText:text];
    [descLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:10]];
    descLabel.adjustsFontSizeToFitWidth = YES;
    descLabel.minimumScaleFactor = .5;
    [view addSubview:descLabel];
}

- (UIView *)container:(UIView *)view label:(NSString *)label {
    [self setupView:view];
    if(ISVALID(label))
        [self addLabel:view text:label];
    [views addObject:view];
    return view;
}

- (void)setupView:(UIView *)view {
    view.backgroundColor = [UIColor whiteColor];
    /*view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = .5;
    view.layer.cornerRadius = 6;
    view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    view.layer.shadowOffset = (CGSize){0, 0};
    view.layer.shadowOpacity = .5;
    view.layer.shadowRadius = 1.5;*/
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    self.flagButton.tag = self.tag;
    
    if(self.isCompletelyVisible || self.delegate.justReappeared) {
        [self configureCommentButton:object];
        [self configureToastButton:object];
    }
    
    [self.reactionView setReaction:[object getReaction]];
    [self.reactionView setReactionSize:26];
    
    [self alignViews];
}

- (void)alignViews {
    /*NSInteger totalWidth = 0;
    for(UIView *view in views)
        if(view != self.reactionView || [self.object getReaction] != ReactionType0None)
            totalWidth += WIDTH(view);*/
    
    NSInteger startX = viewBuffer; //(SCREEN_WIDTH - totalWidth - ([views count] - 1) * viewBuffer) / 2;
    for(UIView *view in views) {
        if(view == self.reactionView && [self.object getReaction] == ReactionType0None) {
            view.alpha = 0;
        } else if(view == self.flagButton) {
            view.alpha = 1;
            [view setOrigin:(CGPoint){SCREENWIDTH - WIDTH(view) - viewBuffer, viewTopBuffer}];
        } else {
            view.alpha = 1;
            [view setOrigin:(CGPoint){startX, viewTopBuffer}];
            startX += WIDTH(view) + viewBuffer;
        }
    }
}

- (NSString *)simpleIndexPath {
    return [NSString stringWithFormat:@"%li-%li", (long)self.indexPath.section, (long)self.indexPath.row];
}

- (void)notifyCompletelyVisible {
    if(!self.isCompletelyVisible || self.delegate.justReappeared) {
        [self configureCommentButton:self.object];
        [self configureToastButton:self.object];
    }
    
    [super notifyCompletelyVisible];
}

- (void)configureToastButton:(NewsFeed *)object {
    User *curr = [User currentUser];
    BOOL guestLikes = [curr isAnonymous] && [[User getWitnessState:WITNESS_GUEST_TOAST] isEqualToString:object.objectId];
    BOOL userLikes = [curr didToastPost:object] || guestLikes;
    [self.toastButton setImage:(userLikes)? [UIImage imageNamed:@"toastsmall"] : [UIImage imageNamed:@"breadsmall"] forState:UIControlStateNormal];
    self.toastButton.tag = self.tag;
    NSLog(@"userLikes vinepost? %@", userLikes ? @"YES" : @"NO");
    NSLog(@"objectId %@ - Likes %li", self.object.objectId, (long)[curr.Likes count]);
    
    [[object updateToastCountIfNecessary] continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger likes = [[object getToasters] count];
            [self.toastButton setTitle:[NSString stringWithFormat:@"%li", (long)(guestLikes ? (likes + 1) : likes)] forState:UIControlStateNormal];
        });
        
        /*if([task.result boolValue])
            return [object saveInBackground];
        else*/
        return nil;
    }];
}

- (void)configureCommentButton:(NewsFeed *)object {
    self.commentButton.tag = self.tag;
    
    [[object updateCommentCountIfNecessary] continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger comments = [[object commentIds] count];
            [self.commentButton setTitle:[NSString stringWithFormat:@"%li", (unsigned long)comments] forState:UIControlStateNormal];
        });
        
        /*if([task.result boolValue])
            return [object saveInBackground];
        else*/
        return nil;
    }];
}

- (void)fakeToast:(UIGestureRecognizer *)recognizer {
    NSString *objectId = self.object.objectId;
    
    if([self.toastButton.currentImage isEqual:[UIImage imageNamed:@"breadsmall"]]) {
        [User setWitnessState:WITNESS_GUEST_TOAST state:objectId];
        [self.toastButton setImage:[UIImage imageNamed: @"toastsmall"] forState:UIControlStateNormal];
        
        [[self.delegate getWineCell:self.indexPath] showToastAnimation:self.toastButton];
        //[self showToastAnimation:self.toastButton];
        
        [self configureToastButton:self.object];
    } else {
        [User unwitness:WITNESS_GUEST_TOAST];
        [self.toastButton setImage:[UIImage imageNamed:@"breadsmall"] forState:UIControlStateNormal];
        
        [self configureToastButton:self.object];
    }
}

- (void)reactionPressed {
    [self reactionPressed:ReactionType0None];
}

- (void)reactionPressed:(ReactionType)reaction {
    if(ISVALID(self.delegate.singleObjectId)) {
        [self.delegate scrollTo:2];
    } else {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_REACTION_BUTTON_ON_VINECAST);
        VineCastTVC *feed = [self.delegate.storyboard instantiateViewControllerWithIdentifier:@"feed"];
        [feed setVineCastSingleObject:self.object];
        
        [self.delegate.navigationController pushViewController:feed animated:YES];
    }
}

- (void)toastPressed:(UIGestureRecognizer *)recognizer {
    User *user = [User currentUser];
    NSString *objectId = self.object.objectId;
    if(!ISVALID(objectId))
        return;
    
    if([user isAnonymous] && (![User hasSeen:WITNESS_GUEST_TOAST] || [[User getWitnessState:WITNESS_GUEST_TOAST] isEqualToString:objectId])) {
        [self fakeToast:recognizer];
        return;
    } else if([user isAnonymous]) {
        [user promptGuest:self.delegate];
        return;
    }
    
    BOOL userLikes = [user didToastPost:self.object];
    if(userLikes) { //Untoast
        [[self.object fetchInBackground] continueWithBlock:^id(BFTask<__kindof PFObject *> *task) {
            NewsFeed *obj = self.object = task.result;
            [user untoastPost:obj];
            
            return [[obj removeToaster:user] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                [self configureToastButton:self.object];
                
                return [user saveInBackground];
            }];
        }];
    } else { //Toast
        [[self.object fetchInBackground] continueWithBlock:^id(BFTask<__kindof PFObject *> *task) {
            NewsFeed *obj = self.object = task.result;
            [user toastPost:obj];
            
            return [[obj addToaster:user] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                [self configureToastButton:self.object];
                [[self.delegate getWineCell:self.indexPath] showToastAnimation:self.toastButton];
                
                [self.object sendPushNotificationWithComment:nil except:nil];
                
                return [user saveInBackground];
            }];
        }];
    }
}

- (void)commentPressed:(UIGestureRecognizer *)recognizer {
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [user promptGuest:self.delegate];
        return;
    }
    
    CommentVC *commenter = [[CommentVC alloc] initWithNewsFeed:self.object];
    [self.delegate.navigationController pushViewController:commenter animated:YES];
    
    /*commentQueryTableViewController *vc = [self.delegate.storyboard instantiateViewControllerWithIdentifier:@"comments"];
    [vc setNewsFeed:self.object];
    [self.delegate.navigationController pushViewController:vc animated:YES];*/
}

- (void)sharePressed:(UIGestureRecognizer *)recognizer {
    SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
    [[[User currentUser] getFriends] continueWithBlock:^id(BFTask *task) {
        HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
            BOOL shouldAddShare = YES;
            NSMutableArray *content = [ScrollElementView scrollElementsFrom:task.result];
            
            if([content count] == 0) {
                shouldAddShare = NO;
            } else if([content count] > 1) {
                [content insertObject:[ScrollElementView makeElementFromObject:[ScrollElement selectAll]] atIndex:0];
            }
            
            [content addObject:[ScrollElementView makeElementFromObject:[ScrollElement inviteFriends]]];
            
            unWineActionSheet *actionSheet = [[unWineActionSheet alloc]
                                              initWithTitle:@"Share Check In"
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              customContent:content];
             
            if(shouldAddShare)
                actionSheet.otherButtonTitles = @[dialogShare];
             */
            
            NSArray *buttons = @[SHARE_FACEBOOK, SHARE_TEXT, SHARE_EMAIL];
            unWineActionSheet *actionSheet = [[unWineActionSheet alloc] initWithTitle:@"Share Checkin"
                                                                             delegate:self.delegate
                                                                    cancelButtonTitle:@"Cancel"
                                                                    otherButtonTitles:buttons];
            actionSheet.checkin = self.object;
            actionSheet.merit = nil;
            [actionSheet showFromTabBar:self.delegate.navigationController.view];
        });
        return nil;
    }];
}

static NSString *dialogAddWishList = @"Add Wine to Wish List";
static NSString *dialogRemoveWishList = @"Remove Wine from Wish List";
static NSString *dialogSavePhoto = @"Save Photo to Camera Roll";
static NSString *dialogReportInappropriate = @"Report Inappropriate";
static NSString *dialogDeleteCheckin = @"Delete Checkin";
static NSString *dialogShare = @"Send";
static NSString *dialogMore = @"More";


/*
 * Action Sheet
 */
- (void)flagButtonSelected:(id)sender {
    //NSLog(@"The object ID that was flagged was %@ !!!!!!!!!!", self.object.objectId);
    
    NSString *destructiveTitle;
    
    User *curr = [User currentUser];
    
    if ([self.object[@"Author"] isEqualToString:curr.objectId] == YES || [[self.object[@"authorPointer"] objectId] isEqualToString:curr.objectId]) {
        destructiveTitle = dialogDeleteCheckin;
    } else{
        destructiveTitle = dialogReportInappropriate;
    }
    
    if(self.object.unWinePointer && ![self.object.unWinePointer isKindOfClass:[NSNull class]]) {
        SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
        
        PFQuery *query = [[curr theCellar] query];
        [query whereKey:@"objectId" equalTo:self.object.unWinePointer.objectId];
        [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
            HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
            
            NSString *dialogCellar = count > 0 ? dialogRemoveWishList : dialogAddWishList;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = self.delegate.cellImages[[self.object objectId]];
                NSMutableArray *array = image ? [@[dialogCellar, dialogSavePhoto, destructiveTitle] mutableCopy] : [@[dialogCellar, destructiveTitle] mutableCopy];
                
                if(!ISVALID(self.delegate.singleObjectId))
                   [array addObject:dialogMore];
                
                unWineActionSheet *actionSheet = [[unWineActionSheet alloc]
                                              initWithTitle:nil
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:array];
                
                actionSheet.tag = UAS_TAG_CHECKIN;
                if(self.delegate.tabBarController && self.delegate.tabBarController.view.window)
                    [actionSheet showFromTabBar:self.delegate.tabBarController.view];
                else
                    [actionSheet showFromTabBar:self.delegate.navigationController.view];
            });
        }];
    } else {
        UIImage *image = self.delegate.cellImages[[self.object objectId]];
        NSMutableArray *array = image ? [@[dialogSavePhoto, destructiveTitle] mutableCopy] : [@[destructiveTitle] mutableCopy];
        
        if(!ISVALID(self.delegate.singleObjectId))
            [array addObject:dialogMore];
        
        unWineActionSheet *actionSheet = [[unWineActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:array];
        
        actionSheet.tag = UAS_TAG_CHECKIN;
        if(self.delegate.tabBarController && self.delegate.tabBarController.view.window)
            [actionSheet showFromTabBar:self.delegate.tabBarController.view];
        else
            [actionSheet showFromTabBar:self.delegate.navigationController.view];
    }
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    //NSLog(@"Method is getting called");
    
    if ([buttonTitle isEqualToString:dialogReportInappropriate]) {
        NSLog(@"Report Inappropriate Pressed");
        
        PFObject *flag = [PFObject objectWithClassName:@"Flags"];
        User *owner = self.object[@"authorPointer"];
        PFQuery *userQuery = [User query];
        
        if (!owner) {
            owner = (User *)[userQuery getObjectWithId:self.object[@"Author"]];
        }
        
        flag[@"flaggedNewsObjectId"] = [self.object objectId];
        flag[@"Author"] = [User currentUser];
        flag[@"Owner"] = owner;
        
        [flag saveInBackground];

    } else if ([buttonTitle isEqualToString:dialogDeleteCheckin]) {
        NSLog(@"Delete Pressed");
        [self deleteNewsFeedObject:self.object.objectId];

    } else if ([buttonTitle isEqualToString:dialogSavePhoto]) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        UIImage *image = self.delegate.cellImages[[self.object objectId]];
        
        MBProgressHUD *hud = SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
        hud.label.text = @"Saving...";
        [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
                [unWineAlertView showAlertViewWithTitle:nil error:error];
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Saved!";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES afterDelay:.4];
                });
            }
        }];
    } else if([buttonTitle isEqualToString:dialogMore]) {
        [self presentMore];
    } else if([buttonTitle isEqualToString:dialogAddWishList]) {
        User *user = [User currentUser];
        if(user != nil && ![self.object.unWinePointer isKindOfClass:[NSNull class]]) {
            [user addWineToCellar:self.object.unWinePointer];
        }
    } else if([buttonTitle isEqualToString:dialogRemoveWishList]) {
        User *user = [User currentUser];
        if(user != nil && ![self.object.unWinePointer isKindOfClass:[NSNull class]]) {
            [user removeWineFromCellar:self.object.unWinePointer];
        }
    } else if([buttonTitle isEqualToString:dialogShare]) {
        NSMutableArray *content = [actionSheet getSelectedElements];
        NSMutableArray *group = [[NSMutableArray alloc] init];
        if(content != nil) {
            for(ScrollElementView *element in content)
                if([element.object isKindOfClass:[User class]])
                    [group addObject:(User *)element.object]; //Get user objects from selected elements
            
            if([group count] > 0) {
                NSString *pushMessage = [NSString stringWithFormat:@"%@ shared a checkin with you!", [[User currentUser] getName]];
                SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
                [[[Push sendPushNotification:NotificationTypeRecommendations toGroup:[BFTask taskWithResult:[group copy]] withMessage:pushMessage withURL:[NSString stringWithFormat:@"unwineapp://vinecast/%@", self.object.objectId]] continueWithBlock:^id(BFTask *task) {
                    
                    if(task.error) {
                        HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
                        [unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
                        return nil;
                    }
                    
                    LOGGER(task.result);
                    NSArray *childTasks = task.result;
                    
                    NSMutableArray *notificationObjectTasks = [[NSMutableArray alloc] init];
                    
                    for(id child in childTasks) {
                        if(child && [child isKindOfClass:[User class]]) {
                            NSLog(@"adding notification %@", [(User *)child objectId]);
                            
                            [notificationObjectTasks addObject:[Notification createRecommendationNotification:self.object andUser:(User *)child]];
                        }
                    }
                    
                    return [[BFTask taskForCompletionOfAllTasks:notificationObjectTasks] continueWithBlock:^id(BFTask *task) {
                        return [BFTask taskWithResult:@([notificationObjectTasks count])];
                    }];
                }] continueWithBlock:^id(BFTask *task) {
                    HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
                    
                    NSInteger sent = [task.result integerValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [unWineAlertView showAlertViewWithTitle:@"Wine Experience Shared"
                                                        message:@"Spreading your wine influence never felt better."
                                              cancelButtonTitle:@"Keep unWineing"
                                                          theme:unWineAlertThemeSuccess];
                    });
                    [Analytics trackUserSharedCheckin:self.object withFriends:sent];
                    NSLog(@"actually sent %lu of %lu", sent, [group count]);
                    
                    return nil;
                }];
            } else {
                actionSheet.shouldDismiss = NO;
                //[unWineAlertView showAlertViewWithTitle:@"Share" message:[NSString stringWithFormat:@"Looks like you didn't select any friends"] theme:unWineAlertThemeRed];
            }
        }
    }
}

- (void)presentMore {
    if(ISVALID(self.delegate.singleObjectId)) {
        self.delegate.singleObject = nil;
        self.delegate.singleObjectId = nil;
        self.delegate.singleObjectType = nil;
        [self.delegate.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    VineCastTVC *feed = [self.delegate.storyboard instantiateViewControllerWithIdentifier:@"feed"];
    [feed setVineCastSingleObject:self.object];
    
    [self.delegate.navigationController pushViewController:feed animated:YES];
}

- (void)deleteNewsFeedObject:(NSString *)newsFeedObjectId{
    NSLog(@"deleteNewsFeedObject - newsFeedObjectId = %@", newsFeedObjectId);
    
    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] init];
    
    parameterDictionary[@"currentUser"] = [User currentUser].objectId;
    parameterDictionary[@"newsPostID"] = newsFeedObjectId;
    
    SHOW_HUD_FOR_VIEW(self.delegate.view);

    [PFCloud callFunctionInBackground:@"deletePost" withParameters:parameterDictionary block:^(id result, NSError *error) {
        HIDE_HUD_FOR_VIEW(self.delegate.view);
        
        if (!error) {
            NSLog(@"Post Deleted, updating user data");
            [[User currentUser] updateUniqueWinesCount];
            
            NSLog(@"Reloading NewsFeed Objects");
            [self.delegate loadObjects];
            
        }else{
            NSLog(@"Error: %@", error);
        }
        
    }];
    
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}

@end
