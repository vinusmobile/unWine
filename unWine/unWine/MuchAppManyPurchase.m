//
//  RageIAPHelper.m
//  unWine
//
//  Created by Bryce Boesen on 8/24/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "MuchAppManyPurchase.h"

@implementation MuchAppManyPurchase

+ (MuchAppManyPurchase *)sharedInstance {
    static dispatch_once_t once;
    static MuchAppManyPurchase * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.LionMobile.unWine.PhotoFilter",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end