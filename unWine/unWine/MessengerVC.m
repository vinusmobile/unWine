//
//  MessengerVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/11/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "MessengerVC.h"
#import "MessengerSelfCell.h"
#import "MessengerUserCell.h"
#import "IQKeyboardManager.h"

@implementation MessengerVC {
    BOOL active;
    UILabel *headerLabel;
    CGFloat frameAdjust;
    CGFloat keyboardHeight;
}

- (instancetype)initWithConversation:(Conversations *)convo {
    self = [super init];
    if (self) {
        self.messenger = [[MessengerTVC alloc] initWithStyle:UITableViewStyleGrouped];
        self.messenger.convo = self.convo = convo;
        self.tableView = self.messenger.tableView;
        [self addChildViewController:self.messenger];
        [self.view addSubview:self.messenger.view];
        [self.messenger didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicAppeareanceSetup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationController.hidesBarsWhenKeyboardAppears = NO;
    self.navigationController.hidesBarsWhenVerticallyCompact = NO;
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.hidesBarsOnTap = NO;
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    
    self.headerView = [self makeHeaderView];
    [self.view addSubview:self.headerView];
    
    self.composeBarView = [self makeComposeBarView:YES];
    [self.view addSubview:self.composeBarView];
    
    [self.messenger.view setFrame:CGRectMake(0, HEIGHT(self.headerView), SCREEN_WIDTH, HEIGHT(self.view) - HEIGHT(self.composeBarView) - HEIGHT(self.headerView))];
    self.messenger.tableView.bounds = self.messenger.view.frame;
    self.messenger.tableView.clipsToBounds = YES;
    [self.composeBarView setFrame:CGRectMake(0, HEIGHT(self.view) - PHFComposeBarViewInitialHeight, SCREEN_WIDTH, PHFComposeBarViewInitialHeight)];
    
    ((customTabBarController *)self.tabBarController).messenger = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)isActive {
    return active;
}

- (void)activeReload {
    self.messenger.loadQuietly = YES;
    [self.messenger loadObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    active = YES;
    (GET_APP_DELEGATE).ctbc.messenger = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    active = NO;
    [self.composeBarView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //if(self.parentViewController)
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (Conversations *)getConvo {
    return self.convo;
}

- (UIView *)makeHeaderView {
    User *other = [[self getConvo] getOtherUser];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    headerView.backgroundColor = UNWINE_GRAY_LIGHT;
    
    NSUInteger labelBuffer = 4;
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelBuffer, labelBuffer, WIDTH(headerView) - labelBuffer * 2, 32 - labelBuffer * 2)];
    [headerLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12]];
    [headerLabel setText:[NSString stringWithFormat:@"Talking to %@", [other getName]]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    headerLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (PHFComposeBarView *)makeComposeBarView:(BOOL)hasInputView {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, PHFComposeBarViewInitialHeight);
    PHFComposeBarView *composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    
    [composeBarView setMaxCharCount:200];
    [composeBarView setMaxLinesCount:5];
    [composeBarView setPlaceholder:@"Type something..."];
    [composeBarView setDelegate:self];
    composeBarView.buttonTitle = @"Send";
    composeBarView.buttonTintColor = UNWINE_RED;
    composeBarView.tintColor = UNWINE_RED;
    
    //composeBarView.textView.inputView = nil;
    composeBarView.textView.returnKeyType = UIReturnKeyDone;
    //if(hasInputView)
    //    composeBarView.textView.inputView = [self makeComposeBarView:NO];
    
    return composeBarView;
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame {
    
    CGFloat shift;
    frameAdjust += shift = endFrame.size.height - startFrame.size.height;
    if(frameAdjust < 0)
        frameAdjust = 0;
    
    CGRect messengerFrame = self.messenger.view.frame;
    messengerFrame.size.height -= shift;
    self.messenger.view.frame = messengerFrame;
    self.messenger.tableView.bounds = self.messenger.view.frame;

    [self.tableView setContentOffset:CGPointMake(0, 24) animated:YES];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView{
    NSString *string = [composeBarView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"string = %@", string);
    
    if (string.length <= 200) {
        [self sendMessage:string];
        
        [composeBarView.textView resignFirstResponder];
        composeBarView.text = @"";
    } else {
        [unWineAlertView showAlertViewWithTitle:nil message:@"Please enter a message shorter than 200 characters."];
    }
}

- (void)sendMessage:(NSString *)text {
    User *user = [User currentUser];
    User *target = [[self getConvo] getOtherUser];
    
    if([[self getConvo] isBlocked]) {
        NSString *blockMsg = [user hasUserBlocked:target] ? [NSString stringWithFormat:@"You have %@ blocked.", [target getName]] : [NSString stringWithFormat:@"You have been blocked."];
        
        [unWineAlertView showAlertViewWithTitle:@"Blocked" message:blockMsg];
        return;
    }
    
    LOGGER(@"arrived for sending");
    
    Messages *message = [Messages object];
    message.sender = user;
    message.seen = NO;
    message.message = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];;
    [[[message saveInBackground] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            return nil;
        }
        
        //PFRelation *messages = [convo relationForKey:@"messages"];
        //[messages addObject:message];
        
        //convo.lastMessage = message;
        
        return [PFCloud callFunctionInBackground:@"saveConversation" withParameters:
                @{ @"convoId":[self getConvo].objectId, @"messageId":message.objectId }];
    }] continueWithBlock:^id(BFTask *task) {
        if(task == nil)
            return nil;
        
        if(task.error) {
            LOGGER(task.error);
            return nil;
        }
        
        LOGGER(@"convo saved!!!!!!!!!!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self activeReload];
            [self sendNotification:message];
        });
        
        return nil;
    }];
}

- (void)sendNotification:(Messages *)message {
    User *user = [User currentUser];
    User *target = [[self getConvo] getOtherUser];
    [Push sendPushNotification:NotificationTypeMessage toUser:target withMessage:[NSString stringWithFormat:@"%@ says: %@", [user getName], message.message] withURL:[NSString stringWithFormat:@"unwineapp://conversation/%@", [self.convo objectId]]];
}

- (void)keyboardWillShow:(NSNotification *)note {
    self.navigationController.navigationBarHidden = NO;
    NSDictionary *info = [note userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if(keyboardHeight == 0)
        keyboardHeight = kbSize.height;
    
    CGFloat screenOffset = 0;
    if(IS_IPHONE_4)
        screenOffset = 86;
    frameAdjust = 0;
    
    CGRect messengerFrame = self.messenger.view.frame;
    messengerFrame.size.height -= keyboardHeight;
    self.messenger.view.frame = messengerFrame;
    
    CGRect composeBarFrame = self.composeBarView.frame;
    composeBarFrame.origin.y -= keyboardHeight;
    self.composeBarView.frame = composeBarFrame;
    
    [self.tableView setContentSize:self.messenger.view.frame.size];
    [self.tableView setContentOffset:CGPointMake(0, 24) animated:YES];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect messengerFrame = self.messenger.view.frame;
    messengerFrame.size.height += keyboardHeight;
    self.messenger.view.frame = messengerFrame;
    frameAdjust = 0;
    
    CGRect composeBarFrame = self.composeBarView.frame;
    composeBarFrame.origin.y += keyboardHeight;
    self.composeBarView.frame = composeBarFrame;
}
                      
- (void)basicAppeareanceSetup {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Back";
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // White Status Bar for controllers inside Navigation Controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // Not sure why this works lol

    [self addUnWineTitleView];
}

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

@end
