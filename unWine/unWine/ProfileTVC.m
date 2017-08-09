//
//  CastProfileTVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/8/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ProfileTVC.h"
#import "ParseSubclasses.h"
#import <AddressBook/AddressBook.h>
#import "RegistrationTVC.h"
#import "MainLogInViewController.h"
#import "MessengerVC.h"
#import "SettingsTVC.h"
#import "LoginVC.h"
#import "EditProfileView.h"
#import "WineProfileTVC.h"
#import "UIViewController+Social.h"
#import "UserFriendsTVC.h"

#define WINE_WORLD_ICON     [UIImage imageNamed:@"newWorldIcon"]
#define WINE_PROFILE_ICON   [UIImage imageNamed:@"statsLogo"]

//#define buttonTitles @[@"FRIENDS", @"WINES", @"CELLAR", @"MERITS"]
//#define buttonTitles @[@"REACTIONS", @"TIMELINE", @"CELLAR", @"MERITS"]
#define buttonTitles @[@"TIMELINE", @"REACTIONS", @"WISH LIST", @"MERITS"]

@import SafariServices;

@implementation ProfileTVC {
    MFMessageComposeViewController *_message;
    MFMailComposeViewController *_mail;
    EditProfileView *editProfileView;
    NSInteger logoViewAlpha;
}
@synthesize vineCast, imageFullVC, friendsVC;

- (void)viewWillAppear:(BOOL)animated {
    if(self.profileUser != nil)
        [self configureLocationLabel:self.profileUser];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideEditProfileView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.view.tintColor = UNWINE_RED;
    
    [self basicAppeareanceSetup];
    //self.view.backgroundColor = [UIColor whiteColor];
    
    if(self.profileUser != nil)
        [self configureProfile:self.profileUser];
    
    //[self scrollTop];
}

