//
//  SettingsTVC.h
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"

#define SETTING_CELL_HEIGHT 54

typedef enum SettingsCell {
    SettingsCellEditProfile,
    SettingsCellPushNotification,
    SettingsCellManageAccount,
    SettingsCellSignOut,
    SettingsCellRateApp,
    SettingsCellContactUs,
    SettingsCellTellAFriend,
    SettingsCellPrivacyPolicy,
    SettingsCellTermsAndConditions,
    SettingsCellResetTutorial,
    SettingsCellDeleteAccount,
    SettingsCellSwitchEnvDevelopment,
    SettingsCellSmartCellar,
    SettingsCellClearAppData,
    SettingsCellSwitchEnvLocal
} SettingsCell;

typedef enum SettingsCellType {
    SettingsCellTypeSegue,
    SettingsCellTypeSwitch,
    SettingsCellTypeAction
} SettingsCellType;

@interface SettingsRow : NSObject

@property (nonatomic) SettingsCell cell;
@property (nonatomic) SettingsCellType type;

+ (id)cell:(SettingsCell)cell type:(SettingsCellType)type;

@end


@interface SettingsSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<SettingsRow *> *rows;

+ (id)title:(NSString *)title rows:(NSArray *)rows;

@end


@interface SettingsTVC : UITableViewController

@property (nonatomic, strong) NSArray<SettingsSection *> *objects;

@end
