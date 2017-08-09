//
//  PartnersTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "PartnersTableViewController.h"
#import "UITableViewController+Helper.h"

static NSString *kClubWCellIdentifier = @"clubWCell";
static NSString *kAustinWineryIdentifier = @"austinWineryCell";
static NSString *kBeatBoxCellIdentifier = @"beatBoxCell";

@interface PartnersTableViewController ()

@end

@implementation PartnersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicAppeareanceSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:kClubWCellIdentifier forIndexPath:indexPath];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:kAustinWineryIdentifier forIndexPath:indexPath];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:kBeatBoxCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}



@end
