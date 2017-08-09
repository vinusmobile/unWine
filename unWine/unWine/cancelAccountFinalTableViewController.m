//
//  cancelAccountFinalTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 7/7/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "cancelAccountFinalTableViewController.h"
#import "settingsTableViewController.h"
#import "ParseSubclasses.h"
#import "Analytics.h"

#define GOODBYE_QUITER_TAG 2

@interface cancelAccountFinalTableViewController () <unWineAlertViewDelegate> {
    MBProgressHUD *gActivityView;
}

@end

@implementation cancelAccountFinalTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 44.f;
    
    switch (indexPath.row) {
        case 0:
            height = 140.0f;
            break;
            
        default:
            break;
    }
    
    return height;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *proceedQuestionCellIdentifier      = @"proceedQuestionCell";
    static NSString *deleteAccountFinalCellIdentifier   = @"deleteAccountFinalCell";
    
    NSString *identifier;
    
    // Figure Out Identifier
    switch (indexPath.row) {
        case 0:
            identifier = proceedQuestionCellIdentifier;
            break;
        case 1:
            identifier = deleteAccountFinalCellIdentifier;
            break;
            
        default:
            break;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.row != 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.row != 1) {
        return;
    }
    
    SHOW_HUD;
    
    [[User deleteAndLogoutUser] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        HIDE_HUD;
        
        NSError *error = task.error;
        
        if(!error){
            NSLog(@"Account deleted successfully");
            
            [Analytics trackAccountDeletions];
            
            unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"We will miss you!"];
            alert.delegate = self;
            [alert shouldShowLogo:YES];
            alert.emptySpaceDismisses = NO;
            alert.title = @"Account Deleted";
            alert.tag = GOODBYE_QUITER_TAG;
            [alert show];
            
        } else{
            [unWineAlertView showAlertViewWithTitle:nil error:error];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return nil;
    }];
}

// HUD Code

- (void)setUpHUD{
    
    if (gActivityView != nil) {
        NSLog(@"setUpHUD - gActivityView is still on the screen");
        [gActivityView hide:YES];
    }
    
    gActivityView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:gActivityView];
    
    // Set determinate mode
    gActivityView.delegate = self;
    gActivityView.labelText = @"Please Wait";
    [gActivityView show:YES];
}

- (void)centerButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == GOODBYE_QUITER_TAG) {
        [[MainVC sharedInstance] dismissPresented:YES];
    }
}

@end
