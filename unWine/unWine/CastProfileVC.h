//
//  CastProfileVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/12/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ProfileTVC.h"
#import "VineCastTVC.h"
#import "ImageFullVC.h"
#import "MeritsTVC.h"
#import "Grapes.h"
#import "FriendsTVC.h"
#import "CellarTVC.h"
#import "UniqWinesTVC.h"
#import "User.h"
#import "PopoverVC.h"
#import "SearchTVC.h"

@class VineCastTVC, ProfileTVC, FriendsTVC, CellarTVC, UniqWinesTVC, MeritsTVC, SearchTVC;
@interface CastProfileVC : UIViewController <GrapesViewDelegate, unWineAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PopoverDelegate>

@property (nonatomic) VineCastTVC *vineCast;
@property (nonatomic) ProfileTVC *profileTable;
@property (nonatomic) ImageFullVC *imageFullVC;
@property (nonatomic) MeritsTVC *merits;
@property (nonatomic) SearchTVC *friends;
@property (nonatomic) UniqWinesTVC *unique;
@property (nonatomic) CellarTVC *cellar;
@property (nonatomic) User *user;

@property (nonatomic) BOOL isProfileTab;
@property (nonatomic) BOOL shouldRefresh;

@property (strong, nonatomic) UIBarButtonItem *grapesButton;
@property (strong, nonatomic) UIBarButtonItem *friendshipButton;

// Appboy stuff
@property (strong, nonatomic) UIBarButtonItem *newsButton;
@property (nonatomic) NSTimeInterval lastUpdateNewsButton;
@property (nonatomic) NSInteger lastUpdateNewsButtonBadge;

- (void)showFacebookInvite;

- (void)refreshHeaderViewWithReaction:(BOOL)addReactionSection;
- (void)addUnWineTitleView;
- (void)setTitleView:(NSString *)title;
- (BFTask *)setProfileUser:(User *)user;
- (void)buttonPressed:(UIButton *)button;
- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)source;
- (void)updateBarButtonItems:(CGFloat)alpha;
- (void)showPopover;

// Appboy stuff
// News Button Stuff
- (void)setUpNewsButton:(UIBarButtonItem *) newsButton;
- (NSInteger)getAppboyCount;
- (void)updateNewsButtonWithTimer:(BOOL)delay;
- (void)updateNewsButton:(NSInteger)number;

// NewsFeed Controller
- (void)refreshUnWineNewsNewsFeed;
- (void)showNewsFeedController:(CastInboxDefault)openToDailyToast;
- (void)showDailyToast;
- (void)showInboxNotification;
- (void)showInboxConversation;

@end
