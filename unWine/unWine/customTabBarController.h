//
//  BaseViewController.h
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//


#import "MainVC.h"
//#import "VineCastTVC.h"
//#import "CastScannerVC.h"
//#import "CastProfileVC.h"

@class VineCastTVC, CastScannerVC, CastProfileVC, MessengerVC, SearchTVC;

@interface customTabBarController : UITabBarController <StateControl, UIActionSheetDelegate, UITabBarControllerDelegate>

@property (nonatomic, assign) UIButton *messageButton;
@property (nonatomic) BOOL userIsOnScanner;
@property (nonatomic, strong) CastProfileVC *profileVC;
@property (nonatomic) NSMutableArray *floatingButtons;
@property (nonatomic) UIView *delicateView;
@property (nonatomic) CGPoint panCoord;

//@property (nonatomic, strong) UINavigationController *newsFeedInitialController;
@property (nonatomic, strong) UIViewController *newsFeedInitialController;
@property (nonatomic, strong) UINavigationController *searchController;
@property (nonatomic, strong) UINavigationController *profileController;

@property (nonatomic, strong) MessengerVC *messenger;

// Stuff

- (VineCastTVC *)getVinecastTVC;
- (CastProfileVC *)getProfileVC;
- (instancetype)init;
- (void)disableInteraction;
- (void)enableInteraction;

// hmm
- (void)selectCheckInCell;
//- (void)selectFeedCell;
//- (void)selectInboxInCell;
//- (void)selectMoreCell;

// Parse Stuff
+ (void)fetchConfigConstants;

- (NSArray<UINavigationController *> *)getControllers;

// Appboy Stuff
- (void)showNewsFeedController:(CastInboxDefault)openTo;
- (void)showCustomSlideUpWithMessage:(NSString *)message andURL:(NSURL *)url;
- (void)showUserVoice;
- (void)showAppBoyNewsFeed:(CastInboxDefault)openTo;

// Deep Linking Stuff
- (void)showClubW;
- (void)showTrendingWines;
- (void)showMerits;
- (void)showInviteFriends;
- (void)showConversationWith:(NSString *)path useRootVC:(BOOL)useRoot;
- (void)showVineCastWith:(NSString *)path useRootVC:(BOOL)useRoot;
- (void)showProfileWith:(NSString *)path useRootVC:(BOOL)useRoot;
- (void)showWineWith:(NSString *)path useRootVC:(BOOL)useRoot;
- (void)showWineryWith:(NSString *)path useRootVC:(BOOL)useRoot;
- (void)pushViewController:(UIViewController *)controller;

@end
