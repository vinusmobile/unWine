//
//  UserFriendCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "UserFriendCell.h"

@implementation UserFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = UNWINE_WHITE_BACK;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureWithUser:(User *)user {
    if (user == nil) {
        LOGGER(@"User was not provided");
    }
    
    LOGGER(@"Got user");
    self.userNameLabel.text = [user getName];
    self.userImage.file = user.imageFile;
    self.userImage.image = USER_PLACEHOLDER;
    [self.userImage loadInBackground];
    CIRCLE(self.userImage);
}

@end
