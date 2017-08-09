//
//  CIShareCell.m
//  unWine
//
//  Created by Bryce Boesen on 5/2/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CIShareCell.h"
#import "CastCheckinTVC.h"

@implementation CIShareCell
@synthesize delegate, hasSetup, myPath, wine;
@synthesize shareButton;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    myPath = indexPath;
    
    if(!hasSetup) {
        hasSetup = YES;
        
        shareButton.backgroundColor = [UIColor whiteColor];
        shareButton.layer.borderWidth = 2;
        shareButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        shareButton.layer.cornerRadius = 6;
        shareButton.layer.masksToBounds = YES;
        shareButton.clipsToBounds = YES;
        [shareButton setTitle:@"Check In" forState:UIControlStateNormal];
        [shareButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
    }
}

- (void)configure:(unWine *)wineObject {
    self.wine = wineObject;
}

- (IBAction)clickShare:(id)sender {
    //CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    shareButton.layer.borderColor = [UNWINE_RED CGColor];
    
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Are you sure wish to checkin with this information?"];
    alert.delegate = self;
    alert.leftButtonTitle = @"No";
    alert.rightButtonTitle = @"Yes";
    alert.tag = 1;
    [alert show];
}

- (void)leftButtonPressed {
    shareButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)rightButtonPressed {
    
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    [parent finalCheckin];
}

@end
