//
//  Venue.h
//  unWine
//
//  Created by Bryce Boesen on 10/8/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User;
@interface Venue : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *category;
@property (nonatomic) User *user;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;

- (BOOL)isCustom;
- (PFGeoPoint *)getGeoPoint;
- (BOOL)isWinery;
- (BOOL)isLikelyVenue:(Venue *)venue;

+ (Venue *)venueFromGoogle:(NSDictionary *)data;

@end