- (void)configureProfile:(User *)user {
    
    if (user == nil) {
        user = self.profileUser;
    }

    if (user == nil) {
        return;
    }

    if(!self.profileImage) {
        self.profileImage = [[PFImageView alloc] initWithFrame:(CGRect){(SCREEN_WIDTH - 108) / 2, 8, {108, 108}}];
        [self.view addSubview:self.profileImage];
    }
    self.profileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileImage.layer.borderWidth = 3.0f;
    self.profileImage.layer.cornerRadius = SEMIWIDTH(self.profileImage);
    [self configureUserImage];
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.userInteractionEnabled = YES;
    self.profileImage.clipsToBounds = YES;
    
    self.profileDetails.backgroundColor = [UIColor clearColor];
    [self.profileView setBackgroundColor:self.delegate.vineCast.view.backgroundColor];
    self.profileView.clipsToBounds = YES;
    self.profileView.userInteractionEnabled = YES;
    self.profileView.exclusiveTouch = NO;
    self.view.exclusiveTouch = NO;
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.clipsToBounds = NO;
    [self.settingsButton setFrame:CGRectMake(12, 12, 48, 48)];
    if([user isTheCurrentUser]) {
        [self.settingsButton setImage:[UIImage imageNamed:@"settingsicon"] forState:UIControlStateNormal];
        [self.settingsButton addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.settingsButton setImage:[UIImage imageNamed:@"bubbleIcon"] forState:UIControlStateNormal];
        [self.settingsButton addTarget:self action:@selector(messagesPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    self.settingsButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.settingsButton setContentMode:UIViewContentModeScaleAspectFit];
    self.settingsButton.layer.shadowColor = [[UIColor lightTextColor] CGColor];
    self.settingsButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.settingsButton.layer.shadowOpacity = 1;
    self.settingsButton.layer.shadowRadius = 1;
    
    if([user isTheCurrentUser])
        [self.view addSubview:self.settingsButton];
    
    /*self.worldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.worldButton.clipsToBounds = NO;
    self.worldButton.tintColor = [UIColor whiteColor];
    [self.worldButton setFrame:CGRectMake(SCREEN_WIDTH - 48 - 12, 12, 48, 48)];
    [self.worldButton setImage:WINE_WORLD_ICON forState:UIControlStateNormal];
    [self.worldButton addTarget:self action:@selector(worldPressed) forControlEvents:UIControlEventTouchUpInside];
    self.worldButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.worldButton setContentMode:UIViewContentModeScaleAspectFit];
    self.worldButton.layer.shadowColor = [[UIColor lightTextColor] CGColor];
    self.worldButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.worldButton.layer.shadowOpacity = 1;
    self.worldButton.layer.shadowRadius = 1;
    
    if([user isTheCurrentUser])
        [self.view addSubview:self.worldButton];*/
    
    self.friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.friendsButton.clipsToBounds = NO;
    self.friendsButton.tintColor = [UIColor whiteColor];
    [self.friendsButton setFrame:CGRectMake(SCREEN_WIDTH - 48 - 12, 12/* + Y2(self.worldButton) + HEIGHT(self.worldButton)*/, 48, 48)];
    [self.friendsButton setImage:[UIImage imageNamed:@"friends"] forState:UIControlStateNormal];
    [self.friendsButton addTarget:self action:@selector(showFriends) forControlEvents:UIControlEventTouchUpInside];
    self.friendsButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.friendsButton setContentMode:UIViewContentModeScaleAspectFit];
    self.friendsButton.layer.shadowColor = [[UIColor lightTextColor] CGColor];
    self.friendsButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.friendsButton.layer.shadowOpacity = 1;
    self.friendsButton.layer.shadowRadius = 1;
    
    if([user isTheCurrentUser])
        [self.view addSubview:self.friendsButton];
    
    BFTask *friendTask = [user getFriendUsers];
    //BFTask *checkinTask = [self.delegate.vineCast getVineCastTask];
    //BFTask *uniqWinesTask = [self.delegate.unique getUniqWinesTask];
    //BFTask *cellarTask = [self.delegate.cellar getCellarTask];
    //BFTask *meritTask = [self.delegate.merits getMeritsTask];
    
    //SHOW_HUD;
    NSArray *tasks = @[friendTask];
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        NSArray *friends = friendTask.result;
        if(friends == nil)
        friends = [[NSArray alloc] init];
        //NSArray *uniqWines = [self.delegate.unique filterNewsFeedIntoWines:uniqWinesTask.result];
        //NSNumber *checkins = checkinTask.result;
        //NSNumber *cellar = cellarTask.result;
        //NSNumber *merits = meritTask.result;
        
        //NSInteger grapes = user.currency;
        [self configureStuff:@[friends, @([self.delegate.unique uniqueCount]), @([self.delegate.cellar cellarCount]), @([self.profileUser.earnedMerits count])]];
        //HIDE_HUD;
        
        return nil;
    }];
}

