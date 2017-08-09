//
//  RequestCell.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "InboxTVC.h"

@class InboxTVC;
@interface CastRequestCell : UITableViewCell <unWineAlertViewDelegate>

@property (nonatomic) InboxTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Friendship *object;

@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIImageView *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *declineButton;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(Friendship *)object;

@end
