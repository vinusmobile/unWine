//
//  profileCell.h
//  unWine
//
//  Created by Fabio Gomez on 8/22/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#define PROFILE_CELL_HEIGHT 52.0f
#define PROFILE_CELL_IDENTIFIER @"profileCell"
#define PROFILE_CELL_ROW 0
#define PROFILE_MINIGAME_HEIGHT 106.0f//76.0f //64.0f
#define PROFILE_MINIGAME_IDENTIFIER @"minigameCell"

@interface profileCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *attemptsLabel;

- (void)setUpProfileImage;
- (void)setUpProfileName;

@end
