//
//  InviteAllCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/16/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "InviteOrAddAllCell.h"
#import "ContactsInviteTVC.h"

@implementation InviteOrAddAllCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    GREEN_BUTTON(self.selectAllButton);

    self.backgroundColor = UNWINE_WHITE_BACK;
    self.layer.borderWidth = .2f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)setLayoutToDefault {
    LOGGER(@"Enter");
    GREEN_BUTTON(self.selectAllButton);
    [self.selectAllButton setTitle:@"ADD ALL" forState:UIControlStateNormal];
    self.selectAllButton.userInteractionEnabled = TRUE;
    [self setNeedsDisplay];
}

- (void)setLayoutToAllUsersInvited {
    LOGGER(@"Enter");
    GRAY_BUTTON(self.selectAllButton);
    [self.selectAllButton setTitle:@"ALL CONTACTS ADDED" forState:UIControlStateNormal];
    self.selectAllButton.userInteractionEnabled = FALSE;
    [self setNeedsDisplay];
}

- (IBAction)inviteAll:(id)sender {
    LOGGER(@"Enter");
    NSString *s = [NSString stringWithFormat:@"Tag %li", self.tag];
    LOGGER(s);
    
    if (self.tag == INVITE_CELL_ADD_ALL) {
        [self.delegate addAll];
    } else if (self.tag == INVITE_CELL_INVITE_ALL) {
        [self.delegate inviteAll];
    }
}
@end
