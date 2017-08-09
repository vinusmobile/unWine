//
//  SKProduct+priceAsString.h
//  unWine
//
//  Created by Bryce Boesen on 10/22/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (priceAsString)

@property (nonatomic, readonly) NSString *priceAsString;

@end

