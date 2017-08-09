//
//  InviteContactButtonCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/14/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "InviteContactButtonCell.h"


NSString *fbImage = @"";
NSString *contactsImage = @"";
NSString *emailImage= @"";

@implementation InviteContactButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setFacebookStyle {
    self.sourceLabel.text = @"Facebook";
    self.imageIcon.style = 0;
    self.imageIcon.width = 20;
    self.imageIcon.height = 20;
    [self.imageIcon setNeedsDisplay];
}

- (void)setFacebookStyleImageOnly {
    self.sourceLabel.text = @"Grow your unWine network by inviting friends not yet on the unWine app to join!";
    self.imageIcon.style = 0;
    self.imageIcon.width = 20;
    self.imageIcon.height = 20;
    [self.imageIcon setNeedsDisplay];
}

- (void)setContactsStyle {
    self.sourceLabel.text = @"Contacts";
    self.imageIcon.style = 1;
    self.imageIcon.width = 20;
    self.imageIcon.height = 20;
    [self.imageIcon setNeedsDisplay];
}

- (void)setSMSStyle {
    self.sourceLabel.text = @"Invite via Text";
    self.imageIcon.hidden = YES;
    self.icon.image = [UIImage imageNamed:@"sms.png"];
}

- (void)setEmailStyle {
    self.sourceLabel.text = @"Invite via Email";
    self.imageIcon.style = 2;
    self.imageIcon.width = 20;
    self.imageIcon.height = 20;
    [self.imageIcon setNeedsDisplay];
}

@end