- (void)showFriends {
    /*SearchTVC *friends = [[SearchTVC alloc] init];
    friends.mode = SearchTVCModeUsers;
    friends.user = self.profileUser;
    friends.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self.delegate.navigationController pushViewController:friends animated:YES];
     */
    
    // [_user getFriendUsers]
    @try {
        LOGGER(@"Hola");
        UserFriendsTVC *vc = ((UserFriendsTVC *)[[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"UserFriendsTVC"]);
    
        [self.delegate.navigationController pushViewController:vc animated:YES];
        //[self.delegate.navigationController performSegueWithIdentifier:@"UserFriendsTVCSegue" sender:self.delegate];
        LOGGER(@"Did the segue");
    } @catch (NSException *exception) {
        LOGGER(@"Something happened");
        LOGGER(exception);
    }
}

- (void)configureStuff:(NSArray *)data {
    User *user = self.profileUser;
    NSArray *friends = [data objectAtIndex:0];
    NSInteger uniqueCount = [[data objectAtIndex:1] intValue];
    //NSArray *uniqWines = [data objectAtIndex:1];
    NSInteger cellarCount = [[data objectAtIndex:2] intValue];
    NSInteger meritCount = [[data objectAtIndex:3] intValue];
    
    if(self.nameLabel == nil)
        self.nameLabel = [[UILabel alloc] init];
    NSString *name = [user getName];
    self.nameLabel.text = ISVALID(name) ? name : @"Guest";
    self.nameLabel.textColor = [UIColor whiteColor];
    [self.nameLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    [self.profileDetails addSubview:self.nameLabel];
    self.nameLabel.numberOfLines = 2;
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    
    if(self.wineLevelLabel == nil)
        self.wineLevelLabel = [[UILabel alloc] init];
    [self.wineLevelLabel setFont:[UIFont fontWithName:@"OpenSans-Italic" size:14]];
    self.wineLevelLabel.textColor = [UIColor whiteColor];
    [self configureWineLevelLabel:user];
    [self.profileDetails addSubview:self.wineLevelLabel];
    self.wineLevelLabel.numberOfLines = 1;
    [self.wineLevelLabel setTextAlignment:NSTextAlignmentCenter];
    
    if(self.grapeFriendLabel == nil)
        self.grapeFriendLabel = [[UIButton alloc] init];
    [self.grapeFriendLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Italic" size:14]];
    [self.grapeFriendLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self configureGrapeFriendLabel:friends];
    //[self.profileDetails addSubview:self.grapeFriendLabel];
    self.grapeFriendLabel.titleLabel.numberOfLines = 1;
    [self.grapeFriendLabel.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.grapeFriendLabel addTarget:self action:@selector(showFriendView) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.locationButton == nil)
        self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.locationButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Italic" size:14]];
    [self.locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self configureLocationLabel:user];
    [self.profileDetails addSubview:self.locationButton];
    self.locationButton.titleLabel.numberOfLines = 1;
    [self.locationButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if([user isTheCurrentUser])
        [self.locationButton addTarget:self action:@selector(updateLocationPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.profileDetails setFrame:CGRectMake(X2(self.profileDetails), Y2(self.profileDetails), SCREEN_WIDTH - X2(self.profileDetails) * 2, 80)];
    [self.profileDetails setPadding:PaddingMake(10, 0, 0, 0)];
    [self.profileDetails update];
    
    //UIView *grapesView = [Grapes getCustomView:[user currency] delegate:self];
    //int grapesViewY = SEMIHEIGHT(self.profileImage) + Y2(self.profileImage) - SEMIHEIGHT(grapesView);
    //[grapesView setFrame:CGRectMake(SCREEN_WIDTH - GRAPES_VIEW_WIDTH - 16, grapesViewY, WIDTH(grapesView), HEIGHT(grapesView))];
    //[self.profileView addSubview:grapesView];
    
    [self.nameLabel setFrame:CGRectMake(X2(self.nameLabel), Y2(self.nameLabel) - 8, WIDTH(self.profileDetails) - X2(self.nameLabel) * 2, HEIGHT(self.nameLabel))];
    [self.wineLevelLabel setFrame:CGRectMake(X2(self.wineLevelLabel), Y2(self.wineLevelLabel), WIDTH(self.profileDetails) - X2(self.wineLevelLabel) * 2, HEIGHT(self.wineLevelLabel))];
    [self.grapeFriendLabel setFrame:CGRectMake(X2(self.grapeFriendLabel), Y2(self.grapeFriendLabel) + 4, WIDTH(self.profileDetails) - X2(self.grapeFriendLabel) * 2, HEIGHT(self.grapeFriendLabel))];
    [self.locationButton setFrame:CGRectMake(X2(self.locationButton), Y2(self.locationButton) + 1, WIDTH(self.profileDetails) - X2(self.locationButton) * 2, HEIGHT(self.locationButton))];
    
    [self.profileView setBackgroundColor:[UIColor clearColor]];
    
    [self configureButtons:[NSArray arrayWithObjects:@([friends count]), @(uniqueCount), @(cellarCount), @(meritCount), nil]];
    //[self.delegate showPopover];
}

- (void)updateCount:(NSInteger)count atIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *button = [self.buttonMemory objectAtIndex:index];
        //[button setTitle:[NSString stringWithFormat:@"%li\n%@", (long)count, [buttonTitles objectAtIndex:index]] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%@", [buttonTitles objectAtIndex:index]] forState:UIControlStateNormal];
    });
}

- (BFTask *)updateCounts {
    //LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    BFTask *refreshUserTask = [self.profileUser fetchInBackground];
    BFTask *friendTask = [self.profileUser getFriendUsers];
    //BFTask *checkinTask = [self.delegate.vineCast getVineCastTask];
    //BFTask *uniqWinesTask = [self.delegate.unique getUniqWinesTask];
    //BFTask *cellarTask = [self.delegate.cellar getCellarTask];
    //BFTask *meritTask = [self.delegate.merits getMeritsTask];
    
    if(!friendTask)
        return [BFTask taskWithResult:@(TRUE)];
    
    NSArray *tasks = @[refreshUserTask, friendTask];
    
    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        NSMutableArray *newTasks = [[NSMutableArray alloc]
                                    initWithArray:@[
                                                    [self configureUserImage]
                                                    ]];
        
        // Async
        if(self.profileUser.checkIns < self.profileUser.uniqueWines) {
            // Async
            [newTasks addObject:[[User currentUser] updateUniqueWinesCount]];
        }
        
        return [BFTask taskForCompletionOfAllTasks:newTasks];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        [self configureLocationLabel:self.profileUser];
        NSString *name = [self.profileUser getName];
        self.nameLabel.text = ISVALID(name) ? name : @"Guest";
        
        [self becomeFirstResponder];
        [self.tableView reloadData];
        
        
        NSArray *friends = friendTask.result;
        //NSArray *uniqWines = [self.delegate.unique filterNewsFeedIntoWines:uniqWinesTask.result];
        //NSNumber *checkins = checkinTask.result;
        //NSNumber *cellar = cellarTask.result;
        //NSNumber *merits = meritTask.result;
        
        [self configureGrapeFriendLabel:friends];
        
        [self updateCount:[friends count] atIndex:0];
        [self updateCount:[self.delegate.unique uniqueCount] atIndex:1];
        [self updateCount:[self.delegate.cellar cellarCount] atIndex:2];
        [self updateCount:[self.profileUser.earnedMerits count] atIndex:3];
        
        //[self.delegate showPopover];
        [theTask setResult:@(TRUE)];
        
        return nil;
    }];
    
    return theTask.task;
}

