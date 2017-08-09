//
//  LeaderboardTVC.m
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "LeaderboardTVC.h"

@interface LeaderboardTVC ()

@end

@implementation LeaderboardTVC {
    NSMutableArray *friends;
    NSArray *global;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    [self loadTheGoods];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.grapesButton == nil)
        self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
    self.grapesButton.customView.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = self.grapesButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.grapesButton == nil)
        self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
    [Grapes userUpdateCurrency:^(NSInteger grapes) {
        self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
    }];
    
    [self basicAppeareanceSetup];
}

- (void)loadTheGoods {
    friends = [NSMutableArray arrayWithArray:@[[User currentUser]]];
    
    PFQuery *query = [User query];
    [query orderByDescending:@"currency"];
    [query whereKeyExists:@"canonicalName"];
    [query whereKey:@"canonicalName" notEqualTo:@""];
    [query setLimit:50];
    
    NSArray *tasks = @[[[User currentUser] getFriends], [query findObjectsInBackground]];
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        BFTask *friendTask = [tasks objectAtIndex:0];
        BFTask *globalTask = [tasks objectAtIndex:1];
        
        friends = [friendTask.result mutableCopy];
        [[User currentUser] getFriendCount];
        [friends addObject:[User currentUser]];
        
        [friends sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"currency" ascending:NO], nil]];
        
        global = [globalTask.result copy];
        
        [self.tableView reloadData];
        return nil;
    }];
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showLeaderboards {
    [Grapes showLeaderboards:self.navigationController];
}

- (void)showPurchases {
    [Grapes showPurchases:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return @"Friends"; // friends
            break;
        case 1:
            return @"Global (Top 50)"; // global top 50
            break;
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return (friends == nil) ? 0 : [friends count]; // friends
            break;
        case 1:
            return (global == nil) ? 0 : [global count]; // global top 50
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    User *object;
    switch(indexPath.section) {
        case 0:
            object = [friends objectAtIndex:indexPath.row];
            
            cell.delegate = self;
            
            [cell setup:indexPath];
            [cell configure:object];
            break;
        case 1:
            object = [global objectAtIndex:indexPath.row];
            
            cell.delegate = self;
            
            [cell setup:indexPath];
            [cell configure:object];
            break;
    }
    
    return cell;
}

@end
