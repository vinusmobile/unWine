//
//  FriendInviteTVC.m
//  unWine
//
//  Created by Fabio Gomez on 6/12/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FriendInviteTVC.h"
#import "UITableViewController+Helper.h"
#import "FriendInvitePlaceholderCell.h"
#import "InvitePromptCell.h"
#import "InviteContactButtonCell.h"
#import "UIViewController+Social.h"
#import "FacebookInviteTVC.h"

NSString *kFriendInvitePlaceholderCell = @"FriendInvitePlaceholderCell";
NSString *kInvitePromptCell = @"InvitePromptCell";
NSString *kInviteContactFacebook = @"InviteContactFacebook";
NSString *kInviteContactButton = @"InviteContactButton";
NSString *kInviteContactSMS = @"InviteContactSMS";
NSString *kInviteContactEmail = @"InviteContactEmail";

@implementation FriendInviteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self basicAppeareanceSetup];
    self.allFriendsInvited = NO;
    //self.signUpMode = false;
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"< Back"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(dismiss)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = dismissButton;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.signUpMode) {
        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"Skip"
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(dismiss)];
        self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
        self.navigationController.navigationBar.topItem.rightBarButtonItem = dismissButton;
        
    } else {
        self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.allFriendsInvited) {
        // This shows after user invites all unWine Facebook friends from FacebookInviteTVC
        [self showAlertWithHeader:@"Success"
                          message:@"You added all your unWine Friends!"
                    andButtonText:@"OK"
                            error:NO];
        self.allFriendsInvited = NO;
    }
}
    
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    if (indexPath.row > 1) {
        if (IS_IPHONE_6P || IS_IPHONE_6) {
            height = 60;
        } else {
            height = 40;
        }
        
    } else if (indexPath.row == 1) {
        height = 100;
        
    } else if (IS_IPHONE_6P) {
        height = 202;

    } else if (IS_IPHONE_6) {
        height = 183;

    } else {
        height = 156;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = nil;
    switch (indexPath.row) {
        case 0:
            identifier = kFriendInvitePlaceholderCell;
            break;
        case 1:
            identifier = kInvitePromptCell;
            break;
        case 2:
            identifier = kInviteContactFacebook;
            break;
        case 3:
            identifier = kInviteContactButton;
            break;
        case 4:
            identifier = kInviteContactSMS;
            break;
        case 5:
            identifier = kInviteContactEmail;
            break;
            
        default:
            identifier = kInviteContactButton;
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    // Configure the cell...
    
    if (indexPath.row < 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    } else if (indexPath.row == 2) {
        InviteContactButtonCell *c = (InviteContactButtonCell *)cell;
        [c setFacebookStyle];
        cell = c;
        
    } else if (indexPath.row == 3) {
        InviteContactButtonCell *c = (InviteContactButtonCell *)cell;
        [c setContactsStyle];
        cell = c;
        
    } else if (indexPath.row == 4) {
        InviteContactButtonCell *c = (InviteContactButtonCell *)cell;
        [c setSMSStyle];
        cell = c;
        
    } else if (indexPath.row == 5) {
        InviteContactButtonCell *c = (InviteContactButtonCell *)cell;
        [c setEmailStyle];
        cell = c;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_PRESSED_FACEBOOK_BUTTON_FRIEND_INVITE);
        
    } if (indexPath.row == 3) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_PRESSED_CONTACTS_BUTTON_FRIEND_INVITE);
        
    } else if (indexPath.row == 4) {
        [self inviteText:nil];
        ANALYTICS_TRACK_EVENT(EVENT_USER_PRESSED_SMS_BUTTON_FRIEND_INVITE);
        
    } else if (indexPath.row == 5) {
        // Show email invite
        [self inviteEmail:nil];
        ANALYTICS_TRACK_EVENT(EVENT_USER_PRESSED_EMAIL_BUTTON_FRIEND_INVITE);
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    LOGGER(@"Segue");
    if ([segue.identifier isEqualToString:@"toFacebookInviteTVC"]) {
        LOGGER(@"Delegate");
        ((FacebookInviteTVC *)segue.destinationViewController).delegate = self;
    }
}


@end
