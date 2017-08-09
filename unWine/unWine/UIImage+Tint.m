//
//  UIImage+Tint.m
//  unWine
//
//  Created by Bryce Boesen on 10/14/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

// UIImage+Tint.m

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

#pragma mark - Public methods

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor
{
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeOverlay];
}

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor
{
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeDestinationIn];
}

#pragma mark - Private methods

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end