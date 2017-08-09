//
//  discoverTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/28/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "discoverTableViewController.h"
#import <Parse/Parse.h>
#import "UITableViewController+Helper.h"
#import "MeritsTVC.h"
#import "ParseSubclasses.h"

@interface discoverTableViewController () {
    PFObject *clubWMeritObject;
}

@end

@implementation discoverTableViewController

- (void)viewWillAppear:(BOOL)animated {
    /*if(!self.grapesButton)
        self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
    self.navigationItem.rightBarButtonItem = self.grapesButton;*/
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicAppeareanceSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 3:
            return @"People";
            break;
        case 2:
            return @"Wines";
            break;
        case 1:
            return @"Merits";
            break;
        case 0:
            return @"Partners";
            break;
        default:
            return @"";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"userSearchCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"userSearchCell" forIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"wineSearchCell" forIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"meritSearchCell" forIndexPath:indexPath];
    } else if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"partnerSearchCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        MeritsTVC *push = [[UIStoryboard storyboardWithName:@"Merits" bundle:nil] instantiateInitialViewController];
        push.meritMode = MeritModeDiscover;
        push.earnedMerits = [User currentUser].earnedMerits;
        [self.navigationController pushViewController:push animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
    [[User currentUser] fetchIfNeededInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Merits"];
    [query whereKey:@"identifier" equalTo:@"clubw"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error) {
            clubWMeritObject = object;
        }
    }];
}

@end