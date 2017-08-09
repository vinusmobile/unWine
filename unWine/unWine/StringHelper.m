//
//  StringHelper.m
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "StringHelper.h"

@implementation StringHelper

+ (CGRect)boundsForString:(NSString *)string font:(UIFont *)font constraint:(CGSize)constraint {
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor blackColor]};

    return [string boundingRectWithSize:constraint options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
}

@end
