//
//  SettingCell.m
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SettingCell.h"
#import "RegistrationTVC.h"
#import "ParseSubclasses.h"
#import "CastProfileVC.h"
#import "ProfileTVC.h"
#import "NotificationTVC.h"
#import "iRate.h"
#import "iRate+extra.h"

@implementation SettingCell {
    UISwitch *switchView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.contentView.backgroundColor = UNWINE_WHITE_BACK;
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 40, SETTING_CELL_HEIGHT)];
        [self.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [self addSubview:self.titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 30, SCREEN_WIDTH - 40, 16)];
        [self.subtitleLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        self.subtitleLabel.alpha = 0;
        self.subtitleLabel.adjustsFontSizeToFitWidth = YES;
        self.subtitleLabel.minimumScaleFactor = .5;
        [self addSubview:self.subtitleLabel];
    }
}

- (void)configure:(SettingsRow *)row {
    self.cell = row.cell;
    self.type = row.type;
    
    User *user = [User currentUser];
    if(self.type == SettingsCellTypeSegue) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if(self.type == SettingsCellTypeSwitch) {
        self.accessoryType = UITableViewCellAccessoryNone;
        if(self.cell == SettingsCellSmartCellar) {
            self.accessoryView = [self getSwitchView:[user isUsingSmartCellar]];
        }
    } else if(self.type == SettingsCellTypeAction) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //vinecast scheme https://unwine.me/vinecast/?id=objectId
    
    NSInteger height = SETTING_CELL_HEIGHT, alpha = 0;
    if(self.cell == SettingsCellContactUs) {
        [self.titleLabel setText:@"Contact Us"];
        [self.subtitleLabel setText:@"Don't be shy, help improve unWine by leaving us feedback!"];
        height = 40;
        alpha = 1;
    } else if(self.cell == SettingsCellEditProfile) {
        [self.titleLabel setText:@"Edit Profile"];
    } else if(self.cell == SettingsCellManageAccount) {
        [self.titleLabel setText:@"Manage Account"];
    } else if(self.cell == SettingsCellPrivacyPolicy) {
        [self.titleLabel setText:@"Privacy Policy"];
    } else if(self.cell == SettingsCellPushNotification) {
        [self.titleLabel setText:@"Push Notifications"];
    } else if(self.cell == SettingsCellRateApp) {
        [self.titleLabel setText:@"Rate unWine"];
    } else if(self.cell == SettingsCellSignOut) {
        [self.titleLabel setText:@"Sign Out"];
        if([user isAnonymous]) {
            [self.subtitleLabel setText:@"As a Guest, your account will be lost forever!"];
            height = 40;
            alpha = 1;
        }
    } else if(self.cell == SettingsCellTellAFriend) {
        [self.titleLabel setText:@"Tell a Friend"];
    } else if(self.cell == SettingsCellTermsAndConditions) {
        [self.titleLabel setText:@"Terms and Conditions"];
    } else if(self.cell == SettingsCellResetTutorial) {
        [self.titleLabel setText:@"Reset Tutorial"];
    } else if(self.cell == SettingsCellClearAppData) {
        [self.titleLabel setText:@"Clear App Data"];
        [self.subtitleLabel setText:@"Spring cleaning for cached images."];
        height = 40;
        alpha = 1;
    } else if(self.cell == SettingsCellDeleteAccount) {
        [self.titleLabel setText:@"Delete Account"];
    } else if(self.cell == SettingsCellSwitchEnvDevelopment) {
        [self.titleLabel setText:[NSString stringWithFormat:@"Switch to %@ Environment", (GET_APP_DELEGATE).environment == DEVELOPMENT ? @"Production" : @"Development"]];
    } else if(self.cell == SettingsCellSmartCellar) {
        [self.titleLabel setText:@"Smart Cellar"];
        [self.subtitleLabel setText:@"Instantly add great wines to your Wish List."];
        height = 40;
        alpha = 1;
    }
    
    [self.titleLabel setFrame:CGRectMake(10, 0, SCREEN_WIDTH - 40, height)];
    self.subtitleLabel.alpha = alpha;
}

