//
//  FacebookInviteTVC.m
//  unWine
//
//  Created by Fabio Gomez on 6/12/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FacebookInviteTVC.h"
#import "UITableViewController+Helper.h"
#import "FacebookInviteHeaderCell.h"
#import "FacebookFriendsCell.h"
#import "FacebookInviteAddAllCell.h"
#import "InviteContactButtonCell.h"
#import "UIViewController+Social.h"
#import "FriendInviteTVC.h"
#import "UserFriendsTVC.h"

static NSString *kFacebookInviteHeaderCell = @"FacebookInviteHeaderCell";
static NSString *kFacebookFriendsCell = @"FacebookFriendsCell";
static NSString *kFacebookInviteAddAllCell = @"FacebookInviteAddAllCell";
static NSString *kInviteContactButtonCell = @"InviteContactButtonCell";

@interface FacebookInviteTVC ()
@property (nonatomic, strong) NSArray <User*>*facebookFriends;
@end

@implementation FacebookInviteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicAppeareanceSetup];
    self.tableView.backgroundColor = UNWINE_WHITE_BACK;
    self.tableView.separatorColor = [UIColor clearColor];
    self.facebookFriends = @[];
    
    SHOW_HUD;
    [[User getUsersFromFacebookFriends] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask <NSArray<User*>*>* _Nonnull t) {
        HIDE_HUD;
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            return nil;
            
        }

        NSString *s = [NSString stringWithFormat:@"Found %li Users from Facebook friends", t.result.count];
        LOGGER(s);
        self.facebookFriends = t.result;
        //self.facebookFriends = @[];
        [self.tableView reloadData];

        return nil;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.facebookFriends.count > 0 ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.facebookFriends.count < 1 || (self.facebookFriends.count > 0 && section != 1)) {
        return 1;
    } else if (self.facebookFriends.count % FACEBOOK_FRIENDS_IMAGES_PER_CELL == 0) {
        return (int)(self.facebookFriends.count / FACEBOOK_FRIENDS_IMAGES_PER_CELL);
    } else {
        return (int)(self.facebookFriends.count / FACEBOOK_FRIENDS_IMAGES_PER_CELL) + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 60;
    switch (indexPath.section) {
        case 0:
            height = self.facebookFriends.count > 0 ? 150 : 60;
            break;
        case 1:
            height = 60;
            break;
        case 2:
            height = 114;
            break;
            
        default:
            height = 60;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = nil;
    switch (indexPath.section) {
        case 0:
            identifier = self.facebookFriends.count > 0 ? kFacebookInviteHeaderCell : kInviteContactButtonCell;
            break;
        case 1:
            identifier = kFacebookFriendsCell;
            break;
        case 2:
            identifier = kFacebookInviteAddAllCell;
            break;
            
        default:
            break;
    }
    
    NSString *s = [NSString stringWithFormat:@"Section %li, using identifier \"%@\"", indexPath.section, identifier];
    LOGGER(s);
    
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    if ([identifier isEqualToString:kInviteContactButtonCell]) {
        cell = (InviteContactButtonCell*)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [(InviteContactButtonCell*)cell setFacebookStyleImageOnly];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    } else if ([identifier isEqualToString:kFacebookInviteHeaderCell]) {
        cell = (FacebookInviteHeaderCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        ((FacebookInviteHeaderCell *)cell).friendsLabel.text = [NSString stringWithFormat:@"%li of your Facebook", self.facebookFriends.count];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if ([identifier isEqualToString:kFacebookFriendsCell]) {
        cell = (FacebookFriendsCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        int j=0;
        for(int i = (int)(indexPath.row * FACEBOOK_FRIENDS_IMAGES_PER_CELL); i < (indexPath.row + 1) * FACEBOOK_FRIENDS_IMAGES_PER_CELL && i < self.facebookFriends.count; i++) {
            s = [NSString stringWithFormat:@"Using index %i, which translates to %i in cell\n", i, j];
            LOGGER(s);
            User *usr = [self.facebookFriends objectAtIndex:i];
            [(FacebookFriendsCell *)cell configureWithIndex:j andUser:usr];
            j++;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if ([identifier isEqualToString:kFacebookInviteAddAllCell]) {
        cell = (FacebookInviteAddAllCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        ((FacebookInviteAddAllCell *)cell).delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.contentView.backgroundColor = UNWINE_WHITE_BACK;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.facebookFriends.count < 1) {
        [self inviteFacebook];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addAll {
    // Send batch unWine follow/friend requests
    LOGGER(@"Enter");
    SHOW_HUD;
    [[self addAllUnWineUsers:self.facebookFriends] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD;
        
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            [self showAlertWithHeader:@"Spilled some wine"
                              message:@"Invites failed to send."
                        andButtonText:@"OK"
                                error:YES];
            return nil;
        }
        
        LOGGER(@"Successfully sent invite to ALL unWine Users");
        self.delegate.allFriendsInvited = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
        return nil;
    }];
}

- (void)addIndividually {
    @try {
        LOGGER(@"Hola");
        UserFriendsTVC *vc = ((UserFriendsTVC *)[[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"UserFriendsTVC"]);
        vc.users = self.facebookFriends;

        [self.navigationController pushViewController:vc animated:YES];

        //[self.delegate.navigationController performSegueWithIdentifier:@"UserFriendsTVCSegue" sender:self.delegate];
        LOGGER(@"Did the segue");
    } @catch (NSException *exception) {
        LOGGER(@"Something happened");
        LOGGER(exception);
    }
}
@end
