//
//  SettingsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/29/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SettingsTVC.h"
#import "SettingCell.h"
#import "VineCastTVC.h"

@interface SettingsTVC ()

@end

@implementation SettingsTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Settings";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationController.view.tag == SHOW_SETTINGS_TAG) {
        self.navigationController.view.tag = 0;
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    self.navigationItem.title = @"Settings";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Back";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[SettingCell class] forCellReuseIdentifier:@"SettingCell"];
    self.tableView.backgroundColor = UNWINE_WHITE_BACK;//[(GET_APP_DELEGATE).ctbc getVinecastTVC].tableView.backgroundColor;
    self.tableView.tableFooterView = [self makeFooterView];
}

- (UIView *)makeFooterView {
    UIView *view = [UIView new];
    
    if(view) {
        [view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        
        NSInteger buffer = 8;
        UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(buffer, buffer * 2, WIDTH(view) - buffer * 2, 20)];
        [version setFont:[UIFont fontWithName:@"OpenSans-Italic" size:16]];
        [version setTextColor:[UIColor whiteColor]];
        [version setTextAlignment:NSTextAlignmentCenter];
        [version setText:[NSString stringWithFormat:@"unWine ® Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
        version.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        version.layer.shadowOffset = CGSizeMake(0, 1);
        version.layer.shadowOpacity = 1;
        version.layer.shadowRadius = 1.0;
        [view addSubview:version];
        
        NSInteger dim = 80;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SEMIWIDTH(view) - dim / 2, HEIGHT(version) + Y2(version), dim, dim)];
        [imageView setImage:[UIImage imageNamed:@"unWineLogo"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(0, 1);
        imageView.layer.shadowOpacity = 1;
        imageView.layer.shadowRadius = 1.0;
        [view addSubview:imageView];
    }
    
    return view;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (void)setupObjects {
    User *user = [User currentUser];
    if(_objects == nil) {
        NSMutableArray *accountRows = [[NSMutableArray alloc] initWithArray:
                                       @[[SettingsRow cell:SettingsCellPushNotification type:SettingsCellTypeSegue]]];
                                         //[SettingsRow cell:SettingsCellSmartCellar type:SettingsCellTypeSwitch]]];
        if(![user isAnonymous])
            [accountRows addObject:[SettingsRow cell:SettingsCellManageAccount type:SettingsCellTypeSegue]];
        [accountRows addObject:[SettingsRow cell:SettingsCellSignOut type:SettingsCellTypeSegue]];
        
        _objects = @[
                     [SettingsSection title:@"Account"
                                       rows:accountRows],
                     [SettingsSection title:@"Support and Feedback"
                                       rows:@[[SettingsRow cell:SettingsCellRateApp type:SettingsCellTypeSegue],
                                              [SettingsRow cell:SettingsCellContactUs type:SettingsCellTypeSegue],
                                              [SettingsRow cell:SettingsCellTellAFriend type:SettingsCellTypeSegue]]],
                     [SettingsSection title:@"General"
                                       rows:@[[SettingsRow cell:SettingsCellResetTutorial type:SettingsCellTypeSegue],
                                              //[SettingsRow cell:SettingsCellClearAppData type:SettingsCellTypeAction],
                                              [SettingsRow cell:SettingsCellPrivacyPolicy type:SettingsCellTypeSegue],
                                              [SettingsRow cell:SettingsCellTermsAndConditions type:SettingsCellTypeSegue]]]
                     ];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self setupObjects];
    return [_objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SETTING_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SettingsSection *obj = [_objects objectAtIndex:section];
    return [obj.rows count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 40)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    
    SettingsSection *obj = [_objects objectAtIndex:section];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH(self.tableView), 40)];
    [headerTitle setText:obj.title];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    SettingsSection *obj = [_objects objectAtIndex:indexPath.section];
    SettingsRow *row = [obj.rows objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.parent = self;
    
    [cell setup:indexPath];
    [cell configure:row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell pressed];
    [cell setSelected:NO animated:YES];
}

@end

@implementation SettingsSection

+ (id)title:(NSString *)title rows:(NSArray *)rows {
    SettingsSection *obj = [[SettingsSection alloc] init];
    obj.title = title;
    obj.rows = rows;
    return obj;
}

@end

@implementation SettingsRow

+ (id)cell:(SettingsCell)cell type:(SettingsCellType)type {
    SettingsRow *row = [[SettingsRow alloc] init];
    row.cell = cell;
    row.type = type;
    return row;
}

@end
