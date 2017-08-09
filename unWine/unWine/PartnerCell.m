//
//  PartnerCell.m
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "PartnerCell.h"
#define TEXT_LABEL_H 21
#define TEXT_LABEL_X (X2(self.imageView)        + WIDTH(self.imageView) + 8)
#define TEXT_LABEL_Y HEIGHT(self.contentView)/2 - TEXT_LABEL_H/2
#define TEXT_LABEL_W WIDTH(self.contentView)    - TEXT_LABEL_X - 8

@implementation PartnerCell
- (void)layoutSubviews {
    [super layoutSubviews];
    //self.imageView.frame = CGRectMake(20, 20, 60, 60);
    //self.textLabel.frame = CGRectMake(TEXT_LABEL_X, TEXT_LABEL_Y, TEXT_LABEL_W, TEXT_LABEL_H);
}
@end
