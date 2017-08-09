//
//  CastProfileVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/12/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastProfileVC.h"
#import "ParseSubclasses.h"
#import "UITableViewController+TabBar.h"
#import "InboxTVC.h"
#import "Conversations.h"
#import "Appboy.h"
#import "AppboyKit.h"
#import "UIBarButtonItem+Badge.h"
#import "UIViewController+Social.h"

#define APPROPRIATE_RELOAD 12
#define ADD_FRIENDS_CELL_TAG 1111
#define ADD_FRIENDS_ALERT_VIEW_TAG 2222
#define UNFRIEND_ALERT_VIEW_TAG 3333
#define CONFIRM_UNFRIEND 4

@interface CastProfileVC () <FriendshipDelegate, unWineActionSheetDelegate>

@end

@implementation CastProfileVC {
    UIView *headerView;
    UILabel *nameLabel;
    UILabel *wineLevelLabel;
    UIButton *face;
    BOOL isUsersFriend;
    BOOL hasAppeared;
}
@synthesize vineCast, profileTable, merits, imageFullVC, friends, cellar, unique;

- (void)showFacebookInvite {
    [self inviteFacebook];
}

- (void) setFollowImage {
    [face setImage:[UIImage imageNamed:@"friendPlus"] forState:UIControlStateNormal];
    self.friendshipButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.rightBarButtonItem = self.friendshipButton;
    isUsersFriend = NO;
}

- (void) setUnfollowImage {
    [face setImage:[UIImage imageNamed:@"friendMinus"] forState:UIControlStateNormal];
    self.friendshipButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.rightBarButtonItem = self.friendshipButton;
    isUsersFriend = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateFrame:NO];
    //self.view.backgroundColor = [UIColor whiteColor];
    self.view.tintColor = UNWINE_RED;
    self.view.exclusiveTouch = NO;
    [self addUnWineTitleView];
    
    if ([self.user isTheCurrentUser] == false) {
        if(!self.friendshipButton) {
            //UIImage *faceImage = [UIImage imageNamed:@"friendPlus"];
            face = [UIButton buttonWithType:UIButtonTypeCustom];
            face.adjustsImageWhenHighlighted = NO;
            [face setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [face setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            //[face setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            face.bounds = CGRectMake(0, 0, 38, 38);
            [face addTarget:self action:@selector(doFriendStuff) forControlEvents:UIControlEventTouchUpInside];
            [self setFollowImage];
        }
        
        self.navigationItem.rightBarButtonItem = self.friendshipButton;
        isUsersFriend = NO;
        
    } else if(self.isProfileTab && !self.navigationItem.rightBarButtonItem && !self.newsButton) {
        LOGGER(@"Setting up news button");
        UIImage *faceImage = [UIImage imageNamed:@"bellIcon"];
        UIButton *face2 = [UIButton buttonWithType:UIButtonTypeCustom];
        face2.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
        [face2 setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [face2 setImage:faceImage forState:UIControlStateNormal];
        [face2 addTarget:self action:@selector(showInboxNotification) forControlEvents:UIControlEventTouchUpInside];
        self.newsButton = [[UIBarButtonItem alloc] initWithCustomView:face2];
        
        self.navigationItem.rightBarButtonItem = self.newsButton;
        
        //UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Stuff" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
        
        //self.navigationItem.rightBarButtonItem = anotherButton;
    }
}

- (BOOL)isRootVC {
    return self == [self.navigationController.viewControllers objectAtIndex:0];
}

- (void)updateFrame:(BOOL)setFrame {
    CGRect table = self.view.frame;
    table.origin.y = 0;
    if(self.isProfileTab && [self isRootVC] && ![self.tabBarController.tabBar isHidden])
        table.size.height = SCREENHEIGHT - 20 - HEIGHT(self.tabBarController.tabBar);
    else
        table.size.height = SCREENHEIGHT - 20;
    
    if(setFrame)
        [self.view setFrame:table];
    else
        self.view.frame = table;
}

// Loads grapes - turn it off
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*if([self.user isTheCurrentUser]) {
     self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
     self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
     [Grapes userUpdateCurrency:^(NSInteger grapes) {
     self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
     }];
     }*/
    
    headerView = [self createHeaderViewWithReactionSection:NO];
    profileTable.delegate = self;
    
    // Appboy stuff
    [self setUpNewsButton:self.newsButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedUpdatedNotificationReceived:)
                                                 name:ABKFeedUpdatedNotification
                                               object:nil];
    
    if (self.isProfileTab) {
        LOGGER(@"Setting profile VC into custom tab bar controller");
        (GET_APP_DELEGATE).ctbc.profileVC = self;
    }

    [self setUpChildViews];
}


