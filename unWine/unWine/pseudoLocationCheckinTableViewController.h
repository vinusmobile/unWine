//
//  pseudoLocationCheckinTableViewController.h
//  unWine
//
//  Created by Fabio Gomez on 1/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "venueCell.h"
#import "customWineCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ParseSubclasses.h"

@protocol VenueViewControllerDelegate;

@interface pseudoLocationCheckinTableViewController : UITableViewController <UISearchBarDelegate,UITableViewDelegate, CLLocationManagerDelegate>{
    
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) CLLocation *lastLocation;

@property (nonatomic, weak) id<VenueViewControllerDelegate> delegate;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

// Protocol
@protocol VenueViewControllerDelegate <NSObject>

- (void)pseudoLocationCheckinTableViewController:(pseudoLocationCheckinTableViewController*)viewController
             sendVenue:(PFObject *)venue;

@end