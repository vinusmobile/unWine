//
//  FriendInvitePlaceholderCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/13/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FriendInvitePlaceholderCell.h"

@implementation FriendInvitePlaceholderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bannerImageView.image = [UIImage imageNamed:@"Share_Reviews_Image.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
