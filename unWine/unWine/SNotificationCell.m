//
//  SNotificationCell.m
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SNotificationCell.h"
#import "ParseSubclasses.h"

@implementation SNotificationCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 40, 54)];
        [self.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [self addSubview:self.titleLabel];
        
        NSInteger dim = 36;
        NSInteger buffer = (54 - dim) / 2;
        self.accessory = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - dim - buffer, buffer, dim, dim)];
        [self.accessory setImage:[UIImage imageNamed:@"acceptAll"]];
        [self.accessory setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.accessory];
        self.accessory.alpha = 0;
    }
}

- (void)configure:(NotificationType)type setting:(NotificationsSetting)setting {
    self.type = type;
    self.setting = setting;
    
    [self.titleLabel setText:[Push settingName:setting]];
}

- (void)showAccessory:(BOOL)animated {
    if(animated)
        [UIView animateWithDuration:.2 animations:^{
            self.accessory.alpha = 1;
        }];
    else
        self.accessory.alpha = 1;
}

- (void)hideAccessory:(BOOL)animated {
    if(animated)
        [UIView animateWithDuration:.2 animations:^{
            self.accessory.alpha = 0;
        }];
    else
        self.accessory.alpha = 0;
}

@end
