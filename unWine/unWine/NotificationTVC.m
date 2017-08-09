//
//  NotificationTVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "NotificationTVC.h"
#import "VineCastTVC.h"
#import "SNotificationCell.h"

@interface NotificationTVC ()

@end

@implementation NotificationTVC {
    UIView *barricade;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(![Push isRegisteredForPushNotifications]) {
        if(!barricade) {
            barricade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), HEIGHT(self.tableView))];
            barricade.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
            barricade.userInteractionEnabled = YES;
            
            NSInteger buffer = 15;
            UITextView *barricadeLabel = [[UITextView alloc] initWithFrame:CGRectMake(buffer, 60, WIDTH(barricade) - buffer * 2, 180)];
            [barricadeLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
            [barricadeLabel setTextAlignment:NSTextAlignmentCenter];
            [barricadeLabel setTextColor:[UIColor whiteColor]];
            [barricadeLabel setText:@"You have notifications for unWine disabled, enable them in your device's Notification Settings so you don't miss out!"];
            barricadeLabel.backgroundColor = [UIColor clearColor];
            barricadeLabel.editable = NO;
            barricadeLabel.scrollEnabled = NO;
            barricadeLabel.userInteractionEnabled = NO;
            [barricade addSubview:barricadeLabel];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSettings)];
            [barricade addGestureRecognizer:tap];
            
            barricade.layer.zPosition = 1001;
            [self.tableView addSubview:barricade];
            self.tableView.scrollEnabled = NO;
        }
    }
}

- (void)toSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.view.tag = SHOW_SETTINGS_TAG;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[SNotificationCell class] forCellReuseIdentifier:@"SNotificationCell"];
    self.tableView.backgroundColor = [(GET_APP_DELEGATE).ctbc getVinecastTVC].tableView.backgroundColor;
    
    self.navigationItem.title = @"Push Notifications";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[Push notifications] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[Push notifications] objectAtIndex:section] getOptionNames] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 40)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    headerView.layer.zPosition = 1000;
    
    NotificationType type = (NotificationType)section;
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH(self.tableView), 40)];
    [headerTitle setText:[Push notificationName:type]];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SNotificationCell" forIndexPath:indexPath];
    NotificationType type = (NotificationType)indexPath.section;
    PushNotificationObject *obj = [Push notificationObject:type];
    NotificationsSetting setting = (NotificationsSetting)[[obj.settingOptions objectAtIndex:indexPath.row] integerValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.parent = self;
    
    [cell setup:indexPath];
    [cell configure:type setting:setting];
    
    if([[User currentUser] getNotificationStatus:type] == setting) {
        [cell showAccessory:NO];
    } else {
        [cell hideAccessory:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
        SNotificationCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        
        if (i != indexPath.row) { //the others
            [cell hideAccessory:YES];
        } else {
            User *user = [User currentUser];
            [user setNotificationStatus:cell.type setting:cell.setting];
            [user saveInBackground];
            [cell showAccessory:YES];
        }
        [cell setSelected:NO animated:YES];
    }
}

@end
