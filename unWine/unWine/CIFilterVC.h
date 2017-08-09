//
//  CIFilterVC.h
//  unWine
//
//  Created by Bryce Boesen on 10/12/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CIFilterEnhance {
    CIFilterEnhanceOriginal,
    CIFilterEnhanceBrightness,
    CIFilterEnhanceContrast,
    CIFilterEnhanceVibrance,
    CIFilterEnhanceGamma,
    CIFilterEnhanceSaturate,
    CIFilterEnhanceEmboss
} CIFilterEnhance;

typedef enum CIFilterEffect {
    CIFilterEffectOriginal,
    CIFilterEffectBlackWhite,
    CIFilterEffectFilter2,
    CIFilterEffectFilter5,
    CIFilterEffectFilterElLeon,
    CIFilterEffectFilter4,
    CIFilterEffectFilterBoneDry,
    CIFilterEffectFilter6,
    CIFilterEffectFilter7,
    CIFilterEffectFilter8,
    CIFilterEffectFilter9,
    CIFilterEffectFilter10
} CIFilterEffect;

typedef enum CIFilterState {
    CIFilterStateDefault,
    CIFilterStateEnhancing,
    CIFilterStateApplyingEffect,
    CIFilterStateCropping,
    CIFilterStateOrienting
} CIFilterState;

typedef enum CIAlertTag {
    CIALertTagNone,
    CIAlertTagCancel,
    CIAlertTagDoneEnhancing,
    CIAlertTagDoneApplyingEffect,
    CIAlertTagDoneCropping,
    CIALertTagDoneOrienting
} CIAlertTag;

@protocol CIFilterDelegate;
@interface CIFilterVC : UIViewController

@property (nonatomic, strong) id<CIFilterDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

- (void)setImage:(UIImage *)image;
+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;

@end

@protocol CIFilterDelegate <NSObject>
- (void)finishedFiltering:(UIImage *)image withFilter:(NSString *)filter;
@optional - (void)willEndEditting;
@optional - (void)didEndEditting;
@end
