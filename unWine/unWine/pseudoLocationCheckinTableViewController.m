//
//  pseudoLocationCheckinTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 1/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "pseudoLocationCheckinTableViewController.h"
#import "UITableViewController+Helper.h"


@interface pseudoLocationCheckinTableViewController () {
    
}

@end

@implementation pseudoLocationCheckinTableViewController
@synthesize locationManager = _locationManager, searchBar = _searchBar, groups = _groups, HUD = _HUD, lastLocation = _lastLocation;

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      WIDTH(self.tableView),
                                      HEIGHT(self.navigationController.view) - 50);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	_HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    // Check for iOS8
    
    if (IOS_8_OR_MAJOR)
        [_locationManager requestWhenInUseAuthorization];
    
    [_locationManager startUpdatingLocation];
    
    _lastLocation = _locationManager.location;
    
    float latitude = _lastLocation.coordinate.latitude;
    float longitude = _lastLocation.coordinate.longitude;
    
    [self fetchVenues:[NSString stringWithFormat:@"%f,%f",latitude,longitude]];
    
    [_locationManager stopUpdatingLocation];
    
    _searchBar.placeholder = @"Create a location";
    _searchBar.barTintColor = UNWINE_RED;
    [_searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.searchBar action:@selector(resignFirstResponder)];
    barButton.tintColor = UNWINE_RED;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    self.searchBar.inputAccessoryView = toolbar;
    
    [self.searchBar setDelegate:self];
    
    [self basicAppeareanceSetup];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        //location denied, handle accordingly
    } else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
        
        _lastLocation = _locationManager.location;
        float latitude = _lastLocation.coordinate.latitude;
        float longitude = _lastLocation.coordinate.longitude;
        
        [self fetchVenues:[NSString stringWithFormat:@"%f,%f",latitude,longitude]];
        
        [_locationManager stopUpdatingLocation];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchVenues:(NSString *)location {
    
    [_HUD show:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%@", FOURSQUARE_CLIENT_ID, FOURSQUARE_CLIENT_SECRET, location]];
    
    NSLog(@"%@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //AFNetworking asynchronous url request
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LOGGER(@"Finished fetching");
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSArray *results = [[responseObject valueForKey:@"response"] valueForKey:@"venues"];
        
        for(NSDictionary *groupDic in results){
            Venue *venue = [Venue object];
            venue.name = [groupDic valueForKey:@"name"];
            
            if ([[groupDic valueForKey:@"location"] valueForKey:@"address"])
                venue.address = [[groupDic valueForKey:@"location"] valueForKey:@"address"];
            else
                venue.address = @"";
            
            if ([[groupDic valueForKey:@"location"] valueForKey:@"city"])
                venue.city = [[groupDic valueForKey:@"location"] valueForKey:@"city"];
            else
                venue.city = @"";
            
            if ([[groupDic valueForKey:@"location"] valueForKey:@"state"])
                venue.state = [[groupDic valueForKey:@"location"] valueForKey:@"state"];
            else
                venue.state = @"";
            
            if ([[groupDic valueForKey:@"categories"] valueForKey:@"name"])
                venue.category = [[[groupDic valueForKey:@"categories"] valueForKey:@"name"] componentsJoinedByString:@""];
            else
                venue.category = @"";
            
            venue.icon = [NSString stringWithFormat:@"%@bg_64%@", [[[[groupDic valueForKey:@"categories"] valueForKey:@"icon"] valueForKey:@"prefix"] componentsJoinedByString:@""], [[[[groupDic valueForKey:@"categories"] valueForKey:@"icon"] valueForKey:@"suffix"] componentsJoinedByString:@""]];
            
            venue.latitude = @([[[groupDic valueForKey:@"location"] valueForKey:@"lat"] floatValue]);
            venue.longitude = @([[[groupDic valueForKey:@"location"] valueForKey:@"lng"] floatValue]);
            
            [groups addObject:venue];
        }
        
        self.groups = groups;
        
        [_HUD hide:YES];
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
        
        [_HUD hide:YES];
        
    }];
    
    [operation start];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tableView reloadData];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.delegate =self;
    [self.view endEditing:YES];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchBar.text length] > 0) {
        return 1;
    } else {
        return self.groups.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchBar.text length] > 0) {
        
        static NSString *CellIdentifier = @"custom";
        customWineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.venueName.text = [NSString stringWithFormat:@"Create %@", self.searchBar.text];
        cell.venueName.tag = 1;
        
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"venueCell";
        venueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Venue *group = self.groups[indexPath.row];
        
        cell.venueName.text = group[@"name"];
        cell.venueName.tag = 1;
        cell.venueLocation.tag = 2;
    
        if ([group.address length] == 0) {
            cell.venueLocation.text = group.category;
        }else{
            cell.venueLocation.text = [NSString stringWithFormat:@"%@, %@ %@", group.address, group.city, group.state];
        }
        
        [cell.venueIcon setImageWithURL:[NSURL URLWithString:group.icon]
                       placeholderImage:[UIImage imageNamed:@"venueDefaultIcon"]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_searchBar.text length] > 0) {
        
        Venue *venue = [Venue object];
        venue.name = _searchBar.text;
        venue.location = @"Custom";
        venue.latitude = @(_lastLocation.coordinate.latitude);
        venue.longitude = @(_lastLocation.coordinate.longitude);
        
        if ([self.delegate respondsToSelector:@selector(pseudoLocationCheckinTableViewController:sendVenue:)]) {
            [self.delegate pseudoLocationCheckinTableViewController:self sendVenue:venue];
        }
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //UILabel *label = (UILabel*)[cell viewWithTag:1];
        UILabel *location = (UILabel*)[cell viewWithTag:2];
        
        Venue *venue = self.groups[indexPath.row];
        venue.name = [venue.name capitalizedString];
        venue.location = location.text;
        
        /*Venue *venue = [Venue object];
        venue.name = label.text;
        venue.latitude = _lastLocation.coordinate.latitude;
        venue.longitude = _lastLocation.coordinate.longitude;*/
        
        if ([self.delegate respondsToSelector:@selector(pseudoLocationCheckinTableViewController:sendVenue:)]) {
            [self.delegate pseudoLocationCheckinTableViewController:self sendVenue:venue];
        }
    }
    
}


@end
