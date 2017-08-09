//
//  WineWorldVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/25/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineWorldVC.h"
#import "WineryContainerVC.h"
#import "VineCastTVC.h"
#import <AFNetworking/AFNetworking.h>
#import <NSDate_Time_Ago/NSDate+NVTimeAgo.h>

@import MapKit;
@import CoreLocation;

@import GooglePlaces;
@import GooglePlacePicker;

typedef enum WWPointType {
    WWPointTypeWineVenue,
    WWPointTypeWinery,
    WWPointTypeCheckinVenue
} WWPointType;

@interface WWPointAnnotation : MKPointAnnotation

@property (nonatomic) WWPointType type;
@property (nonatomic) Venue *venue;
@property (nonatomic) Winery *winery;

@end

typedef NS_OPTIONS(NSUInteger, WineWorldCategory) {
    WineWorldCategoryWineBar            = 1 << 0,
    WineWorldCategoryWinery             = 1 << 1,
    WineWorldCategoryWineSomething      = 1 << 2,
    WineWorldCategoryVineyard           = 1 << 3
};

@interface WineWorldVC () <MKMapViewDelegate, CLLocationManagerDelegate, unWineActionSheetDelegate>

@property (nonatomic) CLLocation *lastLocation;

@end

@implementation WineWorldVC {
    MKMapView *_mapView;
    CLLocationManager *_locationManager;
    NSMutableArray<Venue *> *_groups;
    NSArray<Venue *> *_checkins;
    NSArray<Winery *> *_wineries;
    NSArray<Venue *> *_googleVenues;
    MBProgressHUD *HUD;
    UIView *barricade;
    UIView *mapLegend;
    BOOL firstLoad;
    GMSPlacesClient *_placesClient;
    GMSPlacePicker *_placePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
    [self.view addSubview:_mapView];
}

- (MBProgressHUD *)getHUD {
    if(!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        HUD.removeFromSuperViewOnHide = YES;
    }
    
    return HUD;
}

- (void)showHUD {
    if([self getHUD].alpha == 0) {
        [self.view addSubview:[self getHUD]];
        [[self getHUD] show:YES];
    }
}

- (void)hideHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self getHUD] hide:YES];
    });
}

