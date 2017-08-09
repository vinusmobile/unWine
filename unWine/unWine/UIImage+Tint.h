//
//  UIImage+Tint.h
//  unWine
//
//  Created by Bryce Boesen on 10/14/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

// UIImage+Tint.h

@interface UIImage (Tint)

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

@end