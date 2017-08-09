//
//  NotificationCell.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastNotificationCell.h"
#import "CastProfileVC.h"

@implementation CastNotificationCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.userLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.userLabel.numberOfLines = 0;
        self.userLabel.textColor = [UIColor blackColor];
        [self.userLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
        
        self.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.userImage.layer.borderWidth = .5f;
        self.userImage.layer.cornerRadius = .5f * WIDTH(self.userImage);
        self.userImage.clipsToBounds = YES;
        self.userImage.userInteractionEnabled = YES;
        [self.userImage setContentMode:UIViewContentModeScaleAspectFill];
        
        UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
        [self.userImage addGestureRecognizer:tapProfile];
    }
}

- (void)profilePressed:(UIGestureRecognizer *)gesture {
    User *somebody = [self.object Author];
    if(somebody == nil)
        return;
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    [profile setProfileUser:somebody];
    
    [self.delegate.navigationController pushViewController:profile animated:YES];
}

- (void)configure:(Notification *)object {
    self.object = object;
    
    if (!object.viewed) {
        self.backgroundColor = [UIColor colorWithRed:0.928431 green:0.929209 blue:0.92116 alpha:1];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    [[object Author] setUserImageForImageView:self.userImage];
    
    self.userLabel.text = [self.object getNotificationMessage];
    
    //[self.userLabel sizeToFit];
}


@end
