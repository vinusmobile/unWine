//
//  CIShareCell.m
//  unWine
//
//  Created by Bryce Boesen on 5/2/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MergeNextCell.h"
#import "CastMergeTVC.h"

@implementation MergeNextCell
@synthesize delegate, hasSetup, myPath, wine;
@synthesize nextButton;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    myPath = indexPath;
    
    if(!hasSetup) {
        hasSetup = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        nextButton.backgroundColor = [UIColor whiteColor];
        nextButton.layer.borderWidth = 2;
        nextButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        nextButton.layer.cornerRadius = 6;
        nextButton.layer.masksToBounds = YES;
        nextButton.clipsToBounds = YES;
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [nextButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
    }
}

- (void)configure:(PFObject *)object {
    wine = object;
}

- (IBAction)clickEdit:(id)sender {
    CastMergeTVC *parent = (CastMergeTVC *)delegate;
    [parent clickNext];
}

@end
