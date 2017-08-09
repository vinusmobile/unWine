//
//  StringHelper.h
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelper : NSObject

+ (CGRect)boundsForString:(NSString *)string font:(UIFont *)font constraint:(CGSize)constraint;

@end
