//
//  RequestCell.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastRequestCell.h"
#import "CastProfileVC.h"

@implementation CastRequestCell

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
        
        //self.acceptButton.layer.cornerRadius = .5f * WIDTH(self.acceptButton);
        self.acceptButton.clipsToBounds = YES;
        self.acceptButton.userInteractionEnabled = YES;
        //self.acceptButton.backgroundColor = [UIColor greenColor];
        
        UITapGestureRecognizer *accept = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(acceptFriendship:)];
        [self.acceptButton addGestureRecognizer:accept];
        
        //self.declineButton.layer.cornerRadius = .5f * WIDTH(self.declineButton);
        self.declineButton.clipsToBounds = YES;
        self.declineButton.userInteractionEnabled = YES;
        //self.declineButton.backgroundColor = [UIColor redColor];
        
        UITapGestureRecognizer *decline = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(declineFriendship:)];
        [self.declineButton addGestureRecognizer:decline];
    }
}

- (void)acceptFriendship:(UIGestureRecognizer *)gesture {
    [self.delegate acceptFriendship:self.object];
}

- (void)declineFriendship:(UIGestureRecognizer *)gesture {
    [self.delegate declineFriendship:self.object];
}

- (void)profilePressed:(UIGestureRecognizer *)gesture {
    User *somebody = self.object.fromUser;
    if(somebody == nil)
        return;
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    [profile setProfileUser:somebody];
    
    [self.delegate.navigationController pushViewController:profile animated:YES];
}

- (void)configure:(Friendship *)object {
    self.object = object;
    
    [[object fromUser] setUserImageForImageView:self.userImage];
    [self.userLabel setText:[NSString stringWithFormat:@"%@ wants to be friends!", [[self.object fromUser] getName]]];
}

- (void)showErrorAlert:(NSError *)error {
    [unWineAlertView showAlertViewWithTitle:nil error:error];
}

@end
