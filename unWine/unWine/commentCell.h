//
//  commentCell.h
//  unWine
//
//  Created by Fabio Gomez on 5/21/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface commentCell : PFTableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;

@property (strong, nonatomic) IBOutlet UITextView *commentView;

@end
