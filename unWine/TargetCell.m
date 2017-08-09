//
//  ToggleCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "TargetCell.h"
#import "VineCastTVC.h"
#import "MeritsTVC.h"
#import "CastDetailTVC.h"
#import "Grapes.h"
#import "User.h"
#import "CheckinInterface.h"

@implementation TargetCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
}

- (void) setup {
    [super setup];
    
    self.titleLabel.textColor = UNWINE_RED;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    /*self.layer.shadowColor = [UNWINE_GRAY CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
     self.layer.shadowRadius = 1;*/
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border.frame = CGRectMake(2, 0, SCREEN_WIDTH - 4, .5);
    [self.layer addSublayer:border];
    
    CALayer *border2 = [CALayer layer];
    border2.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border2.frame = CGRectMake(2, 44 - .5, SCREEN_WIDTH - 4, .5);
    [self.layer addSublayer:border2];
}

- (void)pushSingle:(UIGestureRecognizer *)recognizer {
    if(ISVALID(self.delegate.singleObjectId)) {
        self.delegate.singleObject = nil;
        self.delegate.singleObjectId = nil;
        self.delegate.singleObjectType = nil;
        [self.delegate.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    VineCastTVC *feed = [self.delegate.storyboard instantiateViewControllerWithIdentifier:@"feed"];
    [feed setVineCastSingleObject:self.object];
    
    [self.delegate.navigationController pushViewController:feed animated:YES];
}

- (void)inspectWine:(UIGestureRecognizer *)recognizer {
    if(self.object[@"unWinePointer"] == nil) {
        
        [unWineAlertView showAlertViewWithTitle:@"Sorry!" message:@"This wine is no longer available, one of the unwinegineers must have drank it all. Again..."];
        return;
    }
    unWine *wine = self.object[@"unWinePointer"];
    
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = wine;
    container.isNew = NO;
    container.cameFrom = CastCheckinSourceVinecast;
    [self.delegate.navigationController pushViewController:container animated:YES];
}

- (void)exploreMerits:(UIGestureRecognizer *)recognizer {
    MeritsTVC *push = [[UIStoryboard storyboardWithName:@"Merits" bundle:nil] instantiateInitialViewController];
    push.meritMode = MeritModeDiscoverUser;
    push.earnedMerits = [User currentUser].earnedMerits;
    [self.delegate.navigationController pushViewController:push animated:YES];
}

@end
