//
//  userSearchPFQueryTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/28/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "userSearchPFQueryTableViewController.h"
#import "defaultPFCell.h"
#import "UIImageView+AFNetworking.h"
#import "ParseSubclasses.h"
#import "CastProfileVC.h"

@interface userSearchPFQueryTableViewController ()

@end

@implementation userSearchPFQueryTableViewController

@synthesize searchBar;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    searchBar.placeholder = @"Who are you looking for?";
    searchBar.barTintColor = [UIColor colorWithRed:189/255.0f green:19/255.0f blue:40/255.0f alpha:1.0f];
    [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    // Make the nav/tab bar solid instead of translucent
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.searchBar action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    self.searchBar.inputAccessoryView = toolbar;
    
    
    [self.searchBar setDelegate:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100.0;
    
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.

- (PFQuery *)queryForTable {
    PFQuery *query = [User query];
    
    BOOL searchNothing = [searchBar.text.lowercaseString isEqualToString:@""] ? YES : NO;
    [query whereKey:@"isAdmin" notEqualTo:@YES];
    [query whereKey:@"canonicalName" containsString: searchNothing ? @"******" : searchBar.text.lowercaseString];
    
    NSLog(@"searchBar.text = \"%@\"", searchBar.text);
    
    // If Pull To Refresh is enabled, query against the network by default.
    /*if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }*/
    
    [query orderByAscending:@"canonicalName"];
    
    return query;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    
    [self loadObjects];
}

 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
 // and the imageView being the imageKey in the object.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(User *)user {
    static NSString *CellIdentifier = @"friendCell";
    
    defaultPFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[defaultPFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [user setUserImageForImageView:cell.imageViewDefault];
    
    cell.nameTextLabel.text = [user getName];
    cell.nameTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    
    UIColor* imageBorderColor = [UIColor colorWithRed:43.0/255 green:90.0/255 blue:131.0/255 alpha:0.4];
    cell.imageViewDefault.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageViewDefault.clipsToBounds = YES;
    cell.imageViewDefault.layer.cornerRadius = 29.71f;
    cell.imageViewDefault.layer.borderWidth = .5f/*2.29f*/;
    cell.imageViewDefault.layer.borderColor = imageBorderColor.CGColor;
    
    return cell;
}



 // Override if you need to change the ordering of objects in the table.
- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.row >= self.objects.count) {
        return;
    }
    
    User *user = self.objects[indexPath.row];
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    [profile setProfileUser:user];
    [self.navigationController pushViewController:profile animated:YES];
    /*NSLog(@"user = %@", user);
    
    
    UIStoryboard *profile = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    newProfileTabViewController *friendProfile = [profile instantiateViewControllerWithIdentifier:@"profileTabViewController"];
    
    friendProfile.gUser = user;
    
    [self.navigationController pushViewController: friendProfile animated:YES];*/
    
    
}

@end
