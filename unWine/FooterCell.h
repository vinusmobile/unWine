//
//  WineDetailCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VineCastCell.h"
#import "unWineActionSheet.h"
#import "Reaction.h"

@interface FooterCell : VineCastCell <unWineActionSheetDelegate, ReactionViewDelegate>

@property (strong, nonatomic) UIButton *flagButton;
@property (strong, nonatomic) UIButton *toastButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) ReactionView *reactionView;

- (void)configureToastButton:(NewsFeed *)object;
- (void)configureCommentButton:(NewsFeed *)object;
- (void)toastPressed:(UIGestureRecognizer *)recognizer;

@end