- (void)showFriendView {
    NSLog(@"showFriendView");
    
    if(friendsVC == nil)
        friendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"friends"];
    friendsVC.user = self.profileUser;
    friendsVC.profileTVC = self;
    
    [self.delegate.navigationController pushViewController:friendsVC animated:YES];
}

- (void)configureButtons:(NSArray *)numbers {
    if(self.buttonMemory != nil) {
        for(UIButton *button in self.buttonMemory) {
            [button removeFromSuperview];
        }
    }
    
    self.buttonMemory = [[NSMutableArray alloc] init];
    
    int i = 0;
    for(NSString *buttonTitle in buttonTitles) {
        UIButton *someButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [someButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:10]];
        someButton.titleLabel.numberOfLines = 0;
        
        /*if([[numbers objectAtIndex:i] intValue] != -1)
            [someButton setTitle:[NSString stringWithFormat:@"%i\n%@", [[numbers objectAtIndex:i] intValue], buttonTitle] forState:UIControlStateNormal];
        else
            [someButton setTitle:[NSString stringWithFormat:@"%@", buttonTitle] forState:UIControlStateNormal];*/
        [someButton setTitle:[NSString stringWithFormat:@"%@", buttonTitle] forState:UIControlStateNormal];
        [someButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        someButton.backgroundColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:.3];
        someButton.layer.borderColor = [[UIColor lightTextColor] CGColor];
        someButton.layer.borderWidth = .5f;
        someButton.tag = ++i;
        
        [someButton sizeToFit];
        [someButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [someButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [someButton setFrame:[self getBoundsForButtonAtIndex:(i - 1)]];
        
        [self.buttonMemory addObject:someButton];
        [self.profileView addSubview:someButton];
    }
}

- (CGRect)getBoundsForButtonAtIndex:(NSInteger)i {
    CGFloat width = (SCREEN_WIDTH + 2) / [buttonTitles count];
    CGFloat height = 46;
    CGFloat x = -1;
    CGFloat y = HEIGHT(self.profileView) - height;
    
    x += width * i;
    
    return (CGRect){x, y, width, height};
}

static NSString *dialogUnWinegineers = @"unWinegineer Chatroom";
static NSString *dialogGimmeGrapes = @"Gimme Grapes(Test)";

static NSString *dialogSignIn = @"Sign In";
static NSString *dialogInviteFriends = @"Invite Friends";
static NSString *dialogSettings = @"Settings";
static NSString *dialogEditProfile = @"Edit Profile";

static NSString *dialogInviteFacebook = @"Invite by Facebook";
static NSString *dialogInviteText = @"Invite by Text";
static NSString *dialogInviteEmail = @"Invite by Email";

static NSString *dialogViewPhoto = @"View Photo";
static NSString *dialogTakePhoto = @"Take a Photo";
static NSString *dialogChoosePhoto = @"Choose a Photo";
static NSString *dialogImportFacebook = @"Import Facebook Photo";

static NSString *dialogViewConversation = @"View Conversation";
static NSString *dialogStartConversation = @"Start Conversation";
static NSString *dialogEndConversation = @"End Conversation";
static NSString *dialogBlockUser = @"Block User";
static NSString *dialogUnblockUser = @"Unblock User";

- (void)settingsPressed {
    NSMutableArray *buttons = [([[User currentUser] isAnonymous] ? @[dialogSignIn, dialogInviteFriends, dialogSettings] : @[dialogEditProfile, dialogInviteFriends, dialogSettings]) mutableCopy];
    //if((GET_APP_DELEGATE).environment == DEVELOPMENT && ![[User currentUser] isAnonymous])
    //   [buttons insertObject:dialogGimmeGrapes atIndex:0];
    
    if([[User currentUser] isUnwinegineer] && ![[User currentUser] isAnonymous])
        [buttons insertObject:dialogUnWinegineers atIndex:0];
    
    unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:buttons];
    
    if(self.delegate.tabBarController && self.delegate.tabBarController.view.window)
        [sheet showFromTabBar:self.delegate.tabBarController.view];
    else
        [sheet showFromTabBar:self.delegate.navigationController.view];
}

