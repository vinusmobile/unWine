//
//  PhotoNameCell.h
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <GCPlaceholderTextView/GCPlaceholderTextView.h>
#import "unWineActionSheet.h"

@class RegistrationTVC;

@interface PhotoNameCell : UITableViewCell <unWineActionSheetDelegate>
@property (strong, nonatomic) IBOutlet  PFImageView *photoView;
@property (strong, nonatomic) IBOutlet  GCPlaceholderTextView *nameTextView;

- (void)setUpWithParent:(RegistrationTVC *)parentTVC;
//- (void)setPhotoViewWithImage:(UIImage *)image;

@end