- (CLLocationManager *)getLocationManager {
    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [_locationManager requestWhenInUseAuthorization];
    }
    
    return _locationManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Wine World";
    [self updateCurrentLocation];
    
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        if(!barricade) {
            barricade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view))];
            barricade.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
            barricade.userInteractionEnabled = YES;
            
            NSInteger buffer = 15;
            UITextView *barricadeLabel = [[UITextView alloc] initWithFrame:CGRectMake(buffer, 60, WIDTH(barricade) - buffer * 2, 180)];
            [barricadeLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
            [barricadeLabel setTextAlignment:NSTextAlignmentCenter];
            [barricadeLabel setTextColor:[UIColor whiteColor]];
            [barricadeLabel setText:@"Looks like you have location services for unWine disabled. For the best possible experience, we recommend you turn location services on, or you may miss out on some cool features(Like this one)!"];
            barricadeLabel.backgroundColor = [UIColor clearColor];
            barricadeLabel.editable = NO;
            barricadeLabel.scrollEnabled = NO;
            barricadeLabel.userInteractionEnabled = NO;
            [barricade addSubview:barricadeLabel];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSettings)];
            [barricade addGestureRecognizer:tap];
            
            barricade.layer.zPosition = 1001;
        }
        
        if(mapLegend)
            [mapLegend removeFromSuperview];
        
        [self.view addSubview:barricade];
    } else {
        if(!mapLegend) {
            NSInteger height = HEIGHT(self.view) - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
            NSInteger legendWidth = 140;
            NSInteger buffer = 2;
            NSInteger keySize = 28;
            NSInteger legendHeight = keySize * 3 + (buffer * 2) * 4;
            
            mapLegend = [[UIView alloc] initWithFrame:CGRectMake(0, height - legendHeight, legendWidth, legendHeight)];
            mapLegend.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
            mapLegend.userInteractionEnabled = YES;
            
            UIView *purpleKey = [[UIView alloc] initWithFrame:CGRectMake(buffer, buffer * 2, keySize, keySize)];
            [purpleKey setBackgroundColor:[MKPinAnnotationView purplePinColor]];
            [mapLegend addSubview:purpleKey];
            
            UILabel *purpleLabel = [[UILabel alloc] initWithFrame:CGRectMake(X2(purpleKey) + WIDTH(purpleKey) + buffer * 2, Y2(purpleKey), legendWidth - WIDTH(purpleKey) - buffer * 2, HEIGHT(purpleKey))];
            [purpleLabel setText:@"Winery"];
            [purpleLabel setFont:[UIFont fontWithName:@"OpenSans" size:15]];
            [purpleLabel setTextColor:[UIColor whiteColor]];
            [mapLegend addSubview:purpleLabel];
            
            UIView *redKey = [[UIView alloc] initWithFrame:CGRectMake(buffer, buffer * 2 + Y2(purpleKey) + HEIGHT(purpleKey), keySize, keySize)];
            [redKey setBackgroundColor:[MKPinAnnotationView redPinColor]];
            [mapLegend addSubview:redKey];
            
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(X2(redKey) + WIDTH(redKey) + buffer * 2, Y2(redKey), legendWidth - WIDTH(redKey) - buffer * 2, HEIGHT(redKey))];
            [redLabel setText:@"Wine Venues"];
            [redLabel setFont:[UIFont fontWithName:@"OpenSans" size:15]];
            [redLabel setTextColor:[UIColor whiteColor]];
            [mapLegend addSubview:redLabel];
            
            UIView *greenKey = [[UIView alloc] initWithFrame:CGRectMake(buffer, buffer * 2 + Y2(redKey) + HEIGHT(redKey), keySize, keySize)];
            [greenKey setBackgroundColor:[MKPinAnnotationView greenPinColor]];
            [mapLegend addSubview:greenKey];
            
            UILabel *greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(X2(greenKey) + WIDTH(greenKey) + buffer * 2, Y2(greenKey), legendWidth - WIDTH(greenKey) - buffer * 2, HEIGHT(greenKey))];
            [greenLabel setText:@"Checkins"];
            [greenLabel setFont:[UIFont fontWithName:@"OpenSans" size:15]];
            [greenLabel setTextColor:[UIColor whiteColor]];
            [mapLegend addSubview:greenLabel];
        }
        
        if(barricade)
            [barricade removeFromSuperview];
        
        [self.view addSubview:mapLegend];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [barricade removeFromSuperview];
        
        [self updateCurrentLocation];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didChangeAuthorizationStatus)])
            [self.delegate didChangeAuthorizationStatus];
    }
}

- (void)toSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Back";
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (UIViewController *)actionSheetPresentationViewController {
    return self;
}

- (NSArray<WWPointAnnotation *> *)getWWPoints {
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for(id<MKAnnotation> annot in _mapView.annotations) {
        if([annot isKindOfClass:[WWPointAnnotation class]])
           [points addObject:annot];
    }
    
    return points;
}

- (BFTask *)queryGoogleAPI {
    NSString *location = [NSString stringWithFormat:@"%f,%f", _lastLocation.coordinate.latitude, _lastLocation.coordinate.longitude];
    
    return [PFCloud callFunctionInBackground:@"googlePlaces" withParameters:@{@"location": location}];
}

