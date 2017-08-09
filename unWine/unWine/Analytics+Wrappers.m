//
//  Analytics+Wrappers.m
//  unWine
//
//  Created by Fabio Gomez on 2/4/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Analytics+Wrappers.h"
#import <Branch/Branch.h>
@implementation Analytics (Wrappers)

#pragma mark - Wrappers to use all Analytics Libraries

+ (void)trackEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions {
    
    if (dimensions) {
        [PFAnalytics trackEvent:eventName dimensions:dimensions];
        [Flurry logEvent:eventName withParameters:dimensions];
    } else {
        [PFAnalytics trackEvent:eventName];
        [Flurry logEvent:eventName];
    }
    
    [APPBOY logCustomEvent:eventName];
    [[Branch getInstance] userCompletedAction:eventName];
    [Intercom logEventWithName:eventName metaData:dimensions];
}

+ (void)startTrackingTimedEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions {
    
    if (dimensions) {
        [Flurry logEvent:eventName withParameters:dimensions timed:YES];
    } else {
        [Flurry logEvent:eventName timed:YES];
    }
}

+ (void)stopTrackingTimedEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions {
    [Flurry endTimedEvent:eventName withParameters:dimensions];
}

@end