- (void)refreshHeaderViewWithReaction:(BOOL)addReactionSection {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetHeaderViews];
        vineCast.tableView.tableHeaderView = [self createHeaderViewWithReactionSection:addReactionSection];
    });
}

- (UIView *)createHeaderViewWithReactionSection:(BOOL)addSection {
    static int reactionsHeight = 40;
    UIView *theView = [[UIView alloc] initWithFrame:
                       CGRectMake(0, 0, WIDTH(self.view),
                                  profileTable.tableView.contentSize.height + ((addSection) ? reactionsHeight : 0))];
    
    [theView addSubview:profileTable.view];
    
    if (addSection) {
        UIView *gridHeader = [[UIView alloc] initWithFrame:
                              CGRectMake(0, profileTable.tableView.contentSize.height, WIDTH(self.view), reactionsHeight)];
        gridHeader.backgroundColor = UNWINE_GRAY_DARK;
        
        //The setup code (in viewDidLoad in your view controller)
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(showReactionWheel:)];
        [gridHeader addGestureRecognizer:singleFingerTap];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH(gridHeader), 40)];
        [headerLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [headerLabel setText:[NSString stringWithFormat:@"%@", [self getReactionForState]]];
        [gridHeader addSubview:headerLabel];
        
        // Need to make the thing tappable
        // Also add a method to change the state and reload the objects
        // Add button label
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH(gridHeader) - 40, -6, 40, 40)];
        [buttonLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:20]];
        [buttonLabel setTextColor:[UIColor whiteColor]];
        [buttonLabel setText:@"..."];
        [gridHeader addSubview:buttonLabel];
        
        [theView addSubview:gridHeader];
    }
    
    theView.clipsToBounds = YES;
    
    return theView;
}

- (NSString *)getReactionForState {
    NSString *s = [NSString stringWithFormat:@"State: %u", self.vineCast.gridState];
    NSString *r = @"All";
    LOGGER(@"Enter");
    LOGGER(s);
    
    if (self.vineCast.gridState == VineCastGridStateGreatWines) {
        r = @"😍 Wines";
    } else if (self.vineCast.gridState == VineCastGridStateGoodWines) {
        r = @"🙂 Wines";
    } else if (self.vineCast.gridState == VineCastGridStateOKWines) {
        r = @"😐 Wines";
    } else if (self.vineCast.gridState == VineCastGridStateBadWines) {
        r = @"🙁 Wines";
    } else if (self.vineCast.gridState == VineCastGridStateAwfulWines) {
        r = @"😞 Wines";
    } else if (self.vineCast.gridState == VineCastGridStateNoReactionWines) {
        r = @"No Reaction";
    }
    
    return r;
}

