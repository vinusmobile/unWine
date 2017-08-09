//
//  VineCastCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastConstants.h"

@class VineCastTVC, NewsFeed;
@class HeaderCell, VCWineCell, GameCell, FooterCell, TargetCell, TitleCell, RatingCell, MeritCell, LikeCell, VineCommentCell, NewCommentCell;
@interface VineCastCell : UITableViewCell

@property (strong, nonatomic) VineCastTVC *delegate;
@property (strong, nonatomic) NewsFeed *object;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL hasSetup;
@property (nonatomic) BOOL isCompletelyVisible;

- (void)firstSetup:(id)delegate indexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(NewsFeed *)object;
- (void)setup;

- (void)notifyCompletelyVisible;
- (void)notifyNotCompletelyVisible;

+ (PFObject *)getWineForObject:(NewsFeed *)object;

@end
