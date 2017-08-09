//
//  ContactsInviteTVC.h
//  unWine
//
//  Created by Fabio Gomez on 6/12/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContactInviteCell,APContact;

typedef enum InviteSourceType {
    InviteSourceTypeSignUp = 0,
    InviteSourceTypeVineCast,
    InviteSourceTypeProfile
} InviteSourceType;

@interface ContactsInviteTVC : UITableViewController

@property (nonatomic, ) InviteSourceType source;

- (void)addAll;
- (void)inviteAll;
- (void)inviteContact:(APContact *)contact fromSender:(ContactInviteCell *)cell;
- (void)showAlertWithHeader:(NSString *)header message:(NSString *)message andButtonText:(NSString *)buttonText error:(BOOL)error;

@end