- (BFTask *)updateCurrentLocation {
    [_mapView removeAnnotations:_mapView.annotations];
    [[self getLocationManager] startUpdatingLocation];
    
    _lastLocation = [self getLocationManager].location;
    
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_lastLocation.coordinate, 12000, 12000);
    //[_mapView setRegion:region animated:YES]; //[_mapView regionThatFits:region]
    
    PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLocation:self.lastLocation];
    
    User *user = [User currentUser];
    NSArray<BFTask *> *tasks = @[[user getAssociatedVenues], [self fetch:_lastLocation], [Winery getWineriesNear:geopoint], [self queryGoogleAPI]];
    [self showHUD];
    return [[[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        LOGGER(task);
        [self hideHUD];
        BFTask<NSArray<Venue *> *> *venueTask = [tasks objectAtIndex:0];
        BFTask *fetchTask = [tasks objectAtIndex:1];
        BFTask *wineryTask = [tasks objectAtIndex:2];
        BFTask *googleTask = [tasks objectAtIndex:3];
        
        if(venueTask.result) {
            _checkins = venueTask.result;
            
            NSLog(@"checkin venues: %li", (unsigned long)[_checkins count]);
            for(Venue *venue in _checkins) {
                if([venue.latitude floatValue] == 0.f && [venue.longitude floatValue] == 0.f)
                    continue;
                WWPointAnnotation *point = [[WWPointAnnotation alloc] init];
                point.coordinate = CLLocationCoordinate2DMake([venue.latitude floatValue], [venue.longitude floatValue]);
                point.title = venue.name;
                point.subtitle = [NSString stringWithFormat:@"You checked in here %@", [venue.createdAt formattedAsTimeAgo]];
                point.type = WWPointTypeCheckinVenue;
                point.venue = venue;
                
                [_mapView addAnnotation:point];
            }
        }
        
        NSMutableArray<Venue *> *exemptVenues = [NSMutableArray array];
        if(fetchTask.result)
            for(Venue *venue in fetchTask.result)
                if([venue isWinery])
                    [exemptVenues addObject:venue];
        
        if(wineryTask.result) {
            _wineries = wineryTask.result;
            
            NSLog(@"known nearby wineries: %li", (unsigned long)[_wineries count]);
            for(Winery *winery in _wineries) {
                BOOL shouldAdd = YES;
                for(Venue *venue in exemptVenues)
                    if([winery isLikelyVenue:venue]) {
                        //NSLog(@"winery - %@ is likely: venue - %@", winery.name, venue.name);
                        shouldAdd = NO;
                    }
                
                if(shouldAdd) {
                    WWPointAnnotation *point = [[WWPointAnnotation alloc] init];
                    point.coordinate = CLLocationCoordinate2DMake(winery.location.latitude, winery.location.longitude);
                    point.title = [winery.name capitalizedString];
                    point.subtitle = @"Winery";
                    point.type = WWPointTypeWinery;
                    point.venue = [winery getAsVenue];
                    point.winery = winery;
                    
                    [_mapView addAnnotation:point];
                    
                    [exemptVenues addObject:point.venue];
                }
            }
        }
        
        if(googleTask.result) {
            NSMutableArray<Venue *> *convert = [[NSMutableArray alloc] init];
            for(NSDictionary *data in googleTask.result)
                [convert addObject:[Venue venueFromGoogle:data]];
            _googleVenues = convert;
            
            NSLog(@"nearby google wineries: %li", (unsigned long)[_googleVenues count]);
            for(Venue *venue in _googleVenues) {
                BOOL shouldAdd = YES;
                for(Venue *exempt in exemptVenues)
                    if([venue isLikelyVenue:exempt]) {
                        //NSLog(@"winery - %@ is likely: venue - %@", winery.name, venue.name);
                        shouldAdd = NO;
                    }
                
                if(shouldAdd) {
                    WWPointAnnotation *point = [[WWPointAnnotation alloc] init];
                    point.coordinate = CLLocationCoordinate2DMake([venue.latitude doubleValue], [venue.longitude doubleValue]);
                    point.title = [venue.name capitalizedString];
                    point.subtitle = venue.category;
                    if([venue isWinery]) {
                        point.type = WWPointTypeWinery;
                        point.venue = venue;
                    } else {
                        point.type = WWPointTypeWineVenue;
                        point.venue = venue;
                    }
                    
                    [_mapView addAnnotation:point];
                }
            }
        }
        
        [[self getLocationManager] stopUpdatingLocation];
        
        return task;
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        //if(!_lastLocation || (_lastLocation.coordinate.latitude == 0 && _lastLocation.coordinate.longitude == 0))
        if([_mapView.annotations count] > 0 && !firstLoad) {
            [_mapView showAnnotations:_mapView.annotations animated:YES];
            firstLoad = YES;
        }
        
        return nil;
    }];
}

#pragma Map Delegate Stuff

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if([annotation isKindOfClass:[WWPointAnnotation class]]) {
        WWPointAnnotation *point = (WWPointAnnotation *)annotation;
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MKPinAnnotationView"];
        
        //NSLog(@"subtitle - %@", [point.subtitle lowercaseString]);
        UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosure setTintColor:UNWINE_RED];
        annotationView.rightCalloutAccessoryView = disclosure;
        if(point.type == WWPointTypeWinery) {
            annotationView.pinColor = MKPinAnnotationColorPurple;
        } else if(point.type == WWPointTypeWineVenue) {
            annotationView.pinColor = MKPinAnnotationColorRed;
        } else if(point.type == WWPointTypeCheckinVenue) {
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        
        annotationView.userInteractionEnabled = YES;
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.annotation = point;
       
        return annotationView;
    }
           
    return nil;
}

