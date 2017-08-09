//
//  AWFooterCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWFooterCell.h"
#import "CastDetailTVC.h"
#import "ParseSubclasses.h"

#define ADD_WISH_LIST @"Add to Wish List"
#define REMOVE_WISH_LIST @"Remove from Wish List"
#define PENDING_WISH_LIST REMOVE_WISH_LIST
//@"Pending Checkin"

@implementation AWFooterCell
@synthesize hasSetup, myPath, fieldEditor, accessoryView, editView, canModify, wine;
@synthesize lastEdit, basicLabel, cellarButton, shareButton;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    [super setup:indexPath];
    
    if(!hasSetup) {
        hasSetup = YES;
        
        basicLabel.backgroundColor = [UIColor clearColor];
        basicLabel.textColor = [UIColor whiteColor];
        
        shareButton.backgroundColor = [UIColor whiteColor];
        shareButton.layer.borderWidth = 2;
        shareButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        shareButton.layer.cornerRadius = 6;
        shareButton.layer.masksToBounds = YES;
        shareButton.clipsToBounds = YES;
        [shareButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
        
        cellarButton.backgroundColor = [UIColor whiteColor];
        cellarButton.layer.borderWidth = 2;
        cellarButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        cellarButton.layer.cornerRadius = 6;
        cellarButton.layer.masksToBounds = YES;
        cellarButton.clipsToBounds = YES;
        [cellarButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
        
        lastEdit.backgroundColor = [UIColor clearColor];
        [lastEdit setTintColor:[UIColor whiteColor]];
        [lastEdit setImage:SMALL_COG_ICON forState:UIControlStateNormal];
        [lastEdit.imageView setTintColor:[UIColor whiteColor]];
        [lastEdit.titleLabel setTextAlignment:NSTextAlignmentCenter];
        //[lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"N/A"] forState:UIControlStateNormal];
        [lastEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lastEdit setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        lastEdit.alpha = 0;
    }
}

- (void)configure:(unWine *)wineObject {
    [super configure:wineObject];
    self.wine = wineObject;
    
    User *user = [User currentUser];
    
    //if(user[@"cellar"] != nil && [user[@"cellar"] count] > 0) {
    if([user hasCellar]) {
        for(NSString *objectId in user.cellar) {
            [user.theCellar addObject:[PFObject objectWithoutDataWithClassName:[unWine parseClassName] objectId:objectId]];
        }
        user.cellar = [[NSMutableArray alloc] init];
        [user saveInBackground];
    }
    
    [self configureCellarButton];
    //[self configureLastEdit];
}

- (void)configureCellarButton {
    User *user = [User currentUser];
    [[user hasWineInWishList:self.wine] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        
        BOOL inWishList = t.result.boolValue;
        [cellarButton setTitle:(inWishList ? REMOVE_WISH_LIST : ADD_WISH_LIST)
                      forState:UIControlStateNormal];
        
        return nil;
    }];
}

- (void)configureLastEdit {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    
    [parent getLastEdit:^(PFObject *last) {
        if(last == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(parent.registers != nil && [parent.registers count] > 0)
                    [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"You"] forState:UIControlStateNormal];
                else
                    [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"N/A"] forState:UIControlStateNormal];
            });
        } else {
            [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", [last[@"editor"][@"canonicalName"] capitalizedString]] forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)cellarIt:(id)sender {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    User *user = [User currentUser];
    
    if ([user isAnonymous]) {
        [user promptGuest:parent];
        return;
    }
    
    if (parent.isNew) {
        cellarButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self configureCellarButton];
        return;
    }
    
    BFTask *wishlistTask = nil;
    
    if ([cellarButton.titleLabel.text isEqualToString:ADD_WISH_LIST]) {
        LOGGER(@"Adding wine to wish list");
        wishlistTask = [user addWineToCellar:self.wine];
    } else {
        LOGGER(@"Removing wine from wish list");
        wishlistTask = [user removeWineFromCellar:self.wine];
    }
    
    [wishlistTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something went wrong adding/removing wine from wish list");
            LOGGER(t.error);
            
        } if ([cellarButton.titleLabel.text isEqualToString:ADD_WISH_LIST]) {
            LOGGER(@"Added wine to wish list");
            [cellarButton setTitle:REMOVE_WISH_LIST forState:UIControlStateNormal];

        } else {
            LOGGER(@"Removed wine from wish list");
            [cellarButton setTitle:ADD_WISH_LIST forState:UIControlStateNormal];
        }

        return nil;
    }];
}

static NSString *dialogShare = @"Send";

