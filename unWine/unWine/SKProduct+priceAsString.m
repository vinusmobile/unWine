//
//  SKProduct+priceAsString.m
//  unWine
//
//  Created by Bryce Boesen on 10/22/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SKProduct+priceAsString.h"

@implementation SKProduct (priceAsString)

- (NSString *) priceAsString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self priceLocale]];
    
    return [formatter stringFromNumber:[self price]];
}

@end