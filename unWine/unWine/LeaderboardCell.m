//
//  LeaderboardCell.m
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "LeaderboardCell.h"

@implementation LeaderboardCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)path {
    self.path = path;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.userPhoto.layer.cornerRadius = SEMIWIDTH(self.userPhoto);
        self.userPhoto.layer.borderColor = [[UIColor blackColor] CGColor];
        self.userPhoto.layer.borderWidth = .5f;
        self.userPhoto.clipsToBounds = YES;
        self.userPhoto.userInteractionEnabled = YES;
        
        [self.usernameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.usernameLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        
        [self.grapeLabel setTextAlignment:NSTextAlignmentRight];
        [self.grapeLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
        [self.grapeLabel setTextColor:[UIColor redColor]];
    }
}

- (void)configure:(User *)object {
    self.object = object;
    [self configureUserImage:self.path usingObject:self.object];
    
    [self.usernameLabel setText:[object[@"canonicalName"] capitalizedString]];
    [self.grapeLabel setText:[NSString stringWithFormat:@"%ld", (long)object.currency]];
}

- (void)configureUserImage:(NSIndexPath *)indexPath usingObject:(PFObject *)object {
    PFFile *theImage = object[@"imageFile"];
    
    if(theImage != nil && theImage.url != nil) {
        self.userPhoto.image = [UIImage imageNamed:@"user"];
        self.userPhoto.file = theImage;
        [self.userPhoto loadInBackground];
    } else {
        NSString *userImageURL = object[@"profile"][@"picture"];
        [self.userPhoto setImageWithURL:[NSURL URLWithString:userImageURL] placeholderImage:[UIImage imageNamed:@"user"]];
    }
    
    self.userPhoto.tag = indexPath.section;
    self.userPhoto.contentMode = UIViewContentModeScaleAspectFill;
    self.userPhoto.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
    [self.userPhoto addGestureRecognizer:tapProfile];
}

- (void)profilePressed:(UITapGestureRecognizer *)recognizer {
    User *user = self.object;
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    //CastProfileVC *profile = [[CastProfileVC alloc] initWithFrame:self.delegate.view.frame andUser:user];
    
    [profile setProfileUser:user];
    //if(self.delegate.singleUser == nil)
        [self.delegate.navigationController pushViewController:profile animated:YES];
    //} else {
    //    [profile.profile profilePressed:recognizer];
    //}
}


@end