static NSString *actionViewWinery = @"View Winery";
static NSString *actionOpenMaps = @"Open in Maps";
static WWPointAnnotation *actionPoint = nil;

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if([view.annotation isKindOfClass:[WWPointAnnotation class]]) {
        WWPointAnnotation *point = (WWPointAnnotation *)view.annotation;
        if(point.type == WWPointTypeWinery || [point.venue isWinery]) {
            actionPoint = point;
            
            unWineActionSheet *actionSheet = [[unWineActionSheet alloc] initWithTitle:point.title delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@[actionViewWinery, actionOpenMaps]];
            [actionSheet showFromTabBar:self.navigationController.view];
        } else if(point.type == WWPointTypeWineVenue) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_MAPS_FOR_WINE_VENUE_FROM_WINE_WORLD);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[point coordinate] addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:point.title];
            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
            [mapItem openInMapsWithLaunchOptions:options];
        } else if(point.type == WWPointTypeCheckinVenue) {
            [self showHUD];
            ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_MAPS_FOR_CHECKIN_VENUE_FROM_WINE_WORLD);
            PFQuery *query = [NewsFeed query];
            [query whereKey:@"venue" equalTo:point.venue];
            [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
                if(task.error)
                    LOGGER(task.error);
                
                [self hideHUD];
                if(task.result && [task.result count] > 0) {
                    VineCastTVC *feed = [[UIStoryboard storyboardWithName:@"VineCast" bundle:nil] instantiateViewControllerWithIdentifier:@"feed"];
                    [feed setVineCastSingleObject:[task.result firstObject]];
                    
                    [self.navigationController pushViewController:feed animated:YES];
                } else {
                    [unWineAlertView showAlertViewWithTitle:@"Oh no" message:@"We couldn't locate the checkin associated with this venue."];
                }
                
                return nil;
            }];
        }
    }
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(!actionPoint)
        return;
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionViewWinery]) {
        [self showHUD];
        
        BFTask *task = actionPoint.winery && [actionPoint.winery isDataAvailable] ? [BFTask taskWithResult:actionPoint.winery] : [Winery getNearestMatchCreateIfNecessary:actionPoint.venue];
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_WINERY_FROM_WINE_WORLD);
        [task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            if(task.error)
                LOGGER(task.error);
            
            [self hideHUD];
            if(task.result) {
                WineryContainerVC *container = [[WineryContainerVC alloc] init];
                container.winery = task.result;
                actionPoint.winery = task.result;
                [self.navigationController pushViewController:container animated:YES];
            }
            
            return nil;
        }];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionOpenMaps]) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_MAPS_FOR_WINERY_FROM_WINE_WORLD);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[actionPoint coordinate] addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:actionPoint.title];
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [mapItem openInMapsWithLaunchOptions:options];
    }
}

/*- (Venue *)getVenueFromWWPoint:(WWPointAnnotation *)annotation {
    if(_groups && [_groups count] > 0) {
        for(Venue *venue in _groups) {
            if([[venue.name lowercaseString] isEqualToString:[annotation.title lowercaseString]] &&
               [[venue.category lowercaseString] isEqualToString:[annotation.subtitle lowercaseString]])
                return venue;
        }
    }
    
    Venue *newVenue = [Venue object];
    newVenue.name = [annotation.title lowercaseString];
    newVenue.category = [annotation.subtitle lowercaseString];
    newVenue.latitude = @(annotation.coordinate.latitude);
    newVenue.longitude = @(annotation.coordinate.longitude);
    return newVenue;
}*/

#pragma Four Square

