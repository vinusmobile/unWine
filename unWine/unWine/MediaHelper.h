//
//  MediaHelper.h
//  unWine
//
//  Created by Bryce Boesen on 11/16/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Bolts/Bolts.h>
#import "ParseSubclasses.h"

typedef enum CIVideoQuality {
    //CIVideoQuality4K,
    //CIVideoQuality2K,
    CIVideoQuality1080p,
    CIVideoQuality720p,
    CIVideoQuality540p,
    CIVideoQuality480p,
    CIVideoQuality320p,
    CIVideoQualityNone
} CIVideoQuality;

@interface MediaHelper : NSObject

+ (NSArray *)output;
+ (NSString *)outputFileName:(CIVideoQuality)quality;
+ (NSString *)outputPreset:(CIVideoQuality)quality;
+ (BFTask *)getContentForFacebookWithImage:(UIImage *)image;
+ (BFTask *)getContentForFacebookWithThumbnail:(UIImage *)image andMovieURL:(NSURL *)movieURL andRefURL:(NSURL *)refMovieURL;

@end