- (void)messagesPressed {
    User *user = [User currentUser];
    User *target = self.profileUser;
    if([user isAnonymous]) {
        [user promptGuest:self.delegate];
        return;
    }
    
    NSLog(@"messagesPressed");
    PFQuery *query = [Conversations queryEither:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        BOOL hasConversation = NO;
        self.convo = nil;
        for(Conversations *con in objects) {
            if([target isEqualToUser:con.user1] || [target isEqualToUser:con.user2]) {
                self.convo = con;
                hasConversation = YES;
                break;
            }
        }
        
        NSString *dialogBlocked = [user hasUserBlocked:target] ? dialogUnblockUser : dialogBlockUser;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *buttons = hasConversation ? @[dialogViewConversation, dialogBlocked] : ([user hasUserBlocked:target] ? @[dialogBlocked] : @[dialogStartConversation, dialogBlocked]);
            unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[target getName]
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:buttons];
            
            [sheet showFromTabBar:self.delegate.navigationController.view];
        });
    }];
}

- (void)worldPressed {
    WineWorldVC *world = [[WineWorldVC alloc] init];
    world.delegate = self;
    ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_WINE_WORLD_FROM_PROFILE_VIEW);
    [self.delegate.navigationController pushViewController:world animated:YES];
}

- (void)wineProfilePressed {
    WineProfileTVC *profile = [[WineProfileTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.delegate.navigationController pushViewController:profile animated:YES];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogSignIn]) {
        [[User currentUser] promptGuest:self.delegate];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogInviteFriends]) {
        [self.delegate showSocialVC:FALSE];
        ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_PROFILE);
        
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogEditProfile]) {
        [self presentEditProfileView];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Login"]) {
        LoginVC<StateControl> *login = [[LoginVC alloc] init];
        login.isGuestLoggingIn = YES;
        if(self.delegate.tabBarController && self.delegate.tabBarController.view.window)
            [self.delegate.tabBarController presentViewController:login animated:YES completion:nil];
        else
            [self.delegate.navigationController presentViewController:login animated:YES completion:nil];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogSettings]) {
        /*LOGGER(@"Settings");
        UIStoryboard *settings = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        LOGGER(@"Got settings storyboard");
        UIViewController *controller = [settings instantiateViewControllerWithIdentifier:@"settings"];
        LOGGER(@"Got settings, now pushing");
        [self.delegate.navigationController pushViewController:controller animated:YES];
        LOGGER(@"Pushed settings");
        */
        SettingsTVC *settings = [[SettingsTVC alloc] initWithStyle:UITableViewStylePlain];
        [self.delegate.navigationController pushViewController:settings animated:YES];
        
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogViewPhoto]) {
        [self viewPhoto];

    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogTakePhoto]) {
        if(![self.profileUser isAnonymous]) {
            [self.delegate showImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
        } else {
            [self.profileUser promptGuest:self.delegate];
        }
    
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogChoosePhoto]) {
        if(![self.profileUser isAnonymous]) {
            [self.delegate showImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
        } else {
            [self.profileUser promptGuest:self.delegate];
        }
    
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogImportFacebook]) {
        User *user = [User currentUser];
        user.facebookPhotoURL = [user getFacebookFetchURL];
        user.imageFile = nil;
        SHOW_HUD;
        [[user saveInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            HIDE_HUD;
            if(!task.error) {
                [self configureUserImage];
                [self.delegate.vineCast loadObjects];
            }
            return nil;
        }];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogBlockUser]) {
        User *user = [User currentUser];
        User *target = self.profileUser;
        
        [user blockUser:target];
        [user saveInBackground];
        [unWineAlertView showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"%@ has been blocked.", [target getName]] cancelButtonTitle:@"Keep unWineing"];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogGimmeGrapes]) {
        [Grapes addCurrency:1000 reason:@"gimmeGrapes" source:self.delegate];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogUnblockUser]) {
        User *user = [User currentUser];
        User *target = self.profileUser;
        
        [user unblockUser:target];
        [user saveInBackground];
        [unWineAlertView showAlertViewWithTitle:nil message:[NSString stringWithFormat:@"%@ has been unblocked.", [target getName]] cancelButtonTitle:@"Keep unWineing"];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogStartConversation]) {
        User *user = [User currentUser];
        User *target = self.profileUser;
        
        Conversations *convo = [Conversations object];
        convo.user1 = user;
        convo.user2 = target;
        
        [[convo saveInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if(task.error) {
                LOGGER(task.error);
                return nil;
            }
            
            MessengerVC *mess = [[MessengerVC alloc] initWithConversation:convo];//[[UIStoryboard storyboardWithName:@"CastInbox" bundle:nil] instantiateViewControllerWithIdentifier:@"Messenger"];
            mess.fromProfile = YES;
            
            if([convo isUnread]) {
                [convo markRead];
            }
            
            [self.delegate.navigationController pushViewController:mess animated:YES];
            
            return nil;
        }];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogViewConversation]) {
        if(!self.convo)
            return;
        
        MessengerVC *mess = [[MessengerVC alloc] initWithConversation:self.convo];
        mess.fromProfile = YES;
        
        if([self.convo isUnread]) {
            [self.convo markRead];
        }
        
        [self.delegate.navigationController pushViewController:mess animated:YES];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogInviteFacebook]) {
        [self.delegate inviteFacebook];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogInviteText]) {
        [self inviteText:nil];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogInviteEmail]) {
        [self inviteEmail:nil];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogUnWinegineers]) {
        if(NSClassFromString(@"SFSafariViewController")) {
            SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://unwine.herokuapp.com"]];
            
            [self.delegate presentViewController:sf animated:YES completion:nil];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"Please update your device." message:@"You must be using iOS v9.0 or later to be enrolled in this focus group."];
        }
    }
}

