//
//  ParseMiddleMan.h
//  unWine
//
//  Created by Fabio Gomez on 5/15/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseMiddleMan : NSObject

// Analytics
+ (void)trackEvent:(NSString *)event;
+ (void)trackError:(NSError *)error name:(NSString *)name andMessage:(NSString *)message;
+ (void)trackRecommendationUserTappedRecommendationTab;
+ (void)trackRecommendationUserSwipedRight;
+ (void)trackRecommendationUserSwipedLeft;
+ (void)trackRecommendationUserTappedRightButton;
+ (void)trackRecommendationUserTappedLeftButton;
+ (void)trackRecommendationUserTappedRewindButton;

// Sharing App Analytics
+ (void)trackRecommendationUserSawInviteAlert;
+ (void)trackRecommendationUserSharedApp:(NSString *)activity;
+ (void)trackRecommendationUserObtainedWineRecommendationsThroughAppInvites;
+ (void)trackRecommendationUserPurchasedWineRecommendations;
+ (void)trackRecommendationUserRestoredWineRecommendations;

@end
