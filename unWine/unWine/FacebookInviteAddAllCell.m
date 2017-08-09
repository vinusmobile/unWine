//
//  FacebookInviteAddAllCell.m
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FacebookInviteAddAllCell.h"
#import "FacebookInviteTVC.h"

@implementation FacebookInviteAddAllCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    GREEN_BUTTON(self.addAllButton);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addAllUsers:(id)sender {
    [self.delegate addAll];
}

- (IBAction)addIndividually:(id)sender {
    [self.delegate addIndividually];
}
@end
