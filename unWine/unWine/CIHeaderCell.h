//
//  CIHeaderCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/27/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWCell.h"
#import "APLViewController.h"
#import "pseudoLocationCheckinTableViewController.h"
#import "CameraSessionView.h"
#import "unWineActionSheet.h"
#import "CICameraVC.h"
#import "CIFilterVC.h"

#define FACEBOOK_ICON [AWCell imageWithImage:[UIImage imageNamed:@"facebookIcon"] scaledToSize:CGSizeMake(ICON_SIZE, ICON_SIZE)]

@class PFImageView;

@interface CIHeaderCell : UITableViewCell <APLSelectionDelegate, UIPickerViewDelegate, UIPickerViewDataSource, VenueViewControllerDelegate, unWineActionSheetDelegate, CICameraDelegate, CIFilterDelegate>

@property (nonatomic) id delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *myPath;
@property (nonatomic) PFObject *wine;

@property (nonatomic) id previewable;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wineObject;

- (void)presentPhotoForFiltering:(UIImage *)image;
- (void)cameraFinishedRecording:(NSData *)movieData url:(NSURL *)url thumbnail:(UIImage *)thumbnail;

- (void)updateOccasion:(Occasion *)occasion;

@property (nonatomic, strong) CICameraVC *cameraVC;

@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIToolbar* numberToolbar;

@property (weak, nonatomic) IBOutlet PFImageView *wineImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectVintage;
@property (weak, nonatomic) IBOutlet UIButton *selectOccasion;
@property (weak, nonatomic) IBOutlet UIButton *addLocation;
@property (weak, nonatomic) IBOutlet UIButton *shareFacebook;

@end
