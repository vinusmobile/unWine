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
#import "CIHeaderCell.h"

@interface CastOccasionTVC : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *occasions;
@property (strong, nonatomic) NSArray *recentOccasions;

@property (nonatomic, weak) CIHeaderCell *delegate;

@end
