//
//  Merits.h
//  unWine
//
//  Created by Bryce Boesen on 8/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MeritAlertView.h"

#define MERIT_MODE_MESSAGE 0
#define MERIT_MODE_DESCRIPTION 1

typedef NS_ENUM(NSInteger, MeritMode) {
    MeritModeSelfShowOnly, //ONLY shows the merits the user has
    MeritModeDiscover, //Unfiltered view of merits, earned or not
    MeritModeDiscoverMessage, //Unfiltered view of merits, earned or not, shows message
    MeritModeUserOnly, //Shows all merits, but you can only get the alert view on owned merits
    MeritModeDiscoverUser //Shows all merits, but reveals ones in the earnedMerits array(including alert view)
};

@interface Merits : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (nonatomic        ) NSInteger             *Index;
@property (nonatomic, strong) NSString              *description;
@property (nonatomic, strong) NSString              *identifier;
@property (nonatomic, strong) PFFile                *image;
@property (nonatomic, strong) NSString              *message;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *type;

- (void)setMeritImageForImageView:(PFImageView *)imageView;
- (MeritAlertView *)createCustomAlertView:(NSInteger)meritMode andShowShareOption:(BOOL)show;
- (MeritAlertView *)createCustomAlertView:(NSInteger)meritMode andMerits:(NSArray *)earnedMerits andShowShareOption:(BOOL)show ;
- (NSDictionary *)getShareContent;
- (UIImage *)getShareImage;
- (NSString *)getShareCaption;

@end
