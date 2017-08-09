//
//  Venue.m
//  unWine
//
//  Created by Bryce Boesen on 10/8/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Venue.h"

@implementation Venue
@dynamic name, location, user, latitude, longitude, address, city, state, icon, category;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Venue";
}

+ (PFQuery *)query {
    PFQuery *query = [super query];
    [query includeKey:@"user"];
    return query;
}

- (BOOL)isCustom {
    return [self.location isEqualToString:@"Custom"];
}

- (PFGeoPoint *)getGeoPoint {
    return [PFGeoPoint geoPointWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
}

- (BOOL)isWinery {
    return [[self.category lowercaseString] isEqualToString:@"winery"];
}

- (BOOL)isLikelyVenue:(Venue *)venue {
    if([[venue.name lowercaseString] isEqualToString:[self.name lowercaseString]])
        return YES;
    else
        return [[self getGeoPoint] distanceInKilometersTo:[venue getGeoPoint]] < .1f;
    
    return NO;
}

+ (Venue *)venueFromGoogle:(NSDictionary *)data {
    Venue *venue = [Venue new];
    venue.name = data[@"name"];
    
    if([[data allKeys] containsObject:@"geometry"]) {
        venue.latitude = @([data[@"geometry"][@"location"][@"lat"] doubleValue]);
        venue.longitude = @([data[@"geometry"][@"location"][@"lng"] doubleValue]);
    }
    
    if([[data allKeys] containsObject:@"types"])
        venue.category = [[[data[@"types"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
    
    if([[venue.name lowercaseString] containsString:@"winery"])
        venue.category = @"Winery";
    
    if([[data allKeys] containsObject:@"icon"])
        venue.icon = data[@"icon"];
    
    if([[data allKeys] containsObject:@"vicinity"])
        venue.address = data[@"vicinity"];
    
    NSLog(@"new google venue - %@", venue);
    return venue;
}

@end
