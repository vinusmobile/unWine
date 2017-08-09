//
//  InvitePromptCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/13/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "InvitePromptCell.h"

@implementation InvitePromptCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.promptLabel.text = @"Share reviews, wine recommendations, and more when you connect with friends on unWine!";
    
    CGRect frame = self.promptLabel.frame;
    
    // Configure the view for the selected state
    if (IS_IPHONE_6P || IS_IPHONE_6) {
        frame.size.width = 345;
        self.promptLabel.frame = frame;
        
    } else {
        frame.size.width = 320;
        self.promptLabel.frame = frame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