//The event handling method
- (void)showReactionWheel:(UITapGestureRecognizer *)recognizer
{
    LOGGER(@"Did the thing");
    unWineActionSheet *sheet = [[unWineActionSheet alloc]
                                initWithTitle:@"Select Reaction"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:REACTION_TITLES];
    
    if ([self.user isTheCurrentUser]) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_REACTION_SELECTION_BUTTON);
    } else {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_REACTION_SELECTION_BUTTON_OAU);
    }
    [sheet showFromTabBar: self.navigationController.view];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    LOGGER(@"Enter");
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (!ISVALID(title)) {
        return;
    }
    
    if (([title isEqualToString:@"Cancel"])) {
        // Change the state
        // Reload the data
        if ([self.user isTheCurrentUser]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_REACTION_FILTER_SELECTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_REACTION_FILTER_SELECTION_OAU);
        }
        
    } else {
        if (([title isEqualToString:REACTION_GREAT_WINES])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GREAT_WINES_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GREAT_WINES_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateGreatWines;
            
        } else if (([title isEqualToString:REACTION_GOOD_WINES])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GOOD_WINES_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GOOD_WINES_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateGoodWines;
            
        } else if (([title isEqualToString:REACTION_OK_WINES])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_OK_WINES_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_OK_WINES_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateOKWines;
            
        } else if (([title isEqualToString:REACTION_BAD_WINES])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_BAD_WINES_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_BAD_WINES_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateBadWines;
            
        } else if (([title isEqualToString:REACTION_AWFUL_WINES])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_AWFUL_WINES_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_AWFUL_WINES_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateAwfulWines;
            
        } else if (([title isEqualToString:REACTION_NO_REACTION])) {
            // Change the state
            // Reload the data
            if ([self.user isTheCurrentUser]) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_NO_REACTION_FILTER);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_NO_REACTION_FILTER_OAU);
            }
            self.vineCast.gridState = VineCastGridStateNoReactionWines;
            
        }
        LOGGER(@"Refreshing vinecast tableview");
        [self.vineCast refreshFilteredObjects];
        [self.vineCast.tableView reloadData];
        [self refreshHeaderViewWithReaction:YES];
    }
}


// Setups up UI before it shows
// Loads all the profile counts asynchronously


// Dismiss if no user is available
// Loads friendship status asynchronously
// Shows popovers
// Should load everything asynchronously here
- (void)viewDidAppear:(BOOL)animated {
    LOGGER(@"Enter");
    [super viewDidAppear:animated];
    
    if(![User currentUser]) {
        LOGGER(@"something sketchy happened, dimissing tabbar");
        [[MainVC sharedInstance] dismissPresented:YES];
        return;
    }
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    if(self.isProfileTab) {
        self.shouldRefresh = NO;
        if ([self.user isTheCurrentUser] == FALSE) {
            LOGGER(@"Not current user in PROFILE TAB. Setting user as current user");
            [tasks addObject:[self setProfileUser:[User currentUser]]];
        }
    }
    
    if (self.profileTable) {
        LOGGER(@"Adding update count task");
        [tasks addObject:[profileTable updateCounts]];
    }
    
    if (self.vineCast) {
        LOGGER(@"Adding loadObject task");
        [tasks addObject:[self.vineCast loadObjects]];
    }
    
    if(![self.user isAnonymous] && ![self.user isTheCurrentUser]) {
        LOGGER(@"Adding updateFriendshipStatus task");
        [tasks addObject:[self updateFriendshipStatus:self.user]];
    }
    
    // Appboy stuff
    if (self.isProfileTab) {
        LOGGER(@"Refreshing Appboy Newsfeed");
        [self refreshUnWineNewsNewsFeed];
    }
    
    LOGGER(@"Executing all UI tasks");
    
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Finished all the UI tasks");
        
        if (t.error) {
            NSString *s = [NSString stringWithFormat:@"Something went wrong with UI Tasks:\n%@", t.error];
            LOGGER(s);
        }
        
        [self showPopover];
        hasAppeared = YES;
        
        if(![self.user isTheCurrentUser]) {
            return nil;
        }
        
        NSInteger profileViewCount = [User hasSeen:WITNESS_PROFILE_VIEW_COUNT] ? [[User getWitnessValue:WITNESS_PROFILE_VIEW_COUNT] integerValue] : 0;
        [User setWitnessValue:@(profileViewCount + 1) key:WITNESS_PROFILE_VIEW_COUNT];
        
        if(!self.user.birthday && profileViewCount == 3) {
            if(![[PopoverVC sharedInstance] isDisplayed]) {
                CGRect placer = self.profileTable.settingsButton.frame;
                placer.origin.x += 4;
                
                [[PopoverVC sharedInstance] showFrom:self.navigationController
                                          sourceView:self.profileTable.tableView
                                          sourceRect:placer
                                                text:@"Want to earn the birthday merit? Well we aren't mind readers! Tap the settings cog and edit your profile!"];
                [PopoverVC sharedInstance].delegate = self;
            } else {
                LOGGER(@"Stuff");
                [User setWitnessValue:@(2) key:WITNESS_PROFILE_VIEW_COUNT];
            }
            
            //[unWineAlertView showAlertViewWithTitle:@"Hey!" message:@"Want to earn the birthday merit? Well we aren't mind readers! Tap the settings cog and edit your profile!"];
        }
        
        return nil;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //self.navigationController.navigationBar.topItem.title = @"Back";
    
    [self updateBarButtonItems:1];
}

