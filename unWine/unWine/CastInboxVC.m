//
//  InboxVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastInboxVC.h"
#import "CastProfileVC.h"
#import "Appboy.h"
#import "AppboyKit.h"

static NSInteger buttonHeight = 48;

@interface CastInboxVC () <SFSafariViewControllerDelegate, ABKFeedViewControllerDelegate>
@end

@implementation CastInboxVC {
    CALayer *bottomBorder;
    UIScrollView *tabContainer;
}
@synthesize appboy, inbox;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(close)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger buttonWidth = MAX(375 / 2, WIDTH(self.view) / 2);
    tabContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), buttonHeight)];
    tabContainer.backgroundColor = UNWINE_GRAY_DARK;
    tabContainer.clipsToBounds = YES;
    [tabContainer setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [tabContainer setBounces:YES];
    [tabContainer setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    tabContainer.contentSize = (CGSize){buttonWidth * 2, buttonHeight};
    
    self.notificationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.notificationsButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    self.notificationsButton.backgroundColor = UNWINE_GRAY_DARK;
    [self.notificationsButton setTitle:@"Notifications" forState:UIControlStateNormal];
    [self.notificationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.notificationsButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [self.notificationsButton addTarget:self action:@selector(showNotifications) forControlEvents:UIControlEventTouchUpInside];
    [tabContainer addSubview:self.notificationsButton];
    
    
    /*self.converationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.converationsButton setFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    self.converationsButton.backgroundColor = UNWINE_GRAY_DARK;
    [self.converationsButton setTitle:@"Conversations" forState:UIControlStateNormal];
    [self.converationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.converationsButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [self.converationsButton addTarget:self action:@selector(showConversations) forControlEvents:UIControlEventTouchUpInside];
    [tabContainer addSubview:self.converationsButton];*/
    
    
    self.newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.newsButton setFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    self.newsButton.backgroundColor = UNWINE_GRAY_DARK;
    [self.newsButton setTitle:@"The Daily Toast" forState:UIControlStateNormal];
    [self.newsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.newsButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [self.newsButton addTarget:self action:@selector(showNews) forControlEvents:UIControlEventTouchUpInside];
    [tabContainer addSubview:self.newsButton];
    
    [self.view addSubview:tabContainer];
    
    [self setupAppboyVC];
    [self setupInboxTVC]; //must come second for some magic ios reason
    if(self.openTo == CastInboxDefaultNotification)
        [self showNotifications];
    else if(self.openTo == CastInboxDefaultConversation)
        [self showConversations];
    else if(self.openTo == CastInboxDefaultDailyToast)
        [self showNews];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self addUnWineTitleView];
    
    self.appboy.appboyDelegate = self;
    //[self performSelector:@selector(showPopover) withObject:nil afterDelay:.8];
    [self showPopover];
}

- (BOOL)onCardClicked:(ABKCard *)clickedCard feedViewController:(UIViewController *)newsFeed {
    
    BOOL appboyCanShowURL = YES;
    
    NSLog(@"%@\n\n", clickedCard.description);
    NSLog(@"%@\n\n", clickedCard.extras);
    
    NSString *urlString = nil;
    
    if ([clickedCard isKindOfClass:[ABKBannerCard class]]) {
        urlString = ((ABKBannerCard *)clickedCard).urlString;
    } else if ([clickedCard isKindOfClass:[ABKCaptionedImageCard class]]) {
        urlString = ((ABKCaptionedImageCard *)clickedCard).urlString;
    } else if ([clickedCard isKindOfClass:[ABKClassicCard class]]) {
        urlString = ((ABKClassicCard *)clickedCard).urlString;
    } else if ([clickedCard isKindOfClass:[ABKCrossPromotionCard class]]) {
        urlString = ((ABKCrossPromotionCard *)clickedCard).urlString;
    } else if ([clickedCard isKindOfClass:[ABKTextAnnouncementCard class]]) {
        urlString = ((ABKTextAnnouncementCard *)clickedCard).urlString;
    }
  
    // iOS 9
    if(NSClassFromString(@"SFSafariViewController") && ISVALID(urlString) && DOES_NOT_HAVE_UNWINE_SCHEME(urlString)) {
        appboyCanShowURL = NO;
        
        SFSafariViewController *internet = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
        internet.delegate = self;
        
        [self presentViewController:internet animated:YES completion:nil];
    }
    
    return appboyCanShowURL;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Can't clear badge because running simulator");
#else
    [self clearAppBadge];
#endif
}

- (void)showPopover {
    if(![User hasSeen:WITNESS_ALERT_DAILY_TOAST] && ![[PopoverVC sharedInstance] isDisplayed]) {
        CGRect placer = self.newsButton.frame;
        NSLog(@"showPopover frame %@", NSStringFromCGRect(placer));
        //placer.size.width = placer.size.width / 2;
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.view
                                  sourceRect:placer
                                        text:@"The Daily Toast, your one stop experience for unWine related news, wine pairings, wine pro tips, and more!"];
        
        [User witnessed:WITNESS_ALERT_DAILY_TOAST];
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_DAILY_TOAST_BUBBLE);
    }
}