static UIViewController *inviteVC = nil;

- (void)inviteFriends:(UIViewController *)displayView {
    NSArray *buttons = @[dialogInviteFacebook, dialogInviteText, dialogInviteEmail];
    
    unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:buttons];
    
    inviteVC = displayView ? displayView : self.delegate;
    [sheet showFromTabBar:inviteVC.navigationController.view];
}

- (void)scrollTop {
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)buttonPressed:(UIButton *)button {
    [self.delegate buttonPressed:button];
}

- (void)configureLocationLabel:(User *)user {
    if(ISVALID(user.location)) {
        [self.locationButton setTitle:[NSString stringWithFormat:@"%@", user.location] forState:UIControlStateNormal];
    } else if([user isTheCurrentUser] && self.isViewLoaded && self.view.window && ![user isAnonymous]) {
        //[self updateLocation:NO];
        [self.locationButton setTitle:@"Tap here to add your location!" forState:UIControlStateNormal];
    } else if([user isAnonymous]) {
        [self.locationButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)configureGrapeFriendLabel:(NSArray *)friends {
    [self.grapeFriendLabel setTitle:[NSString stringWithFormat:@"%lu friend%@", (unsigned long)[friends count], [friends count] == 1 ? @"" : @"s"] forState:UIControlStateNormal];
}

- (void)updateLocationPressed {
    [User unwitness:WITNESS_USER_LOCATION];
    if(![[User currentUser] isAnonymous]) {
        [self updateLocation:YES];
    }
}

- (void)updateLocation:(BOOL)request {
    NSLog(@"Attempting updateLocation");
    if([CLLocationManager locationServicesEnabled] || request) {
        [self requestLocation];
    } /*else {
        User *user = [User currentUser];
        if(!ISVALID(user.location))
            [self.locationButton setTitle:@"Tap here to add your location!" forState:UIControlStateNormal];
        else
            [self.locationButton setTitle:[NSString stringWithFormat:@"%@", user.location] forState:UIControlStateNormal];
    }*/
}

- (void)requestLocation {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    [self.locationButton setTitle:@"Tap here to add your location!" forState:UIControlStateNormal];
    
    if(![User hasSeen:WITNESS_USER_LOCATION]) {
        [User witnessed:WITNESS_USER_LOCATION];
        [unWineAlertView showAlertViewWithTitle:nil message:@"Looks like you have location services for unWine disabled. For the best possible experience, we recommend you turn location services on, or you may miss out on some cool features!" cancelButtonTitle:@"Keep unWineing"];
    }
    
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *location = newLocation;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        NSDictionary *addressDictionary = [placemark addressDictionary];
        NSString *city = addressDictionary[(NSString *)kABPersonAddressCityKey];
        NSString *state = addressDictionary[(NSString *)kABPersonAddressStateKey];
        NSString *country = placemark.country;
        
        if([self.profileUser isTheCurrentUser]) {
            [self.locationButton setTitle:[NSString stringWithFormat:@"%@, %@, %@", city, state, country] forState:UIControlStateNormal];
        
            self.profileUser.location = [self.locationButton.titleLabel text];
           [self.profileUser saveInBackground];
        }
    }];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)configureWineLevelLabel:(User *)user {
    Level *currentLevel = [user getLevel];
    //NSLog(@"currentLevel - %@", currentLevel);
    //NSLog(@"allLevels - %@", [User getLevels].result);
    
    [[user checkLevel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        Level *level = task.result;
        //NSLog(@"level - %@", level);
        
        if(task.error || !level || [level isKindOfClass:[NSNull class]]) {
            LOGGER(task.error);
            if(!level)
                level = currentLevel;
        }
        
        if(level && ![level isKindOfClass:[NSNull class]] && [level isDataAvailable]) {
            if ([user isTheCurrentUser]) {
                self.wineLevelLabel.text = [NSString stringWithFormat:@"You're %@", level.canonicalName];
            } else {
                self.wineLevelLabel.text = [NSString stringWithFormat:@"Is %@", level.canonicalName];
            }
            
            if([user isTheCurrentUser] && ![currentLevel isEqual:level])
                return [user saveInBackground];
            else
                return nil;
        } else
            return nil;
    }];
}

