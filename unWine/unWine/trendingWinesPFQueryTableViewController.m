//
//  trendingWinesPFQueryTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/30/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "trendingWinesPFQueryTableViewController.h"
#import "trendingWineCell.h"
#import "UIImageView+AFNetworking.h"
//#import "wineDetailViewController.h"
#import "CastDetailTVC.h"
#import "ParseSubclasses.h"

@interface trendingWinesPFQueryTableViewController ()

@end

@implementation trendingWinesPFQueryTableViewController
{
    NSInteger tincrement;
    
}
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        //increment for table
        tincrement = 0;
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

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make the nav/tab bar solid instead of translucent
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    CGFloat height = 100.0;
    
    if (indexPath.row == self.objects.count) {
        height = 0.;
    }
    
    return height;
    
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.

- (PFQuery *)queryForTable {
    PFQuery *query = [unWine query];
    
    [query includeKey:@"partner"];
    [query orderByDescending:@"trending"];
    
    self.objectsPerPage = 10;
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    [self loadObjects];
}

//create the image for the top ranking icons

- (void) setRankingIconViewForCell : (trendingWineCell *)cell ForRowAtIndexPath: (NSIndexPath *) indexPath{
    cell.RankingIconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%li.png", indexPath.row +1]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(unWine *)object{
    static NSString *CellIdentifier = @"friendCell";
    //old counter for trending wines
    //NSInteger indexCell = indexPath.row + 1;
    trendingWineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[trendingWineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.nameTextLabel.text = [object getWineName];
    cell.nameTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    
    
    // call my ranking icon picture labeled 1-10@2x.png change later for higher resolution
    [self setRankingIconViewForCell:cell ForRowAtIndexPath:indexPath];
    
    [self setImageViewForCell:cell WithObject:object];
    
    return cell;
}

- (void)setImageViewForCell:(trendingWineCell *)cell WithObject:(unWine *)object{
    if (object.thumbnail) {
        cell.imageViewDefault = [object getThumbnailImageView];
        NSLog(@"%s - using thumbnail", FUNCTION_NAME);
    } else if (ISVALID(object.imageSquare)) {
        [cell.imageViewDefault setImageWithURL: [NSURL URLWithString:object.imageSquare] placeholderImage:WINE_PLACEHOLDER];
        NSLog(@"%s - using imageSquare", FUNCTION_NAME);
    } else if (object.image) {
        cell.imageViewDefault = [object getLargeImageView];
        NSLog(@"%s - using image", FUNCTION_NAME);
    } else if (ISVALID(object.imageLarge)) {
        [cell.imageViewDefault setImageWithURL: [NSURL URLWithString:object.imageLarge] placeholderImage:WINE_PLACEHOLDER];
        NSLog(@"%s - using imageLarge", FUNCTION_NAME);
    }
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
    
    PFObject *wine = self.objects[indexPath.row];
    
    NSLog(@"%s - wine = %@", FUNCTION_NAME, wine.description);
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
        CastDetailTVC *detail = [checkIn instantiateViewControllerWithIdentifier:@"detail"];
        
        detail.wine = (unWine *)wine;
        detail.lockAllWines = [config[@"LOCK_ALL_WINES"] boolValue];;
        detail.isNew = NO;
        detail.cameFrom = CastCheckinSourceSomewhere;
        
        [self.navigationController pushViewController:detail animated:YES];
    }];
    
    /*
    UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"checkIn" bundle:nil];
    wineDetailViewController *checkInInitialController = [checkIn instantiateViewControllerWithIdentifier:@"wineDetail"];
    
    checkInInitialController.title = @"Check In";
    checkInInitialController.tabBarItem.image = [UIImage imageNamed:@"checkin.png"];
    checkInInitialController.wineObjectIdFromNewsFeed = object.objectId;
    
    [self.navigationController pushViewController: checkInInitialController animated:YES];
     */
}


@end
