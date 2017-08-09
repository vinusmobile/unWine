//
//  CastCheckinTVC.h
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Bolts/Bolts.h>
#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"
#import "CIHeaderCell.h"
#import "CICaptionCell.h"
#import "CIShareCell.h"
#import "VCWineCell.h"
#import "CRToast.h"
#import "MentionTVC.h"

#define CAPTION_CHAR_LIMIT 140

@interface CastCheckinTVC : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MentionTVCDelegate>

@property (nonatomic) NewsFeed *checkin;
@property (nonatomic) unWine *wine;
@property (nonatomic) NSDictionary *registers;
@property (strong, nonatomic) UIImage *newsFeedImage;
@property (strong, nonatomic) UIImage *wineImage;
@property (nonatomic) BOOL isNew;
@property (nonatomic) CastCheckinSource cameFrom;
@property (nonatomic) ReactionType selectedType;
@property (nonatomic) UIView *hudShowView;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic) BOOL pushedFromNotification;
@property (nonatomic) __block BOOL IS_SAVING;

@property (nonatomic, strong) NSString *filterName;
@property (strong, nonatomic) NSData *movieData;
@property (strong, nonatomic) NSURL *movieURL;
@property (strong, nonatomic) NSURL *parseMovieURL;
@property (strong, nonatomic) NSURL *refMovieURL;
@property (strong, nonatomic) NSString *movieFileName;

+ (NSDictionary *)options;

//- (void)addPhoto:(UIImage *) image;
- (void)addVintage:(NSString *)vintage;
- (void)addOccasion:(PFObject *)occasion;
- (void)addLocation:(PFObject *)location;
- (BFTask *)finalCheckin;
+ (Records *)createObject:(unWine *)wine withField:(NSString *)field asValue:(id)value;

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType;

@end
