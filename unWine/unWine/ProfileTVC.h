//
//  CastProfileTVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/8/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "VineCastTVC.h"
#import "ImageFullVC.h"
#import "UITableViewController+Helper.h"
#import "FriendsTVC.h"
#import "ParseSubclasses.h"

#import "unWineActionSheet.h"
#import "IQKeyboardManager.h"
#import "WineWorldVC.h"

@class VineCastTVC, CastProfileVC, FriendsTVC, WineWorldVC;
@interface ProfileTVC : UITableViewController <CLLocationManagerDelegate, unWineActionSheetDelegate, FBSDKAppInviteDialogDelegate, WineWorldDelegate>

@property (nonatomic) CastProfileVC *delegate;
@property (nonatomic) VineCastTVC *vineCast;
@property (nonatomic) FriendsTVC *friendsVC;
@property (nonatomic) ImageFullVC *imageFullVC;
@property (nonatomic, retain) User *profileUser;

@property (nonatomic, retain) Conversations *convo;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *wineLevelLabel;
@property (nonatomic) UIButton *grapeFriendLabel;
@property (nonatomic) UIButton *locationButton;
@property (nonatomic) UIButton *settingsButton;
@property (nonatomic) UIButton *worldButton;
@property (nonatomic) UIButton *friendsButton;
@property (nonatomic) NSMutableArray *buttonMemory;
@property (nonatomic) NSMutableAttributedString *formatted;

@property (strong, nonatomic) PFImageView *profileImage;
@property (strong, nonatomic) IBOutlet CascadingLabelView *profileDetails;
@property (strong, nonatomic) IBOutlet UIView *profileView;

@property (strong, nonatomic) UIImageView *blurredBack;
@property (strong, nonatomic) UIView *blurredBackOverlay;

- (void)profilePressed:(UITapGestureRecognizer *)gesture;
- (BFTask *)configureUserImage;
- (void)configureProfile:(User *)user;
- (void)configureLocationLabel:(User *)user;
- (void)updateCount:(NSInteger)count atIndex:(NSInteger)index;
- (BFTask *)updateCounts;
- (void)inviteFriends:(UIViewController *)displayView;
- (CGRect)getBoundsForButtonAtIndex:(NSInteger)i;

- (void)presentEditProfileView;
- (void)hideEditProfileView;

@end