- (void)showPopover {
    if(![User hasSeen:WITNESS_ALERT_MERIT] && ![[PopoverVC sharedInstance] isDisplayed]) {
        CGRect placer = [self.profileTable getBoundsForButtonAtIndex:3];
        placer.origin.y += NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT;
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.view
                                  sourceRect:placer
                                        text:@"Merits are collectible shiny things that you get from checking in various wines. Some merits are seasonal and some are super exclusive, so drink up!"];
        [PopoverVC sharedInstance].delegate = self;
        
        [User witnessed:WITNESS_ALERT_MERIT];
        ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_PROFILE_MERITS_BUBBLE);
    } else if(![User hasSeen:WITNESS_ALERT_UNIQUE_WINES] && ![[PopoverVC sharedInstance] isDisplayed]) {
        CGRect placer = [self.profileTable getBoundsForButtonAtIndex:1];
        placer.origin.y += NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT;
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.view
                                  sourceRect:placer
                                   direction:UIPopoverArrowDirectionUp
                                        text:@"This is where all the unique wines you have ever tried will be. Unique wines are wines you have tried for the first time."];
        
        [User witnessed:WITNESS_ALERT_UNIQUE_WINES];
    }
}

- (void)popoverDismissed {
    [self performSelector:@selector(showPopover) withObject:nil afterDelay:.1];
}

- (BOOL)hidesBottomBarWhenPushed {
    return self != [self.navigationController.viewControllers objectAtIndex:0];
}

- (BFTask *)setProfileUser:(User *)user {
    self.user = user;
    __block BOOL isCurrentUser = [self.user isTheCurrentUser];
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    BFTask *fetchTask = isCurrentUser ? [self.user fetchInBackground] : [BFTask taskWithResult:@(true)];
    NSString *s = [NSString stringWithFormat:@"Fetching current user = %@", isCurrentUser ? @"YES" : @"NO"];
    LOGGER(s);
    
    [fetchTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Fetched user");
        NSString *s = [NSString stringWithFormat:@"isProfileTab = %@", self.isProfileTab ? @"YES" : @"NO"];
        LOGGER(s);
        
        if (profileTable == nil) {
            LOGGER(@"Allocating Profile");
            profileTable = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile2"];
        }
        profileTable.delegate = self;
        
        //self.view.backgroundColor = profileTable.tableView.backgroundColor;
        
        if (vineCast == nil) {
            LOGGER(@"Allocating VineCast");
            vineCast = [[UIStoryboard storyboardWithName:@"VineCast" bundle:nil] instantiateViewControllerWithIdentifier:@"feed"];
        }
        //[vineCast adjustFrame];
        vineCast.singleUser = user;
        vineCast.profileTVC = profileTable;
        s = [NSString stringWithFormat:@"vineCast.profileTVC: %@", vineCast.profileTVC];
        LOGGER(s);
        
        if (merits == nil) {
            merits = [[UIStoryboard storyboardWithName:@"Merits" bundle:nil] instantiateInitialViewController];
        }
        merits.meritMode = MeritModeDiscoverUser;
        merits.earnedMerits = [[NSMutableArray alloc] init];
        [merits.earnedMerits addObjectsFromArray:user.earnedMerits];
        merits.earnedOnly = NO;
        merits.profileTVC = profileTable;
        
        /*if(friends == nil)
         friends = [[SearchTVC alloc] init];
         friends.mode = SearchTVCModeUsers;
         friends.user = user;
         //friends.profileTVC = profileTable;
         */
        
        if (cellar == nil) {
            cellar = [self.storyboard instantiateViewControllerWithIdentifier:@"wishList"];
        }
        cellar.user = user;
        cellar.profileTVC = profileTable;
        [cellar loadObjects];
        
        if (unique == nil) {
            unique = [self.storyboard instantiateViewControllerWithIdentifier:@"unique"];
        }
        unique.user = user;
        unique.profileTVC = profileTable;
        
        profileTable.profileUser = user;
        LOGGER(@"set profile user");
        
        if (isCurrentUser && !t.error && t.result) {
            self.user = (User *)t.result;
            vineCast.singleUser = self.user;
            merits.earnedMerits = [[NSMutableArray alloc] init];
            [merits.earnedMerits addObjectsFromArray:self.user.earnedMerits];
            friends.user = self.user;
            cellar.user = self.user;
            unique.user = self.user;
        }
        
        [theTask setResult:@(TRUE)];
    
        return nil;
    }];

    return theTask.task;
}

