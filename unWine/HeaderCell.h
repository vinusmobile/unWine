//
//  HeaderCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"
#import "ProfileTVC.h"
#import "CastProfileVC.h"

#define VC_HEADER_CELL_HEIGHT 72

@class ProfileTVC, CastProfileVC;
@interface HeaderCell : VineCastCell

- (void)configureCell:(PFObject *)object withPath:(NSIndexPath *)path;

- (void)profilePressed:(UITapGestureRecognizer *)recognizer;

@end
