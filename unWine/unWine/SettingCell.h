//
//  SettingCell.h
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsTVC.h"

@interface SettingCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic) SettingsTVC *parent;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) SettingsCell cell;
@property (nonatomic) SettingsCellType type;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(SettingsRow *)row;
- (void)pressed;

@end