- (void)updateBarButtonItems:(CGFloat)alpha {
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationController.navigationItem.titleView.alpha = alpha;
    self.grapesButton.customView.alpha = alpha;
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)setUpChildViews {
    // VineCast, Merits, Friends
    if (profileTable == nil) {
        LOGGER(@"Allocating Profile");
        profileTable = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile2"];
    }
    profileTable.delegate = self;
    
    if (vineCast == nil) {
        LOGGER(@"Allocating VineCast");
        vineCast = [[UIStoryboard storyboardWithName:@"VineCast" bundle:nil] instantiateViewControllerWithIdentifier:@"feed"];
    }
    
    if (merits == nil) {
        LOGGER(@"Allocating Merits");
        merits = [[UIStoryboard storyboardWithName:@"Merits" bundle:nil] instantiateInitialViewController];
    }
    
    if (cellar == nil) {
        LOGGER(@"Allocating Wish List");
        cellar = [self.storyboard instantiateViewControllerWithIdentifier:@"wishList"];
    }
    
    if (unique == nil) {
        LOGGER(@"Allocating Unique");
        unique = [self.storyboard instantiateViewControllerWithIdentifier:@"unique"];
    }
    
    [vineCast.tableView setContentInset:UIEdgeInsetsMake(NAVIGATION_BAR_HEIGHT, 0, [self isRootVC] ? 40 : 0, 0)];
    [vineCast.tableView setScrollIndicatorInsets:vineCast.tableView.contentInset];
    
    [self resetHeaderViews];
    vineCast.tableView.tableHeaderView = headerView;
    
    [self removeTables];
    
    [self addChildViewController:vineCast];
    [self.view addSubview:vineCast.view];
    [vineCast didMoveToParentViewController:self];
    self.view.backgroundColor = vineCast.view.backgroundColor;
    [self updateFrame:YES];
}

- (void)buttonPressed:(UIButton *)button {
    LOGGER(@"Enter");
    if (button == nil) {
        LOGGER(@"Something happened! Do nothing");
        return;
    }
    
    if(button.tag == 1) {
        //unique.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        //[self.navigationController pushViewController:unique animated:YES];
        if ([self.user isTheCurrentUser]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_LIST_SECTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_LIST_SECTION_ON_ANOTHER_USER);
        }
        
        [self resetHeaderViews];
        self.vineCast.state = VineCastStateGlobal;
        self.vineCast.gridMode = false;
        vineCast.tableView.tableHeaderView = [self createHeaderViewWithReactionSection:NO];
        //[self.vineCast loadObjects];
        // Only update UI, not data
        [self.vineCast.tableView reloadData];
        
    } else if(button.tag == 2) {
        //friends.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        //movingToFriends = YES;
        //[self.navigationController pushViewController:friends animated:YES];
        if ([self.user isTheCurrentUser]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_REACTIONS_SECTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_REACTIONS_SECTION_ON_ANOTHER_USER);
        }
        
        self.vineCast.gridMode = YES;
        [self resetHeaderViews];
        vineCast.tableView.tableHeaderView = [self createHeaderViewWithReactionSection:YES];
        //[self.vineCast loadObjects];
        // Only update UI, not data
        //vineCast.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [self.vineCast.tableView reloadData];
        
    } else if(button.tag == 3) {
        //cellar.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        if ([self.user isTheCurrentUser]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_CELLAR_SECTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_CELLAR_SECTION_ON_ANOTHER_USER);
        }
        
        [self.navigationController pushViewController:cellar animated:YES];
        
    } else if(button.tag == 4) {
        if ([self.user isTheCurrentUser]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_MERITS_SECTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_MERITS_SECTION_ON_ANOTHER_USER);
        }
        
        [self.navigationController pushViewController:merits animated:YES];
    }
}

