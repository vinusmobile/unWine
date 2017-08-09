//
//  SNotificationCell.h
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationTVC.h"

@interface SNotificationCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *accessory;

@property (nonatomic) NotificationTVC *parent;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NotificationType type;
@property (nonatomic) NotificationsSetting setting;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(NotificationType)type setting:(NotificationsSetting)setting;

- (void)showAccessory:(BOOL)animated;
- (void)hideAccessory:(BOOL)animated;

@end
