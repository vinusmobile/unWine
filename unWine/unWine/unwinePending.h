//
//  unwinePending.h
//  unWine
//
//  Created by Fabio Gomez on 5/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class PFImageView;

@interface unwinePending : PFObject

+ (NSString *)parseClassName;
@property (nonatomic, strong) NSString              *imageSquare;
@property (nonatomic, strong) NSString              *imageLarge;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *region;
@property (nonatomic, strong) NSString              *vineyard;
@property (nonatomic, strong) NSString              *wineType;
@property (nonatomic,       ) int                    trending;
@property (nonatomic,       ) BOOL                   verified;
@property (nonatomic, strong) NSMutableDictionary   *barrels;
@property (nonatomic, strong) NSMutableDictionary   *ratingObject;
@property (nonatomic, strong) PFFile                *image;


- (PFImageView *)getLargeImageView;
- (void)setWineImageForImageView:(PFImageView *)imageView;

@end
