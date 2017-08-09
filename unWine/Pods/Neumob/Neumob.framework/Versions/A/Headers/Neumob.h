//
//  Neumob.h
//  Neumob iOS Library
//
//  Copyright (c) 2015 Neumob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NMLogLevel) {
    NMLogLevelDetail  = 0x1,
    NMLogLevelWarning = 0x3,
    NMLogLevelError   = 0x4,
    NMLogLevelNone    = 0xF
};

@interface Neumob : NSObject

/**
 Initialization is the process of modifying your application in order to communicate with Neumob.
 Initialize Neumob on the main thread at the beginning of your onCreate activity or Application.
 ```
 [Neumob initialize:clientKey];
 ```
 @param clientKey - application client key
 */
+ (void) initialize:(NSString*)clientKey;

/**
 Initialization is the process of modifying your application in order to communicate with Neumob.
 Initialize Neumob on the main thread at the beginning of your onCreate activity or Application.
 ```
 [Neumob initialize:clientKey completionHandler:^ {
    if ([Neumob initialized]) {
    // Neumob is ON.
        BOOL accelerated = [Neumob accelerated];
        // ex. [Analytics logCustomDimension: Dimension.ACCELERATION value: accelerated];
        ...
    } else {
        // Neumob is OFF. Change log settings for more details.
        ...
    }
 }];
 ```
 @param clientKey - application client key
 @param completionHandler - a block is run after Neumob is asynchronously initialized.
                            The runnable is executed on a background thread.
 */
+ (void) initialize:(NSString*)clientKey completionHandler: (void (^)(void))completionHandler;

// DEPRECATED: please use `+initialize:completionHandler:` instead.
+ (void) initialize:(NSString*)clientKey OnComplete: (void (^)(void))completionHandler DEPRECATED_MSG_ATTRIBUTE("This method has been renamed to `+initialize:completionHandler:`");

+ (BOOL) authenticated;

/**
 Returns a boolean indicating Neumob is enabled and ready to accelerate your network requests.
 
 @return boolean - true if enabled
*/
+ (BOOL) initialized;

/**
 Returns a boolean indicating whether Neumob is currently accelerating your requests. You may
 configure whether or not Neumob is accelerated by adjusting the % accelerated slider through
 the portal (click the settings button for the app version on your app details page). If you
 plan to A / B test accelerated vs unaccelerated Neumob users, we recommend using the
 `accelerated` API in the Runnable. Please note that `accelerated` is sticky- meaning a user
 who is accelerated will remain accelerated until the % accelerated slider value is changed.
 
 @return boolean - true if accelerated
*/
+ (BOOL) accelerated;

/**
 Set whether requests are accelerated through Neumob's custom protocol and cloud. If Neumob
 is not initialized, acceleration will be off. This method should ONLY be called ONCE and should
 take place before Neumob is initialized. Please note that setAcceleration will override portal
 acceleration settings. If Neumob is not initialized then setAcceleration will not take effect.
 ```
 BOOL shouldAccelerate = // Determine whether this device should be accelerated
 [Neumob setAcceleration: shouldAccelerate];
 [Neumob initialize:clientKey completionHandler:^ { ... }];
 ```
 @param shouldAccelerate - whether the session should be accelerated
 */
+ (void)setAcceleration: (BOOL) shouldAccelerate;

/**
 Return the current log level used by the Neumob library.
 
 @return NMLogLevel - logLevel
 */
+ (NMLogLevel)logLevel;

/**
 Set the log level used by the Neumob library.
 
 @return NMLogLevel - logLevel
 */
+ (void)setLogLevel:(NMLogLevel)logLevel;

@end