- (BFTask *)fetch:(CLLocation *)location {
    [self showHUD];
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    if(!location || (location.coordinate.latitude == 0.f && location.coordinate.longitude == 0.f)) {
       [source setResult:nil];
        
        return source.task;
    }
    
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20160225&ll=%@&limit=30&radius=25000&intent=browse&categoryId=4bf58dd8d48988d14b941735,4bf58dd8d48988d123941735,4bf58dd8d48988d119951735,4bf58dd8d48988d1de941735", FOURSQUARE_CLIENT_ID, FOURSQUARE_CLIENT_SECRET, [NSString stringWithFormat:@"%f,%f", latitude, longitude]]];
    //NSLog(@"%@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        LOGGER(@"Finished fetching");
        NSMutableArray<Venue *> *groups = [[NSMutableArray alloc] init];
        //NSLog(@"response - %@", responseObject);
        NSArray *results = [[responseObject valueForKey:@"response"] valueForKey:@"venues"];
        
        for(NSDictionary *groupDic in results) {
            Venue *venue = [Venue object];
            venue.name = [groupDic valueForKey:@"name"];
            //NSLog(@"Venue name - %@", venue.name);
            
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
            
            if ([[groupDic valueForKey:@"categories"] valueForKey:@"name"]) {
                venue.category = [[[groupDic valueForKey:@"categories"] valueForKey:@"name"] componentsJoinedByString:@""];
                //NSLog(@"Venue category - %@", venue.category);
                //if([[[groupDic valueForKey:@"categories"] valueForKey:@"id"] isEqualToString:@"4bf58dd8d48988d1f8941735"])
                    //continue;
            } else
                venue.category = @"";
            
            venue.icon = [NSString stringWithFormat:@"%@bg_64%@", [[[[groupDic valueForKey:@"categories"] valueForKey:@"icon"] valueForKey:@"prefix"] componentsJoinedByString:@""], [[[[groupDic valueForKey:@"categories"] valueForKey:@"icon"] valueForKey:@"suffix"] componentsJoinedByString:@""]];
            
            venue.latitude = @([[[groupDic valueForKey:@"location"] valueForKey:@"lat"] floatValue]);
            venue.longitude = @([[[groupDic valueForKey:@"location"] valueForKey:@"lng"] floatValue]);
            
            [groups addObject:venue];
        }
        
        _groups = groups;
        NSLog(@"venues fetched: %li", (unsigned long)[groups count]);
        for(Venue *venue in groups) {
            WWPointAnnotation *point = [[WWPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([venue.latitude floatValue], [venue.longitude floatValue]);
            point.title = venue.name;
            point.subtitle = venue.category;
            if([[venue.category lowercaseString] isEqualToString:@"winery"])
                point.type = WWPointTypeWinery;
            else
                point.type = WWPointTypeWineVenue;
            point.venue = venue;
            
            [_mapView addAnnotation:point];
        }
        
        [self hideHUD];
        [source setResult:groups];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
        [self hideHUD];
        [source setError:error];
    }];
    
    [operation start];
    
    return source.task;
}

static WineWorldVC *world = nil;

+ (BFTask *)fetchNearbyWineries:(id<WineWorldDelegate>)delegate {
    if(!world)
        world = [[WineWorldVC alloc] init];
    world.delegate = delegate;
    
    return [[world updateCurrentLocation] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if(task.error)
            LOGGER(task.error);
        
        NSMutableOrderedSet<Winery *> *wineries = [[NSMutableOrderedSet alloc] init];
        NSMutableArray<BFTask *> *tasks = [[NSMutableArray alloc] init];
        for(WWPointAnnotation *annot in [world getWWPoints])
            if(annot.type == WWPointTypeWinery) {
                if(annot.winery)
                    [wineries addObject:annot.winery];
                else
                    [tasks addObject:[Winery getNearestMatchCreateIfNecessary:annot.venue]];
            }
        
        if([tasks count] > 0)
            return [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                for(BFTask *task in tasks) {
                    if(task.result)
                        [wineries addObject:task.result];
                    
                    if(task.error)
                        LOGGER(task.error);
                }
                
                [wineries sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
                    return [obj1[@"name"] localizedCaseInsensitiveCompare:obj2[@"name"]];
                }];
                
                return [BFTask taskWithResult:[wineries array]];
            }];
        else {
            [wineries sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return [obj1[@"name"] localizedCaseInsensitiveCompare:obj2[@"name"]];
            }];
            
            return [BFTask taskWithResult:[wineries array]];
        }
        
        /*BFTask *fetchTask = [task.result objectAtIndex:1];
        BFTask *wineryTask = [task.result objectAtIndex:2];
        
        if(world.lastLocation && fetchTask.result) {
            NSMutableArray<BFTask *> *tasks = [[NSMutableArray alloc] init];
            for(Venue *venue in fetchTask.result) {
                if([[venue.category lowercaseString] containsString:@"winery"]) {
                    [tasks addObject:[Winery getNearestMatchCreateIfNecessary:venue]];
                }
            }
            
            return [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                NSMutableArray *wineries = [[NSMutableArray alloc] init];
                for(BFTask *task in tasks) {
                    if(task.result)
                        [wineries addObject:task.result];
                    
                    if(task.error)
                        LOGGER(task.error);
                }
                
                return [BFTask taskWithResult:wineries];
            }];
        }
        
        return nil;*/
    }];
}

@end

@implementation WWPointAnnotation

@end
