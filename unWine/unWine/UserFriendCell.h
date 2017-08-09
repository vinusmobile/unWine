//
//  UserFriendCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFriendCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

- (void)configureWithUser:(User *)user;

@end
