//
//  unWine.h
//  unWine
//
//  Created by Fabio Gomez on 5/20/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "NewsFeed.h"

@class Partner, Reaction, PFImageView;

@interface unWine : PFObject <PFSubclassing>

+ (NSString *)parseClassName;
@property (nonatomic, strong) NSString              *imageSquare;
@property (nonatomic, strong) NSString              *imageLarge;
@property (nonatomic, strong) NSString              *capitalizedName;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *colorType;
@property (nonatomic, strong) NSString              *nameWOWinery;
@property (nonatomic, strong) NSString              *region;
@property (nonatomic, strong) NSString              *varietal;
@property (nonatomic, strong) NSString              *vineyard;
@property (nonatomic, strong) NSString              *vintage;
@property (nonatomic, strong) NSString              *wineType;
@property (nonatomic,       ) int                   trending;
@property (nonatomic,       ) BOOL                  verified;
@property (nonatomic,       ) BOOL                  locked;
@property (nonatomic, strong) NSString              *price;
@property (nonatomic, strong) NSMutableDictionary   *barrels;
@property (nonatomic, strong) NSMutableDictionary   *ratingObject;
@property (nonatomic, strong) PFFile                *thumbnail;
@property (nonatomic, strong) PFFile                *image;
@property (nonatomic, strong) Partner               *partner;
@property (retain           ) PFRelation            *history;
@property (retain           ) PFRelation            *ratings;
@property (nonatomic,       ) NSInteger             checkinCount;
@property (nonatomic, strong) NSMutableArray        *reactions;
@property (nonatomic, strong) NSMutableArray        *words;
@property (nonatomic, strong) NSMutableArray        *hashtags;
@property (nonatomic, strong) NSMutableArray        *photoDims;
@property (nonatomic,       ) int                   swipeRightCounter;
@property (nonatomic,       ) int                   swipeLeftCounter;
@property (nonatomic,       ) BOOL                  userGeneratedFlag;

+ (PFQuery *)find:(NSString *)searchString;
+ (PFQuery *)findByRegion:(NSString *)searchString;
+ (BFTask *)findTask:(NSString *)searchString;
+ (BFTask *)findByRegionTask:(NSString *)searchString;

- (NSString *)getWineName;
- (NSString *)getVineYardName;
- (PFImageView *)getThumbnailImageView;
- (PFImageView *)getLargeImageView;
- (BFTask *)setWineImageForImageView:(PFImageView *)imageView;
- (void) checkIfVerified;
- (BOOL) isEditable;
- (NSString *)getImageURL;

- (BFTask *)taskForDownloadingWineImage;
+ (BFTask *)getWineObjectTask:(NSString *)objectId;
+ (BFTask *)getWinesTask:(NSArray<NSString *> *)objectIds;

- (BFTask *)checkinReactionTask;
- (void)addCheckinReaction:(NewsFeed *)checkin;

+ (BOOL)areAllWinesLocked;
+ (void)setAllWinesLocked:(BOOL)locked;
+ (NSInteger)getVerifiedCount;
+ (void)setVerifiedCount:(NSInteger)count;
+ (NSInteger)getWeatheredCount;
+ (void)setWeatheredCount:(NSInteger)count;

+ (NSArray *)getFeaturedWines;
+ (void)setFeaturedWines:(NSArray *)featured;

- (BOOL)isEqual:(id)object;
- (UIImage *)getImage;

- (BFTask *)increaseSwipeRightCounter;
- (BFTask *)increaseSwipeLeftCounter;

- (BFTask *)createRecordsAndSaveWineWithRegisters:(NSDictionary *)registers;

@end