- (BFTask *)configureUserImage {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    if(self.blurredBack == nil)
        self.blurredBack = [[UIImageView alloc] initWithFrame:self.profileView.frame];
    if(self.blurredBackOverlay == nil)
        self.blurredBackOverlay = [[UIView alloc] initWithFrame:self.profileView.frame];
    self.blurredBack.clipsToBounds = YES;
    self.blurredBackOverlay.clipsToBounds = YES;
    
    self.blurredBackOverlay.backgroundColor = [UIColor colorWithRed:.15 green:.15 blue:.15 alpha:.75];
    
    [[self.profileUser taskForDownloadingUserImage] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        UIImage *image = (UIImage *)task.result;
        [self.profileImage setImage:image];
        
        CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [gaussianBlurFilter setDefaults];
        CIImage *inputImage = [CIImage imageWithCGImage:[image CGImage]];
        [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
        [gaussianBlurFilter setValue:@(1) forKey:kCIInputRadiusKey];
        
        CIImage *outputImage = [gaussianBlurFilter outputImage];
        CIContext *context   = [CIContext contextWithOptions:nil];
        CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];
        
        UIImage *blurredImage = [UIImage imageWithCGImage:cgimg];
        CGImageRelease(cgimg);
        
        [self.blurredBack setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.profileView))];
        [self.blurredBack setImage:blurredImage];
        [self.blurredBack setContentMode:UIViewContentModeScaleAspectFill];
        [self.blurredBackOverlay setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.profileView))];
        
        [self.view insertSubview:self.blurredBack belowSubview:self.profileView];
        [self.view insertSubview:self.blurredBackOverlay aboveSubview:self.blurredBack];
        
        [theTask setResult:@(TRUE)];
        
        return nil;
    }];
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
    [self.profileImage addGestureRecognizer:tapProfile];
    
    return theTask.task;
}

