//
//  ContactInviteCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/15/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APContact, ContactsInviteTVC;

@interface ContactInviteCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *thumbNail;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic)          ContactsInviteTVC *delegate;

- (void)configureWithUser:(User *)u;
- (void)configureWithContact:(APContact *)c;
- (IBAction)sendInvite:(id)sender;

- (void)setSuccessfulInviteForContact;
@end
