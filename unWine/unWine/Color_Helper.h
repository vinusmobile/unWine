//
//  Color_Helper.h
//  POLO
//
//  Created by Fabio Gomez on 10/14/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

@interface UIColor(MBCategory)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end