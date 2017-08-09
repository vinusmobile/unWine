//
//  MessengerVC.h
//  unWine
//
//  Created by Bryce Boesen on 10/11/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHFComposeBarView.h"
#import "MessengerTVC.h"
#import "ParseSubclasses.h"

@class MessengerTVC;
@interface MessengerVC : UIViewController <PHFComposeBarViewDelegate>

@property (nonatomic, strong) MessengerTVC *messenger;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PHFComposeBarView *composeBarView;
@property (nonatomic) BOOL fromProfile;

@property (nonatomic, retain) Conversations *convo;

- (instancetype)initWithConversation:(Conversations *)convo;

- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;

- (BOOL)isActive;
- (void)activeReload;

- (PHFComposeBarView *)makeComposeBarView:(BOOL)hasInputView;

@end
