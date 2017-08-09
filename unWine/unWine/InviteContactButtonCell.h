//
//  InviteContactButtonCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/14/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendStyleKitView.h"

@interface InviteContactButtonCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FriendStyleKitView *imageIcon;
@property (strong, nonatomic) IBOutlet UILabel *sourceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *icon;

- (void)setFacebookStyle;
- (void)setFacebookStyleImageOnly;
- (void)setContactsStyle;
- (void)setSMSStyle;
- (void)setEmailStyle;

@end
