//
//  NotificationCell.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "InboxTVC.h"

@class InboxTVC;
@interface CastNotificationCell : UITableViewCell

@property (nonatomic) InboxTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Notification *object;

@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(Notification *)object;

@end
