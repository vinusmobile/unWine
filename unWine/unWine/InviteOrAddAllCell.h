//
//  InviteAllCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/16/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#define INVITE_CELL_ADD_ALL 123
#define INVITE_CELL_INVITE_ALL 456

@class ContactsInviteTVC;

@interface InviteOrAddAllCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *inviteLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectAllButton;
@property (strong, nonatomic) ContactsInviteTVC *delegate;

- (void)setLayoutToDefault;
- (void)setLayoutToAllUsersInvited;
- (IBAction)inviteAll:(id)sender;

@end
