//
//  ContactInviteCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/15/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "ContactInviteCell.h"
#import <APAddressBook/APContact.h>
#import "ContactsInviteTVC.h"

@interface ContactInviteCell ()

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) APContact *contact;

@end

@implementation ContactInviteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Make circle
    // Set Label Font and Size
    GREEN_BUTTON(self.addButton);
    
    CIRCLE(self.thumbNail);
    
    self.backgroundColor = UNWINE_WHITE;
    [self updateLayoutToAdd];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sendInvite:(id)sender {
    if (self.contact) {
        [self.delegate inviteContact:self.contact fromSender:self];
    } else if (self.user) {
        [self sendInviteToUser];
    } else {
        LOGGER(@"Inviting no one");
    }
}

- (NSMutableArray <NSNumber *>*)getInviteArray {
    printf("\n\n");
    NSMutableArray <NSNumber *> *invites = [NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults] arrayForKey:INVITE_DEFAULTS]];
    if (invites == nil) {
        LOGGER(@"Creating new invites array");
        invites = [[NSMutableArray alloc] init];
    }
    NSString *s = [NSString stringWithFormat:@"Found %li invites in INVITE_DEFAULTS", invites.count];
    LOGGER(s);
    
    printf("\n\n");
    
    return invites;
}

#pragma mark - Contact Stuff
- (void)configureWithContact:(APContact *)c {
    if (c == nil) {
        LOGGER(@"No contact");
        return;
    }
    
    self.contact = c;
    self.user = nil;

    if (c.emails.count > 0) {
        [self setNameLabelWithName:c.name.compositeName andEmail:c.emails.firstObject.address];
        
    } else {
        self.nameLabel.text = c.name.compositeName;
    }
    
    self.thumbNail.image = c.thumbnail ? c.thumbnail : USER_PLACEHOLDER;
    
    // Check if User Defaults has an invite for this contact
    // Check for contact name, or maybe APContact id
    // If it exists, then say Pending or Invited - with a different button color
    // Else, just keep the default Invite
    // For invite, might have to change the frame
    [self checkContactInviteAndUpdateView];
}

- (void)setNameLabelWithName:(NSString *)name andEmail:(NSString *)email {
    
    // Do formatted string
    // First line is name as usual
    // Second line is email with smaller font
    // Attributed label
    // Create the attributes
    NSString *text = [NSString stringWithFormat:@"%@\n%@", name, email];
    
    
    const CGFloat fontSize = 17;
    const CGFloat subFontSize = 13;
    NSDictionary *attrs = @{
                            NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                            NSForegroundColorAttributeName:[UIColor blackColor]
                            };
    NSDictionary *subAttrs = @{
                               NSFontAttributeName:[UIFont systemFontOfSize:subFontSize],
                               NSForegroundColorAttributeName:[UIColor lightGrayColor]
                               };
    
    // Range of " 2012/10/14 " is (8,12). Ideally it shouldn't be hardcoded
    // This example is about attributed strings in one label
    // not about internationalisation, so we keep it simple :)
    // For internationalisation example see above code in swift
    //const NSRange range = NSMakeRange(8,12);
    const NSRange range = [text rangeOfString:email];
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    
    // Set it in our UILabel and we are done!
    [self.nameLabel setAttributedText:attributedText];
}

- (void)checkContactInviteAndUpdateView {
    if (self.contact == nil) {
        LOGGER(@"No contact provided");
        return;
    }
    
    NSMutableArray <NSNumber *> *invites = [self getInviteArray];
    BOOL hasInvite = NO;
    
    for (NSNumber *recordID in invites) {
        if (recordID.intValue == self.contact.recordID.intValue) {
            NSString *s = [NSString stringWithFormat:@"Found invite for contact \"%@\" with Name \"%i\"", self.contact.name.compositeName, self.contact.recordID.intValue];
            LOGGER(s);
            hasInvite = YES;
            break;
        }
    }
    
    if (hasInvite) {
        // Change layout
        [self updateLayoutToInviteSent];
    } else {
        [self updateLayoutToAdd];
    }
}

- (void)updateLayoutToAdd {
    GREEN_BUTTON(self.addButton);
    [self.addButton setTitle: @"Add" forState: UIControlStateNormal];
    self.addButton.userInteractionEnabled = TRUE;
}

- (void)updateLayoutToInviteSent {
    GRAY_BUTTON(self.addButton);
    [self.addButton setTitle: @"Sent" forState: UIControlStateNormal];
    self.addButton.userInteractionEnabled = FALSE;
}

- (void)setSuccessfulInviteForContact {
    if (self.contact == nil) {
        LOGGER(@"No contact provided");
        return;
    }
    
    @try {
        LOGGER(@"Enter");
        
        NSMutableArray *invites = [self getInviteArray];
        [invites addObject:self.contact.recordID];

        LOGGER(@"Updating standardUserDefaults");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:invites forKey:INVITE_DEFAULTS];
        [defaults synchronize];
        invites = [self getInviteArray];
        LOGGER(@"Done Updating standardUserDefaults");

        [self updateLayoutToInviteSent];
        
    } @catch (NSException *exception) {
        LOGGER(@"Something happened");
        LOGGER(exception);
    }
}

#pragma mark = unWine User Stuff

- (void)configureWithUser:(User *)u {
    if (u == nil) {
        LOGGER(@"No user");
        return;
    }
    
    self.user = u;
    self.contact = nil;
    
    self.nameLabel.text = [self.user getName];
    self.thumbNail.file = self.user.imageFile;
    self.thumbNail.image = USER_PLACEHOLDER;
    [self.thumbNail loadInBackground];
    
    [self updateLayoutToAdd];
    [self checkUserInviteAndUpdateView];
}

- (void)checkUserInviteAndUpdateView {
    if (self.user == nil) {
        LOGGER(@"No user provided");
        return;
    }

    [[[User currentUser] getFriendshipWithUser:self.user] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (t.result) {
            Friendship *f = (Friendship *)t.result;
            
            if ([f isPending]) {
                // Do pending/set layout
                [self updateLayoutToInviteSent];
            } else {
                // Do add layout
                [self updateLayoutToAdd];
            }
        }
        
        return nil;
    }];
}

- (void)sendInviteToUser {
    if (self.user == nil) {
        LOGGER(@"No user provided");
        return;
    }
    
    LOGGER(@"Sending friend request to user");
    
    SHOW_HUD_FOR_VIEW(self.delegate.view);
    
    [[Friendship sendFriendRequest:self.user ignoreError:FALSE] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<Friendship *> * _Nonnull t) {
        HIDE_HUD_FOR_VIEW(self.delegate.view);
        
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            [self.delegate showAlertWithHeader:@"Spilled some wine"
                                       message:@"Invite failed to send."
                                 andButtonText:@"OK"
                                         error:YES];
        } else {
            LOGGER(@"Successfully sent invite to user");
            [self updateLayoutToInviteSent];
        }
        
        return nil;
    }];
}

@end
