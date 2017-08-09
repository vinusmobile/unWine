//
//  meritsPFQueryTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/25/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsPFQueryTableViewController.h"
#import "meritsPFCell.h"
#import "ParseSubclasses.h"

@interface meritsPFQueryTableViewController ()

@end

@implementation meritsPFQueryTableViewController

@synthesize gUser;

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
        self.objectsPerPage = 1000;
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
    
    printf("\n\n\n");
    NSLog(@"*****  meritsPFQueryTableViewController *****");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[User currentUser] fetchInBackgroundWithTarget:self selector:@selector(loadObjects)];
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
    
    PFQuery *meritQuery = [PFQuery queryWithClassName:@"Merits"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        meritQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    //meritQuery.limit = 1000;
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        meritQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    //[meritQuery orderByDescending:@"name"];
    
    return meritQuery;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self getNumberOfSections] + 1;
}


- (NSInteger)getNumberOfSections{
    
    NSInteger numberOfSections = 0;
    
    NSMutableArray *uniqueFieldsArray = [[NSMutableArray alloc] init];
    
    for (PFObject *merit in self.objects) {
        
        if (uniqueFieldsArray.count == 0) {
            [uniqueFieldsArray addObject: [merit[@"type"] capitalizedString]];
            continue;
        }
        
        if (![uniqueFieldsArray containsObject:[merit[@"type"] capitalizedString]]) {
            [uniqueFieldsArray addObject: [merit[@"type"] capitalizedString]];
        }
        
        NSLog(@"Merit Type = %@", merit[@"type"]);
    }
    
    numberOfSections = uniqueFieldsArray.count;
    
    NSLog(@"getNumberOfSections - unique fields count = %li", (long)numberOfSections);
    NSLog(@"getNumberOfSections - uniqueFieldsArray");
    NSLog(@"%@", uniqueFieldsArray);
    
    return numberOfSections;
}

 
// Set the height for each the cells (i.e. the first cell should be smaller than the rest of the cells)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section!=0) {
        
        return 138.0;
        
    }
    
    else {
        
        return 50.0;
        
    }
    
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)wine {
    static NSString *CellIdentifier = @"friendCell";
    
    meritsPFCell *cell = (meritsPFCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[meritsPFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //[cell.imageViewDefault setImageWithURL: [NSURL URLWithString:wine[@"imageSquare"]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    //cell.nameTextLabel.text = wine[@"name"];
    //cell.nameTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PFObject *wine = self.objects[indexPath.row];
    
    NSLog(@"wine = %@", wine);
    
   
}


@end
