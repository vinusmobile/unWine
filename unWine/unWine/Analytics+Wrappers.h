//
//  Analytics+Wrappers.h
//  unWine
//
//  Created by Fabio Gomez on 2/4/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Analytics.h"

#import <UIKit/UIKit.h>

// Analytics
#import <Parse/Parse.h>
#import "Flurry.h"
#import "AppboyKit.h"
#import <Intercom/Intercom.h>
#define MINT [Mint sharedInstance]
#define APPBOY [Appboy sharedInstance]

#import <Bolts/Bolts.h>
#import "unWineAppDelegate.h"


@interface Analytics (Wrappers)

/*! Tracks any non-error and non-timed events using the Analytics SDKs (Splunk Mint, Parse, Appboy, and Flurry)
 \param eventName REQUIRED. The name of the event to track. Must be all in one camel cased word. i.e. newCheckInCreated
 \param dimensions Dictionary containing custom paramaters to keep track of. Can be nil
 \param logLevel REQUIRED. Specific to Splunk Mint SDK. See MintLogLevel in SplunkMint-iOS for different log levels
 \warning Splunk Mint and Appboy do not support adding dimensions to events
 */
+ (void)trackEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions;

/*! Initializes tracking of any non-error and TIMED events using the Analytics SDKs (Splunk Mint and Flurry Only)
 \param eventName REQUIRED. The name of the event to track. Must be all in one camel cased word. i.e. newCheckInCreated
 \param dimensions Dictionary containing custom paramaters to keep track of. Can be nil
 \warning Splunk Mint does not support adding dimensions to events
 */
+ (void)startTrackingTimedEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions;

/*! Initializes tracking of any non-error and TIMED events using the Analytics SDKs (Splunk Mint and Flurry Only)
 \param eventName REQUIRED. The name of the event to track. Must be all in one camel cased word. i.e. newCheckInCreated
 \param dimensions REQUIRED. Dictionary containing custom paramaters to keep track of. Can be nil
 \warning Splunk Mint does not support adding dimensions to events
 */
+ (void)stopTrackingTimedEvent:(NSString *)eventName withDimensions:(NSDictionary *)dimensions;



@end
