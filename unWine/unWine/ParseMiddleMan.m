//
//  ParseMiddleMan.m
//  unWine
//
//  Created by Fabio Gomez on 5/15/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "ParseMiddleMan.h"
#import "ParseSubclasses.h"
#import "SlackHelper.h"

@implementation ParseMiddleMan

// Analytics
+ (void)trackEvent:(NSString *)event {
    ANALYTICS_TRACK_EVENT(event);
}

+ (void)trackError:(NSError *)error name:(NSString *)name andMessage:(NSString *)message {
    [Analytics trackError:error withName:name withMessage:message];
}

+ (void)trackRecommendationUserTappedRecommendationTab {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_TAPPED_RECOMMENDATION_TAB);
}

+ (void)trackRecommendationUserSwipedRight {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SWIPED_RIGHT);
}

+ (void)trackRecommendationUserSwipedLeft {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SWIPED_LEFT);
}

+ (void)trackRecommendationUserTappedRightButton {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_TAPPED_RIGHT_BUTTON);
}

+ (void)trackRecommendationUserTappedLeftButton {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_TAPPED_LEFT_BUTTON);
}

+ (void)trackRecommendationUserTappedRewindButton {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_TAPPED_REWIND_BUTTON);
}

// Sharing App Analytics
+ (void)trackRecommendationUserSawInviteAlert {
    User *user = [User currentUser];

    if (user.recommendationPromptType == RecommendationPromptTypeBoth) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_BOTH);
    
    } else if (user.recommendationPromptType == RecommendationPromptTypeFriendInvite) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_FRIEND);
        
    } else if (user.recommendationPromptType == RecommendationPromptTypePurchase) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_PURCHASE);
    }
}

+ (void)trackRecommendationUserSharedApp:(NSString *)activity {
    if ([activity containsString:@"facebook"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_FACEBOOK);
    
    } else if ([activity containsString:@"twitter"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_TWITTER);
        
    } else if ([activity containsString:@"whatsapp"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_WHATSAPP);
        
    } else if ([activity containsString:@"messenger"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_MESSENGER);
        
    } else if ([activity containsString:@"mail"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_EMAIL);
        
    } else if ([activity containsString:@"message"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_TEXT_MESSAGE);
        
    } else if ([activity containsString:@"slack"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_SLACK);
        
    } else if ([activity containsString:@"linkedin"]) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_SHARED_APP_LINKEDIN);
    }
}

+ (void)trackRecommendationUserObtainedWineRecommendationsThroughAppInvites {
    User *user = [User currentUser];
    
    if (user.recommendationPromptType == RecommendationPromptTypeBoth) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_AWARDED_THROUGH_INVITES_BOTH);
        [SlackHelper sendRecommendationMessage:@"<!channel> User Obtained Recommendations through Friend Invites after being shown both Options"];
        
    } else if (user.recommendationPromptType == RecommendationPromptTypeFriendInvite) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_AWARDED_THROUGH_INVITES_FRIEND);
        [SlackHelper sendRecommendationMessage:@"<!channel> User Obtained Recommendations through Friend Invites after being shown Friend Invite option only"];
    }
}

+ (void)trackRecommendationUserPurchasedWineRecommendations {
    User *user = [User currentUser];
    
    if (user.recommendationPromptType == RecommendationPromptTypeBoth) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_PURCHASED_RECOMMENDATIONS_BOTH);
        [SlackHelper sendRecommendationMessage:@"<!channel> User Purchased Recommendations after being shown both Options"];
        
    } else if (user.recommendationPromptType == RecommendationPromptTypePurchase) {
        ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_PURCHASED_RECOMMENDATIONS_PURCHASE);
        [SlackHelper sendRecommendationMessage:@"<!channel> User Purchased Recommendations after being shown Purchase option only"];
    }
}

+ (void)trackRecommendationUserRestoredWineRecommendations {
    ANALYTICS_TRACK_EVENT(EVENT_RECOMMENDATION_USER_RESTORED_RECOMMENDATIONS);
}

@end