- (void)resetHeaderViews {
    vineCast.tableView.tableHeaderView = nil;
    //cellar.tableView.tableHeaderView = nil;
    merits.tableView.tableHeaderView = nil;
    //friends.tableView.tableHeaderView = nil;
    //unique.tableView.tableHeaderView = nil;
}

- (void)removeTables {
    if(merits.view.superview)
        [merits.view removeFromSuperview];
    
    if(cellar.view.superview)
        [cellar.view removeFromSuperview];
    
    if(friends.view.superview)
        [friends.view removeFromSuperview];
    
    if(vineCast.view.superview)
        [vineCast.view removeFromSuperview];
    
    if(unique.view.superview)
        [unique.view removeFromSuperview];
}

- (void)showLeaderboards {
    [Grapes showLeaderboards:self.navigationController];
}

- (void)showPurchases {
    [Grapes showPurchases:self.navigationController];
}

- (UIView *)getPresentationView {
    return self.navigationController.view;
}

- (void)doFriendStuff {
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [user promptGuest:self];
        return;
    }
    
    if(isUsersFriend) {
        [Friendship showUnfriendDialogue:self returnTag:CONFIRM_UNFRIEND];
    } else {
        [Friendship sendFriendRequest:self.user fromController:self];
    }
}

- (void)rightButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == CONFIRM_UNFRIEND) {
        [Friendship confirmUnfriend:self.user fromController:self];
    }
}

- (BFTask *)updateFriendshipStatus:(User *)user {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *curr = [User currentUser];
    BFTask *task = [self.user isTheCurrentUser] ?
    [BFTask taskWithResult:@(TRUE)] : [self.user isFriendsWithUser:curr];
    
    //NSArray *tasks = @[fetchTask, areFriendsTask];
    [task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        BOOL areFriends = [task.result boolValue];
        
        if(!areFriends) {
            [self setFollowImage];
            isUsersFriend = NO;
        } else {
            [self setUnfollowImage];
            isUsersFriend = YES;
        }
        
        [theTask setResult:@(TRUE)];
        
        return nil;
    }];
    
    return theTask.task;
}


- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)source {
    
    if ([UIImagePickerController isSourceTypeAvailable:source] == NO) {
        LOGGER(@"Source not available");
        return;
    }
    
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType = source;
    
    // Delegate is self
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.userInteractionEnabled = YES;
    imagePicker.view.tintColor = [UIColor whiteColor];
    imagePicker.navigationController.view.tintColor = [UIColor whiteColor];
    
    // Show image picker
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"didFinishPickingMediaWithInfo");
    
    UIImage *image = info[UIImagePickerControllerEditedImage];// = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        User *user = [User currentUser];
        [user setProfileImageWithImage:image];
        user.facebookPhotoURL = nil;
        
        SHOW_HUD_FOR_VIEW(self.navigationController.view);
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            HIDE_HUD_FOR_VIEW(self.navigationController.view);
            if(!error)
                [self.profileTable configureUserImage];
        }];
    }];
}

- (void)addUnWineTitleView {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.title = @"Back";
    
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    //self.navigationItem.titleView = imageView;
    self.navigationItem.title = @"Cellar Profile";
}

