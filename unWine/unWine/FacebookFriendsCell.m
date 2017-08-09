//
//  FacebookFriendsCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FacebookFriendsCell.h"
#import "UIImageView+AFNetworking.h"

@implementation FacebookFriendsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.image0.image = nil;
    self.image1.image = nil;
    self.image2.image = nil;
    self.image3.image = nil;
    self.image4.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithIndex:(int)index andUser:(User *)user {
    NSString *url = [user getProfileImageURL];
    
    switch (index) {
        case 0:
            self.image0.file = user.imageFile;
            [self.image0 setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
            url = self.image0.file.url;
            //[self.image0 loadInBackground];
            break;
        case 1:
            self.image1.file = user.imageFile;
            [self.image1 setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
            //[self.image1 loadInBackground];
            break;
        case 2:
            self.image2.file = user.imageFile;
            [self.image2 setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
            //[self.image2 loadInBackground];
            break;
        case 3:
            self.image3.file = user.imageFile;
            [self.image3 setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
            //[self.image3 loadInBackground];
            break;
        case 4:
            self.image4.file = user.imageFile;
            [self.image4 setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
            //[self.image4 loadInBackground];
            break;
    }
    NSString *s = [NSString stringWithFormat:@"Using URL %@", url];
    LOGGER(s);
}

@end
