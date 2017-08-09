//
//  InboxVC.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "ABKFeedViewControllerNavigationContext.h"
#import "InboxTVC.h"

@interface CastInboxVC : UIViewController

@property (nonatomic) UIButton *notificationsButton;
@property (nonatomic) UIButton *converationsButton;
@property (nonatomic) UIButton *newsButton;
@property (nonatomic) CastInboxDefault openTo;

@property (nonatomic) ABKFeedViewControllerNavigationContext *appboy;
@property (nonatomic) InboxTVC *inbox;

- (void)updateVinecastBadge;

@end