- (void)setTitleView:(NSString *)title {
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"Edit Profile";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * AppBoy Stuff
 */
#pragma mark - News Button Stuff

- (void)feedUpdatedNotificationReceived:(NSNotification *)notification {
    //NSLog(@"%s - Checking to see if update was successful", FUNCTION_NAME);
    LOGGER(@"Enter");
    BOOL updateIsSuccessful = [[notification.userInfo objectForKey:ABKFeedUpdatedIsSuccessfulKey] boolValue];
    
    if (updateIsSuccessful && [self.user isTheCurrentUser]) {
        LOGGER(@"Updating");
        [self updateNewsButtonWithTimer:NO];
        
    } else if (updateIsSuccessful == FALSE) {
        LOGGER(@"Update WAS NOT successful");
    }
}

- (void)setUpNewsButton:(UIBarButtonItem *) newsButton {
    newsButton.shouldHideBadgeAtZero = YES;
    //newsButton.shouldAnimateBadge = YES;
}

- (void)refreshUnWineNewsNewsFeed {
    LOGGER(@"Enter");
    [[Appboy sharedInstance] requestFeedRefresh];
}

- (NSInteger)getAppboyCount {
    return [[Appboy sharedInstance].feedController unreadCardCountForCategories:ABKCardCategoryAll];
}

- (NSTimeInterval)timeStamp {
    return [[NSDate date] timeIntervalSince1970];
}

- (void)updateNewsButtonWithTimer:(BOOL)delay {
    if (![self.user isTheCurrentUser]) {
        return;
    }
    
    if (delay) {
        [self updateNewsButton:self.lastUpdateNewsButtonBadge];
        return;
    }
    
    NSArray *tasks = [InboxTVC getInboxTasks:YES];
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        BFTask *task1 = [tasks objectAtIndex:0];
        BFTask *task2 = [tasks objectAtIndex:1];
        BFTask *task3 = [tasks objectAtIndex:2];
        
        if(!task1.error && !task2.error && !task3.error) {
            NSInteger count1 = (task1.result != nil) ? [task1.result count] : 0;
            NSInteger count2 = (task2.result != nil) ? [task2.result count] : 0;
            NSInteger count3 = 0;
            for(Conversations *convo in task3.result) {
                if([convo isUnread] && !convo.hidden)
                    count3++;
            }
            //NSLog(@"count3 %li", (long)count3);
            
            [self updateNewsButton:(count1 + count2 + count3 + [self getAppboyCount])];
        } else {
            [self updateNewsButton:self.lastUpdateNewsButtonBadge];
        }
        return nil;
    }];
    
}

- (void)updateNewsButton:(NSInteger)number {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"updateNewsButton - %li", (long)number);
        self.lastUpdateNewsButtonBadge = number;
        
        if (self.newsButton) {
            self.newsButton.badge.layer.masksToBounds = YES;
            self.newsButton.badgeValue = [NSString stringWithFormat:@"%lu", (long)number];
        }
        
        if (number == 0) {
            [[(GET_APP_DELEGATE).ctbc.tabBar.items objectAtIndex:2] setBadgeValue:nil];
        } else {
            [[(GET_APP_DELEGATE).ctbc.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%lu", (long)number] ];
        }
        //[[self.tabBar.items objectAtIndex:INBOX_TAB_INDEX] setBadgeValue: @"0"];
        
        if([User currentUser])
            [UIApplication sharedApplication].applicationIconBadgeNumber = number;
        else
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    });
}

#pragma mark - Feed Controller Stuff

- (void)showNewsFeedController:(CastInboxDefault)openTo {
    [(GET_APP_DELEGATE).ctbc showNewsFeedController:openTo];
}

- (void)showInboxNotification {
    [self showNewsFeedController:CastInboxDefaultNotification];
}

- (void)showInboxConversation {
    [self showNewsFeedController:CastInboxDefaultConversation];
}

- (void)showDailyToast {
    [self showNewsFeedController:CastInboxDefaultDailyToast];
}


@end
