//
//  customWineCell.m
//  unWine
//
//  Created by Anggi Priatmadi on 4/27/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "customWineCell.h"

@implementation customWineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