- (IBAction)shareIt:(id)sender {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    
    SHOW_HUD_FOR_VIEW(parent.navigationController.view);
    [[[User currentUser] getFriends] continueWithBlock:^id(BFTask *task) {
        HIDE_HUD_FOR_VIEW(parent.navigationController.view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL shouldAddShare = YES;
            NSMutableArray *content = [ScrollElementView scrollElementsFrom:task.result];
            
            if([content count] == 0) {
                shouldAddShare = NO;
            } else if([content count] > 1) {
                [content insertObject:[ScrollElementView makeElementFromObject:[ScrollElement selectAll]] atIndex:0];
            }
            
            [content addObject:[ScrollElementView makeElementFromObject:[ScrollElement inviteFriends]]];
            
            unWineActionSheet *actionSheet = [[unWineActionSheet alloc]
                                              initWithTitle:@"Recommend Wine"
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              customContent:content];
            
            if(shouldAddShare)
                actionSheet.otherButtonTitles = @[dialogShare];
            
            //if(parent.pushedFromNotification)
                [actionSheet showFromTabBar:parent.navigationController.view];
            //else
            //    [actionSheet showFromTabBar:parent.tabBarController.view];
        });
        return nil;
    }];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    //NSLog(@"Method is getting called");
    
    if([buttonTitle isEqualToString:dialogShare]) {
        NSMutableArray *content = [actionSheet getSelectedElements];
        NSMutableArray *group = [[NSMutableArray alloc] init];
        if(content != nil) {
            for(ScrollElementView *element in content)
                if([element.object isKindOfClass:[User class]])
                    [group addObject:(User *)element.object]; //Get user objects from selected elements
            
            if([group count] > 0) {
                NSString *pushMessage = [NSString stringWithFormat:@"%@ recommended a wine to you!", [[User currentUser] getName]];
                SHOW_HUD_FOR_VIEW(parent.navigationController.view);
                [[[Push sendPushNotification:NotificationTypeRecommendations toGroup:[BFTask taskWithResult:[group copy]] withMessage:pushMessage withURL:[NSString stringWithFormat:@"unwineapp://wine/%@", wine.objectId]] continueWithBlock:^id(BFTask *task) {
                    
                    if(task.error) {
                        HIDE_HUD_FOR_VIEW(parent.navigationController.view);
                        [unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
                        return nil;
                    }
                    
                    LOGGER(task.result);
                    NSArray *childTasks = task.result;
                    
                    NSMutableArray *notificationObjectTasks = [[NSMutableArray alloc] init];
                    
                    for(id child in childTasks) {
                        if(child && [child isKindOfClass:[User class]]) {
                            NSLog(@"adding notification %@", [(User *)child objectId]);
                            
                            [notificationObjectTasks addObject:[Notification createRecommendationObjectFor:wine andUser:(User *)child]];
                        }
                    }
                    
                    return [[BFTask taskForCompletionOfAllTasks:notificationObjectTasks] continueWithBlock:^id(BFTask *task) {
                        return [BFTask taskWithResult:@([notificationObjectTasks count])];
                    }];
                }] continueWithBlock:^id(BFTask *task) {
                    HIDE_HUD_FOR_VIEW(parent.navigationController.view);
                    
                    NSInteger sent = [task.result integerValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [unWineAlertView showAlertViewWithTitle:@"Wine Experience Shared"
                                                        message:@"Spreading your wine influence never felt better."
                                              cancelButtonTitle:@"Keep unWineing"
                                                          theme:unWineAlertThemeSuccess];
                    });

                    [Analytics trackUserSharedWine:wine withFriends:sent];
                    NSLog(@"actually sent %lu of %lu", sent, [group count]);
                    
                    return nil;
                }];
            } else {
                actionSheet.shouldDismiss = NO;
                //[unWineAlertView showAlertViewWithTitle:@"Recommendation" message:[NSString stringWithFormat:@"Looks like you didn't select any friends"] theme:unWineAlertThemeRed];
            }
        }
    }
}

- (IBAction)viewEdits:(id)sender {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    CastEditTVC *history = [parent.storyboard instantiateViewControllerWithIdentifier:@"history"];
    
    [parent getLastEdit:^(PFObject *last) {
        if(last == nil) {
            if(parent.registers != nil && [parent.registers count] > 0) {
                NSMutableArray *passedResults = [[NSMutableArray alloc] init];
                
                for(NSString *key in parent.registers) {
                    PFObject *result = [CastCheckinTVC createObject:nil withField:key asValue:[parent.registers objectForKey:key]];
                    [passedResults addObject:result];
                }
                
                history.results = passedResults;
                if([passedResults count] > 0)
                    [parent.navigationController pushViewController:history animated:YES];
            }
        } else {
            history.wine = self.wine;
            [parent.navigationController pushViewController:history animated:YES];
        }
    }];
    
    /*[parent getRecords:^{
        [self configureLastEdit];
    }];*/
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}

@end
