//
//  TitleProfileCell.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "TitleProfileCell.h"

@implementation TitleProfileCell

@synthesize title;

- (void)awakeFromNib {
    // Initialization code
    LOGGER(@"Setting Up Title Cell");
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.title.textColor = [UIColor whiteColor];
    self.title.font = UNWINE_FONT_TEXT_XSMALL;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUp {
    
}


@end
