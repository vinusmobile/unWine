//
//  profileself.m
//  unWine
//
//  Created by Fabio Gomez on 8/22/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "profileCell.h"
#import "ParseSubclasses.h"

@implementation profileCell
@synthesize profileImageView, profileName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUpProfileImage];
        [self setUpProfileName];
        
        LOGGER(@"Initializing profile cell");
        
        //self.profileImageView.frame = CGRectMake(X2(self.profileImageView), Y2(self.profileImageView), 34, 34);
    }
    return self;
}

/*
- (void)awakeFromNib
{
    // Initialization code
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setUpProfileImage{
    
    UIColor* imageBorderColor = [UIColor colorWithRed:43.0/255 green:90.0/255 blue:131.0/255 alpha:0.4];
    
    [[User currentUser] setUserImageForImageView:self.profileImageView];
    
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.cornerRadius = 17.f;
    self.profileImageView.layer.borderWidth = .5f;
    self.profileImageView.layer.borderColor = imageBorderColor.CGColor;
}

- (void)setUpProfileName{
    
    self.profileName.text = [[User currentUser] getName];
    
    //self.profileName.font = [UIFont systemFontOfSize:17];
    self.profileName.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:15];
    self.profileName.textColor = [UIColor colorWithRed:171.0/255 green:17.0/255 blue:36.0/255 alpha:1.0];
    self.profileName.numberOfLines = 0;
    self.profileName.lineBreakMode = NSLineBreakByWordWrapping;
    
}


@end