- (void)pressed {
    if(self.cell == SettingsCellContactUs) {
        [(GET_APP_DELEGATE).ctbc showUserVoice];
    } else if(self.cell == SettingsCellEditProfile) {
        [self editProfile];
    } else if(self.cell == SettingsCellManageAccount) {
        SettingsTVC *manage = [[SettingsTVC alloc] initWithStyle:UITableViewStylePlain];
        NSArray *rows = ![User currentUser].isAdmin ?
            @[[SettingsRow cell:SettingsCellDeleteAccount type:SettingsCellTypeAction]] :
            @[[SettingsRow cell:SettingsCellDeleteAccount type:SettingsCellTypeAction],
              [SettingsRow cell:SettingsCellSwitchEnvDevelopment type:SettingsCellTypeAction]];
        
        manage.objects = @[[SettingsSection title:@"Account" rows:rows]];
        [self.parent.navigationController pushViewController:manage animated:YES];
    } else if(self.cell == SettingsCellPrivacyPolicy) {
        [self settingsView:@"Privacy"];
    } else if(self.cell == SettingsCellPushNotification) {
        NotificationTVC *notification = [[NotificationTVC alloc] initWithStyle:UITableViewStylePlain];
        [self.parent.navigationController pushViewController:notification animated:YES];
    } else if(self.cell == SettingsCellRateApp) {
        [[UIApplication sharedApplication] openURL:[[iRate sharedInstance] ratingsURL]];
    } else if(self.cell == SettingsCellSignOut) {
        [User logOutAndDismiss:self.parent];
    } else if(self.cell == SettingsCellTellAFriend) {
        [[(GET_APP_DELEGATE).ctbc getProfileVC].profileTable inviteFriends:self.parent];
    } else if(self.cell == SettingsCellTermsAndConditions) {
        [self settingsView:@"Terms"];
    } else if(self.cell == SettingsCellResetTutorial) {
        [User unwitnessAllAlerts];
        
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Your tutorial has been reset!"];
        alert.centerButtonTitle = @"Keep unWineing";
        [alert show];
    } else if(self.cell == SettingsCellDeleteAccount) {
        [self settingsView:@"Delete"];
    } else if(self.cell == SettingsCellSwitchEnvDevelopment) {
        /*unWineAppDelegate *theDelegate = (GET_APP_DELEGATE);
        NSInteger env = theDelegate.environment == DEVELOPMENT ? PRODUCTION : DEVELOPMENT;
            
        [self switchEnvironment:env];*/
    }
}

- (void)settingsView:(NSString *)title {
    UIStoryboard *oldSettings = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *controller = [oldSettings instantiateViewControllerWithIdentifier:title];
    [self.parent.navigationController pushViewController:controller animated:YES];
}

- (void)editProfile {
    /*UIStoryboard *registrationStoryboard = [UIStoryboard storyboardWithName:@"MainNew" bundle:nil];
    RegistrationTVC *editController = [registrationStoryboard instantiateViewControllerWithIdentifier:@"registration"];
    
    editController.title = @"Edit Profile";
    editController.mode = EDIT_MODE;
    editController.hidesBottomBarWhenPushed = YES;
    
    [self.parent.navigationController pushViewController:editController animated:YES];*/
    
    [unWineAlertView showAlertViewWithTitle:@"Beta" message:@"Pending Update" cancelButtonTitle:@"Ok"];
}

/*- (void)switchEnvironment:(NSInteger)newEnvironment {
    unWineAppDelegate *theDelegate = (GET_APP_DELEGATE);
    [theDelegate myApplication:[UIApplication sharedApplication] didFinishLaunchingWithOptions:theDelegate.launchOptions withEnvironment:newEnvironment];
}*/

- (UISwitch *)getSwitchView:(BOOL)initial {
    if(!switchView) {
        switchView = [[UISwitch alloc] initWithFrame:(CGRect){ }];
        [switchView addTarget:self
                       action:@selector(switchAction:)
             forControlEvents:UIControlEventValueChanged];
    }
    switchView.on = initial;
    
    return switchView;
}

- (void)switchAction:(UISwitch *)someSwitch {
    if(self.cell == SettingsCellSmartCellar) {
        User *user = [User currentUser];
        [user setUserSetting:UserSettingSmartCellar value:@(someSwitch.on)];
        [[user saveInBackground] continueWithBlock:^id(BFTask *task) {
            NSLog(@"settings %@", user.userSettings);
            return nil;
        }];
    }
}

@end
