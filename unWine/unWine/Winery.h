//
//  Winery.h
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Winery : PFObject <PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) PFGeoPoint *location;
@property (nonatomic) PFFile *image;
@property (nonatomic) BOOL verified;

+ (NSString *)parseClassName;

+ (PFQuery *)find:(NSString *)searchString;
+ (BFTask *)findTask:(NSString *)searchString;
+ (BFTask *)getWineryObjectTask:(NSString *)objectId;
+ (BFTask *)getWinerysTask:(NSArray<NSString *> *)objectIds;

+ (BFTask<Winery *> *)getWineriesNear:(PFGeoPoint *)point;
+ (BFTask<Winery *> *)getNearestMatch:(Venue *)venue;
+ (BFTask<Winery *> *)getNearestMatchCreateIfNecessary:(Venue *)venue;
+ (BFTask<Winery *> *)findFirstCreateIfNecessary:(NSString *)searchString;

- (BFTask *)setWineryImageForImageView:(PFImageView *)imageView;
- (BFTask<UIImage *> *)getWineryImage;
- (NSString *)getWineryName;
- (BOOL)isLikelyVenue:(Venue *)venue;
- (Venue *)getAsVenue;

- (BOOL)hasLocation;

@end
