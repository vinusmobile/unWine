//
//  settingsTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 6/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "settingsTableViewController.h"
#import "UITableViewController+Helper.h"
#import "ParseSubclasses.h"
#import "profileCell.h"
#import "RegistrationTVC.h"
#import "CastProfileVC.h"
#import "iRate.h"
#import "iRate+extra.h"

#define SECTION_MEMBERSHIP          2
#define SECTION_SUPPORT             0
#define SECTION_MORE_INFORMATION    1

@implementation settingsTableViewController

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
    
    [self basicAppeareanceSetup];
    
    [self addUnWineTitleView];
    
    
    self.tableView.estimatedRowHeight = 52.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[iRate sharedInstance] promptForRatingIfUserHasNotDeclinedCurrentVersion];

}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (BOOL)hidesBottomBarWhenPushed {
    return self != [self.navigationController.viewControllers objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Header View Stuff

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_MEMBERSHIP:
            return @"Membership";
        case SECTION_SUPPORT:
            return @"Support";
        case SECTION_MORE_INFORMATION:
            return @"More Information";
        default:
            return @"";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return ![[User currentUser] isAnonymous] ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    
    if (section == SECTION_MEMBERSHIP) {
        numberOfRows = ![[User currentUser] isAnonymous] ? 1 : 0;
    } else if (section == SECTION_SUPPORT) {
        numberOfRows = 2;
    } else if (section == SECTION_MORE_INFORMATION) {
        numberOfRows = 5;
    }
    
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *profileCellIdentifier          = @"profileCell";
    static NSString *editProfileCellIdentifier      = @"editProfileCell";
    static NSString *cancelAccountCellIdentifier    = @"cancelAccountCell";
    static NSString *contactCellIdentifier          = @"contactCell";
    static NSString *privacyCellIdentifier          = @"privacyCell";
    static NSString *termsCellIdentifier            = @"termsCell";
    //static NSString *changeCellIdentifier           = @"changeCell";
    static NSString *versionCellIdentifier          = @"versionCell";
    static NSString *logoutCellIdentifier           = @"logoutCell";
    
    NSString *identifier;
    
    switch (indexPath.section) {
        /*case 0:
            identifier = profileCellIdentifier;
            break;*/
            
        case SECTION_MEMBERSHIP:
            identifier = editProfileCellIdentifier;
            
            switch (indexPath.row) {
                /*case 0:
                    identifier = editProfileCellIdentifier;
                    break;*/
                case 0:
                    identifier = cancelAccountCellIdentifier;
                    break;
                    
                default:
                    break;
            }
            
            
            break;
        case SECTION_SUPPORT:
            identifier = contactCellIdentifier;
            break;
        case SECTION_MORE_INFORMATION:
            
            switch (indexPath.row) {
                case 0:
                    identifier = contactCellIdentifier;
                    break;
                case 1:
                    identifier = privacyCellIdentifier;
                    break;
                case 2:
                    identifier = termsCellIdentifier;
                    break;
                /*case 2:
                    identifier = changeCellIdentifier;
                    break;*/
                case 3:
                    identifier = versionCellIdentifier;
                    break;
                case 4:
                    identifier = logoutCellIdentifier;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == SECTION_MORE_INFORMATION && indexPath.row == 3) {
        NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Version %@", versionString];
    }
    
    if (indexPath.section == SECTION_MORE_INFORMATION && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Reset Tutorial"];
    }
    
    if(indexPath.section == SECTION_SUPPORT && indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"Rate unWine"];
    }
    
    /*if (indexPath.section == 0) {
        [((profileCell *)cell) setUpProfileImage];
        [((profileCell *)cell) setUpProfileName];
        
    }*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        /*case 0:{
            CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
            
            [profile setProfileUser:[User currentUser]];
            [self.navigationController pushViewController:profile animated:YES];
        }
            break;*/
        case SECTION_MEMBERSHIP:
            switch (indexPath.row) {
                /*case 0:
                    [self editProfile];
                    break;*/
                    
                default:
                    break;
            }
            break;
        case SECTION_SUPPORT:
            switch (indexPath.row) {
                case 0:
                    [(customTabBarController *)self.tabBarController showUserVoice];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[[iRate sharedInstance] ratingsURL]];
                    [User currentUser].ratedApp = true;
                    [[User currentUser] saveInBackground];
                    break;
                    
                default:
                    break;
            }
            break;
        case SECTION_MORE_INFORMATION:
            switch (indexPath.row) {
                case 0: {
                    [User unwitnessAllAlerts];
                    
                    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Your tutorial has been reset!"];
                    alert.centerButtonTitle = @"Keep unWineing";
                    [alert show];
                }
                    break;
                case 3:{
                    //push popup
                    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"Constants"];
                    [query whereKey:@"Type" equalTo:@"ChangeLog"];
                    [query whereKey:@"Value.Version" equalTo:version];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error && object) {
                            popupView *pv = [[popupView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                            
                            pv.titleLabel.text = object[@"Value"][@"Title"];
                            
                            UILabel *content = [[UILabel alloc] init];
                            content.text = object[@"Value"][@"Log"];
                            content.font = [UIFont fontWithName:@"TrebuchetMS" size:12.0f];
                            [pv.clv addSubview:content];
                            
                            [pv.clv update];
                            
                            [self.navigationController.view addSubview:pv];
                            [pv showAndOpen];
                        }
                    }];
                }
                    break;
                case 4:
                    [User logOutAndDismiss:self];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)editProfile {
    
    /*UIStoryboard *registrationStoryboard = [UIStoryboard storyboardWithName:@"MainNew" bundle:nil];
    RegistrationTVC *editController = [registrationStoryboard instantiateViewControllerWithIdentifier:@"registration"];
    
    editController.title = @"Edit Profile";
    editController.mode = EDIT_MODE;
    editController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:editController animated:YES];*/
    
}

@end
