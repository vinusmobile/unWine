//
//  WineCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VineCastCell.h"
#import "ImageFullVC.h"
#import "CastDetailTVC.h"

@class ImageFullVC, PFImageView;
@interface VCWineCell : VineCastCell {
    AVAudioPlayer *click;
}

@property (nonatomic, strong) AVAudioPlayer *click;
@property (nonatomic, strong) UIView *tinkView;

@property (strong, nonatomic) IBOutlet UIImageView *wineImage; // Don't even touch it
@property (nonatomic) PFImageView * realImage;
@property (strong, nonatomic) UITextView *detailView;
@property (strong, nonatomic) UITextView *captionView;

@property (nonatomic) NSString *occasion;
@property (nonatomic) NSString *vintage;

@property (nonatomic) ImageFullVC *imageFullVC;

- (void)showToastAnimation:(UIButton *)tappedButton;

+ (NSArray *)arrayFromSize:(CGSize)size;
+ (CGRect)getImageFrame:(UIView *)view withImage:(UIImage *)image;
+ (CGRect)getImageFrame:(UIView *)view withDims:(NSArray *)dims;

@end
