//
//  VineCastTVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastConstants.h"

#import "HeaderCell.h"
#import "VCWineCell.h"
#import "GameCell.h"
#import "FooterCell.h"
#import "TargetCell.h"
#import "TitleCell.h"
#import "RatingCell.h"
#import "VineCastCell.h"
#import "MeritCell.h"
#import "CaptionCell.h"
#import "LikeCell.h"
#import "ReactionCell.h"
#import "VineCommentCell.h"
#import "NewCommentCell.h"
#import "EarnedMeritCell.h"
#import "Grapes.h"

#import "UITableViewController+Helper.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileTVC.h"

#import "SearchTVC.h"

typedef enum VineCastState {
    VineCastStateGlobal,
    VineCastStateSingle,
    VineCastStateFriends,
    VineCastStateGreatWines
} VineCastState;

typedef enum VineCastGridState {
    VineCastGridStateGreatWines,
    VineCastGridStateGoodWines,
    VineCastGridStateOKWines,
    VineCastGridStateBadWines,
    VineCastGridStateAwfulWines,
    VineCastGridStateNoReactionWines
} VineCastGridState;

@class ProfileTVC;
@interface VineCastTVC : PFQueryTableViewController <UITabBarDelegate, GrapesViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) User *singleUser;
@property (nonatomic) ProfileTVC *profileTVC;
@property (nonatomic) VineCastState state;
@property (nonatomic) VineCastGridState gridState;

//@property (nonatomic, copy) NSArray *objects;

@property (nonatomic,strong) NSMutableArray *cellList;
@property (nonatomic,strong) NewsFeed *singleObject;
@property (nonatomic,strong) NSString *singleObjectId;
@property (nonatomic,strong) NSString *singleObjectType;
@property (nonatomic,strong) NSMutableDictionary *cellImages;
//@property (nonatomic,strong) NSMutableDictionary *fetched;
//@property (strong, nonatomic) UIBarButtonItem *newsButton;
@property (strong, nonatomic) UIBarButtonItem *grapesButton;
@property (nonatomic) BOOL justReappeared;

@property (nonatomic) NSTimeInterval lastUpdateNewsButton;
@property (nonatomic) NSInteger lastUpdateNewsButtonBadge;

@property (nonatomic) CGFloat previousScrollViewYOffset;

@property (nonatomic) BOOL gridMode;

@property (nonatomic) SearchTVCState searchState;
@property (nonatomic) BOOL searchMode;   
@property (nonatomic, strong) NSArray *_results;


- (void)scrollTo:(NSInteger)tag;
- (BFTask *)getVineCastTask;
- (void)sudoToast:(NSIndexPath *)path;
- (VCWineCell *)getWineCell:(NSIndexPath *)path;
- (void)setVineCastSingleObject:(NewsFeed *)object;
- (void)animateNavBarTo:(CGFloat)y;
- (void)updateWithObject:(NewsFeed *)object;

- (void)refreshFilteredObjects;
- (void)showScanner;
- (void)showInvite;

@end
