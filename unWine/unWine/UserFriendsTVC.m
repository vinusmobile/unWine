//
//  UserFriendsTVC.m
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "UserFriendsTVC.h"
#import "InviteContactButtonCell.h"
#import "UserFriendCell.h"
#import "UITableViewController+Helper.h"
#import "CastProfileVC.h"
#import "UIViewController+Social.h"

static NSString *kFacebookInviteCell = @"FacebookInviteCell";
static NSString *kUserFriendCell = @"UserFriendCell";

@interface UserFriendsTVC ()
@property (nonatomic, strong) NSArray<User *> *friends;
@end

@implementation UserFriendsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self basicAppeareanceSetup];
    self.tableView.backgroundColor = UNWINE_WHITE_BACK;
    self.friends = @[];
    
    if (ISVALIDARRAY(self.users)) {
        self.friends = self.users;
        [self.tableView reloadData];
    } else {
        [self defaultSetup];
    }
    
}

- (void)defaultSetup {
    UIImage *faceImage = [UIImage imageNamed:@"addUser"];
    UIButton *face2 = [UIButton buttonWithType:UIButtonTypeCustom];
    face2.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    [face2 setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [face2 setImage:faceImage forState:UIControlStateNormal];
    [face2 addTarget:self action:@selector(showSocialView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:face2];
    
    SHOW_HUD;
    [[[User currentUser] getFriendUsers] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSArray<User *> *> * _Nonnull t) {
        HIDE_HUD;
        
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
        } else {
            self.friends = t.result;
            NSString *s = [NSString stringWithFormat:@"Found %li friends", (unsigned long)self.friends.count];
            LOGGER(s);
            [self.tableView reloadData];
        }
        
        return nil;
    }];
}

- (void)showSocialView {
    LOGGER(@"Enter");
    [self showSocialVC:FALSE];
    ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_FRIENDS_VIEW);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.friends.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  ISVALIDARRAY(self.users) && indexPath.section == 0 ? 0 : 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.section == 0 ? kFacebookInviteCell : kUserFriendCell;
    UITableViewCell *cell = nil;
    
    if ([identifier isEqualToString:kFacebookInviteCell]) {
        cell = (InviteContactButtonCell*)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [(InviteContactButtonCell*)cell setFacebookStyleImageOnly];

    } else {
        User *usr = [self.friends objectAtIndex:indexPath.row];
        cell = (UserFriendCell*)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [(UserFriendCell*)cell configureWithUser:usr];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self inviteFacebook];
        
    } else {
        User *user = [self.friends objectAtIndex:indexPath.row];
        CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
        
        [profile setProfileUser:user];
        [self.navigationController pushViewController:profile animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
