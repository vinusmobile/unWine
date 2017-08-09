//
//  cancelAccountTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 7/7/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//


#import "cancelAccountCheckEmailTableViewController.h"
#import "emailCheckCell.h"
#import "InfoCell.h"
#import <Parse/Parse.h>
#import "ParseSubclasses.h"

@interface cancelAccountCheckEmailTableViewController ()

@end

@implementation cancelAccountCheckEmailTableViewController

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
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Delete My Account";
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationItem.title = @"Back";
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
    return 3;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 44.f;
    
    switch (indexPath.row) {
        case 0:
            height = 178.0f;
            break;

        default:
            break;
    }
    
    return height;
    
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *deleteDetailsCellIdentifier        = @"deleteDetailsCell";
    static NSString *emailCellIdentifier                = @"emailCell";
    static NSString *deleteAccountCellCellIdentifier    = @"deleteAccountCell";
    
    NSString *identifier;
    
    // Figure Out Identifier
    switch (indexPath.row) {
        case 0:
            identifier = deleteDetailsCellIdentifier;
            break;
        case 1:
            identifier = emailCellIdentifier;
            break;
        case 2:
            identifier = deleteAccountCellCellIdentifier;
            break;
            
        default:
            break;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.row != 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        ((InfoCell *)cell).infoLabel.numberOfLines = 0;
        ((InfoCell *)cell).infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSMutableString *string = [[NSMutableString alloc]initWithString:@""];
        
        [string appendString:@"\u2022 Permanently remove your unWine progress and wine history.\n\n"];
        [string appendString:@"\u2022 You will no longer have the most engaging fun wine app in the industry.\n\n"];
        [string appendString:@"\u2022 We will miss you and hope you come back soon.\n"];
        
        ((InfoCell *)cell).infoLabel.text = string;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    emailCheckCell *cell = (emailCheckCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    [cell.emailTextField resignFirstResponder];
    
    if (indexPath.row == 2) {
        
        // Check Email
        
        if ([cell.emailTextField.text isEqualToString:[User currentUser].email]) {
            [self performSegueWithIdentifier:@"toFeedback" sender:self];
        } else {
            [unWineAlertView showAlertViewWithTitle:@"Incorrect Email" message:@"Please enter the email you used to register your account."];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



// This is to scroll the the tableview to allow the comment box to be seen
- (void)keyboardWillShow:(NSNotification*)note {
    
    printf("\n\n");
    NSLog(@"keyboardWillShow\n\n");
    
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"Prepare For Segue");
}


@end