- (void)clearAppBadge {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if(currentInstallation == nil)
        return;
    
    if (currentInstallation.badge != 0)
        currentInstallation.badge = 0;
    
    [currentInstallation saveInBackground];
}

- (void)updateVinecastBadge {
    CastProfileVC *profileVC = (GET_APP_DELEGATE).ctbc.profileVC;
    [profileVC updateNewsButton:([inbox getBadgeCount] + [profileVC getAppboyCount])];
    //NSLog(@"updateVinecastBadge - %li", (long)([inbox getBadgeCount] + [profileVC getAppboyCount]));
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)showNotifications {
    inbox.mode = CastInboxModeNotifications;
    [inbox loadObjects];
    
    appboy.view.alpha = 0;
    inbox.view.alpha = 1;
    
    if(!bottomBorder)
        bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, buttonHeight - 4, WIDTH(self.notificationsButton), 4);
    bottomBorder.backgroundColor = UNWINE_RED.CGColor;
    
    if([bottomBorder superlayer])
        [bottomBorder removeFromSuperlayer];
    [self.notificationsButton.layer addSublayer:bottomBorder];
}

- (void)showConversations {
    inbox.mode = CastInboxModeConversations;
    [inbox loadObjects];
    
    appboy.view.alpha = 0;
    inbox.view.alpha = 1;
    
    if(!bottomBorder)
        bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, buttonHeight - 4, WIDTH(self.converationsButton), 4);
    bottomBorder.backgroundColor = UNWINE_RED.CGColor;
    
    if([bottomBorder superlayer])
        [bottomBorder removeFromSuperlayer];
    [self.converationsButton.layer addSublayer:bottomBorder];
}


- (void)showNews {
    appboy.view.alpha = 1;
    inbox.view.alpha = 0;
    
    if(!bottomBorder)
        bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, buttonHeight - 4, WIDTH(self.newsButton), 4);
    bottomBorder.backgroundColor = UNWINE_RED.CGColor;
    
    if([bottomBorder superlayer])
        [bottomBorder removeFromSuperlayer];
    [self.newsButton.layer addSublayer:bottomBorder];
}

- (void)setupAppboyVC {
    if(appboy == nil) {
        appboy = [[ABKFeedViewControllerNavigationContext alloc] init];
        
        [self addChildViewController:appboy];
        [self.view addSubview:appboy.view];
        [appboy didMoveToParentViewController:self];
        
        //NSLog(@"appboy views - %@", [appboy.view subviews]);
        //NSLog(@"appboy vc - %@", [appboy childViewControllers]);
    }
    
    [appboy.view setFrame:CGRectMake(0, buttonHeight, WIDTH(self.view), HEIGHT(self.view) - buttonHeight)];
    appboy.view.clipsToBounds = YES;
}

- (void)setupInboxTVC {
    if(inbox == nil) {
        inbox = [self.storyboard instantiateViewControllerWithIdentifier:@"InboxTVC"];
        inbox.delegate = self;
        
        [self addChildViewController:inbox];
        [self.view addSubview:inbox.view];
        [inbox didMoveToParentViewController:self];
    }
    
    [inbox.view setFrame:CGRectMake(0, buttonHeight, WIDTH(self.view), HEIGHT(self.view) - buttonHeight)];
    inbox.view.clipsToBounds = YES;
    
    inbox.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    appboy.view.backgroundColor = inbox.view.backgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

@end