- (void)profilePressed:(UITapGestureRecognizer *)gesture {
    if([self.profileUser isTheCurrentUser]) {// && ![self.profileUser isAnonymous]) {
        User *curr = [User currentUser];
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        if(ISVALID([curr getProfileImageURL]))
            [buttons addObject:dialogViewPhoto];
        [buttons addObject:dialogTakePhoto];
        [buttons addObject:dialogChoosePhoto];
        if([curr hasFacebook])
            [buttons addObject:dialogImportFacebook];
        
        unWineActionSheet *action = [[unWineActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:buttons];
        
        [action showFromTabBar:self.delegate.navigationController.view];
    } else {
        [self viewPhoto];
    }
}

- (void)viewPhoto {
    NSLog(@"Profile Pressed.");
    if(imageFullVC == nil)
        imageFullVC = [[UIStoryboard storyboardWithName:@"ImageFull" bundle:nil] instantiateInitialViewController];
    
    [imageFullVC setImage:self.profileImage.image];
    
    [self.delegate.navigationController.view addSubview:imageFullVC.view];
    [UIView animateWithDuration:.3 animations:^{
        imageFullVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [imageFullVC setImage:self.profileImage.image];
    }];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 44)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SEMIWIDTH(self.tableView), 44)];
    [headerTitle setText:@"Header"];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"default" forIndexPath:indexPath];
}

#pragma Edit Profile View Stuff

- (void)presentEditProfileView {
    //logoViewAlpha = (GET_APP_DELEGATE).ctbc.logoView.alpha;
    //(GET_APP_DELEGATE).ctbc.logoView.alpha = 0;
    
    [self.delegate.vineCast animateNavBarTo:20];
    [self.delegate updateBarButtonItems:1];
    
    [self.tableView setContentOffset:CGPointZero];
    self.tableView.scrollEnabled = NO;
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    [self.delegate setTitleView:@"Edit Profile"];
    
    NSInteger epvY = 44 + 20;
    CGRect frame = CGRectMake(0, epvY, SCREEN_WIDTH, HEIGHT(self.delegate.view) - epvY + 20);
    editProfileView = [[EditProfileView alloc] initWithFrame:frame]; //(CGRect){0, epvY, {SCREEN_WIDTH, HEIGHT(self.tableView) - epvY}}
    editProfileView.parent = self;
    [editProfileView addName:self.nameLabel relativeFrame:[self.profileDetails.superview convertRect:self.nameLabel.frame fromView:self.profileDetails]];
    [editProfileView addLocation:self.locationButton relativeFrame:[self.profileDetails.superview convertRect:self.locationButton.frame fromView:self.profileDetails]];
    [editProfileView addBirthday];
    [editProfileView addSubview:self.profileImage];
    
    [self.delegate.view addSubview:editProfileView];
}

- (void)hideEditProfileView {
    if([editProfileView superview]) {
        self.tableView.scrollEnabled = YES;
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
        
        [self.view addSubview:self.profileImage];
        [self configureProfile:self.profileUser];
        [editProfileView dismissFields];
        [editProfileView removeFromSuperview];
        //(GET_APP_DELEGATE).ctbc.logoView.alpha = logoViewAlpha;
        
        [self.delegate addUnWineTitleView];
    }
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}

@end
