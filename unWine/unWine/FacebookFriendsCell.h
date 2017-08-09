//
//  FacebookFriendsCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FACEBOOK_FRIENDS_IMAGES_PER_CELL 5

@interface FacebookFriendsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *image0;
@property (strong, nonatomic) IBOutlet PFImageView *image1;
@property (strong, nonatomic) IBOutlet PFImageView *image2;
@property (strong, nonatomic) IBOutlet PFImageView *image3;
@property (strong, nonatomic) IBOutlet PFImageView *image4;

- (void)configureWithIndex:(int)index andUser:(User *)user;

@end
