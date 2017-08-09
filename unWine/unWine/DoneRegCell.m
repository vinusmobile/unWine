//
//  DoneRegCell.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "DoneRegCell.h"
#import "RegistrationTVC.h"

@interface DoneRegCell ()
@property (nonatomic, strong) RegistrationTVC *parent;
@end

@implementation DoneRegCell
@synthesize parent, doneButton;

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.doneButton.titleLabel.font = UNWINE_FONT_TEXT;
    self.doneButton.layer.cornerRadius = 30; // this value vary as per your desire
    self.doneButton.clipsToBounds = YES;
    self.doneButton.backgroundColor = UNWINE_RED;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
}

- (IBAction)checkProfile:(id)sender {
    [self.parent checkProfile];
}


@end
