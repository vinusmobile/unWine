//
//  User.h
//  unWine
//
//  Created by Fabio Gomez on 7/22/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

// TODO: Need to update profile registration to use new data structures (location, birthday, gender)

#import <Parse/Parse.h>
#import "Push.h"
#import <Bolts/Bolts.h>
#import "unWine.h"
#import "NewsFeed.h"

#define WITNESS_GUEST_TOAST         @"guest.toast"
#define WITNESS_USER_LOCATION       @"user.location"
#define WITNESS_ALERT_WISH_LIST     @"alert.wishlist"
#define WITNESS_ALERT_VINECAST      @"alert.vinecast"
#define WITNESS_ALERT_DAILY_TOAST   @"alert.daily_toast"
#define WITNESS_ALERT_TOAST         @"alert.toast"
#define WITNESS_ALERT_MERIT         @"alert.merit"
#define WITNESS_ALERT_GRAPES        @"alert.grapes"
#define WITNESS_ALERT_UNIQUE_WINES  @"alert.unique_wines"
#define WITNESS_ALERT_CHECKIN       @"alert.checkin"
#define WITNESS_ALERT_GREAT_REACT   @"alert.great_reaction"
#define WITNESS_VINECAST_LAST       @"vinecast.last"
#define WITNESS_PROFILE_VIEW_COUNT  @"profile.view_count"

/*!
 * Must add string representation to getKeyForSetting when adding UserSetting
 */
typedef enum UserSetting {
    UserSettingSmartCellar,
    UserSettingTheme
} UserSetting;

typedef enum RecommendationPromptType {
    RecommendationPromptTypeNone = 0,
    RecommendationPromptTypeFriendInvite,
    RecommendationPromptTypePurchase,
    RecommendationPromptTypeBoth
} RecommendationPromptType;

@class PFImageView, Level, Push, Winery, Venue, MBProgressHUD;

@interface User : PFUser <PFSubclassing>

// These are the fields mostly used by the app


@property (nonatomic,       ) BOOL                  acceptedTerms;
@property (nonatomic, strong) PFFile                *imageFile;
@property (nonatomic, strong) NSString              *canonicalName;
@property (nonatomic, strong) NSString              *phoneNumber;
@property (nonatomic,       ) NSInteger             checkIns;
@property (nonatomic, strong) NSMutableArray        *friends;
@property (nonatomic,       ) NSInteger             uniqueWines;
@property (nonatomic, strong) NSMutableDictionary   *profile;
@property (nonatomic, strong) NSMutableArray        *earnedMerits;
@property (nonatomic, strong) NSMutableArray        *Likes;
@property (nonatomic, strong) NSString              *location;
@property (nonatomic, strong) NSString              *gender;
@property (nonatomic, strong) NSString              *facebookId;
@property (nonatomic, strong) NSString              *facebookPhotoURL;
@property (nonatomic, strong) NSDate                *lastLogin;
@property (nonatomic, strong) NSMutableArray        *blockedUsers;
@property (nonatomic, strong) NSMutableDictionary   *notifications;
@property (nonatomic, strong) NSMutableDictionary   *userSettings;
@property (nonatomic, strong) NSMutableArray        *creditedWines;
@property (nonatomic, strong) NSString              *twitterHandle;
@property (nonatomic,       ) NSInteger             timezone;
@property (nonatomic,       ) NSMutableDictionary   *palateData;
@property (nonatomic) BOOL seenTutorial;

// Cellar Stuff
@property (nonatomic, strong) NSMutableArray        *cellar; //deprecated
@property (retain           ) PFRelation            *theCellar;
@property (nonatomic,       ) NSInteger             cellarCount;

// Grapes stuff
@property (nonatomic,       ) NSInteger             currency;
@property (nonatomic,       ) NSInteger             currencyTotal;
@property (retain           ) PFRelation            *grapes;
@property (nonatomic        ) BOOL                  hasPhotoFilters;

// Sobriety Test stuff
@property (nonatomic, strong) NSMutableDictionary   *freeplays;
@property (nonatomic, strong) NSMutableDictionary   *highscores;

// Friends stuff
@property (retain           ) PFRelation            *friendsList;
@property (nonatomic,       ) NSInteger             friendCount;
@property (nonatomic        ) BOOL                  sharedApp;

// Stuff we want to move to primarily

@property (nonatomic, strong) NSDate                *birthday;
@property (retain           ) PFRelation            *checkins;
@property (retain           ) PFRelation            *contributions;
@property (retain           ) PFRelation            *ratings;
@property (nonatomic, strong) Level                 *level;
//@property (nonatomic, strong) PFRelation            *likes;
@property (retain           ) PFRelation            *locations;

// Default Parse stuff that's not being used
@property (nonatomic,       ) BOOL                   emailVerified;

// Backend stuff
@property (nonatomic, strong) NSString              *version;
@property (nonatomic,       ) BOOL                   emailUnsubscribed;

// Recent Checkin/Search
@property (nonatomic, strong) NSMutableArray        *recentCheckins;
@property (nonatomic, strong) NSMutableArray        *recentSearches;
@property (nonatomic, strong) NSMutableArray        *followedWineries;

// PM stuff
//@property (retain           ) PFRelation            *conversations;

@property (nonatomic, readonly) BOOL                 isAdmin;
@property (nonatomic, readonly) BOOL                 isUnwinegineer;
@property (nonatomic,         ) BOOL                 isSuperUser;

// App Rating and Recommendation Stuff
@property (nonatomic,         ) BOOL                 ratedApp;
@property (nonatomic,         ) BOOL                 hasWineRecommendations;

// ABC Test Stuff
/*
    Recommendation ABC Pop Up Type: The kind of prompt a user gets to obtain Recommendation Engine
 
     typedef enum RecommendationPromptType {
         RecommendationPromptTypeNone = 0,
         RecommendationPromptTypeFriendInvite,
         RecommendationPromptTypePurchase,
         RecommendationPromptTypeBoth
     } RecommendationPromptType;
 */
@property (nonatomic,         ) NSInteger            recommendationPromptType;


/*
 * SIGN UP STUFF
 */
- (BFTask *)initializeAndThenSignUp;
- (BFTask *)signUpUserWithHUD:(MBProgressHUD *)hud;
- (BFTask *)uploadPictureAndThenSignUpWithHUD:(MBProgressHUD *)hud;

/*
 * USER INIT STUFF
 */
+ (void)unwitnessAllAlerts;
+ (BFTask *)initStuffWithUser:(User *)user;
- (BFTask *)updateSocialMediaInfo;

/*
 * TWITER STUFF
 */
+ (BFTask *)twitterLogin;
+ (BFTask *)getTwitterUserData;


/*
 * FACEBOOK STUFF
 */
+ (BFTask *)facebookLogin;
+ (BFTask *)getFacebookUserData;
+ (BFTask <NSArray <NSDictionary*>*>*)getFacebookFriends;
+ (BFTask <NSMutableArray <User *>*>*)getUsersFromFacebookFriends;
+ (BFTask *)deauthorizeFacebook:(User *)user;

/*
 * GUEST STUFF
 */
+ (BFTask *)continueAsGuest;

/*
 * LOGOUT STUFF
 */
+ (BFTask *)logOutAndDismiss:(UIViewController *)view;
+ (BFTask *)deleteAndLogoutGuest;
+ (BFTask *)deleteAndLogoutUser;

/*
 * INSTALLATION STUFF
 */
- (void)updateInstallation;
- (void)saveInstallation;


+ (PFQuery *)query;
+ (PFQuery *)find:(NSString *)searchString;
+ (BFTask *)findTask:(NSString *)searchString;
+ (BFTask *)getUserObjectTask:(NSString *)objectId;

+ (NSInteger)getFiltersLockedAfter;
+ (NSString *)getShareMessageAndURL;
+ (NSString *)getShareMessage;
+ (NSString *)getAppStoreURL;
+ (void)setFiltersLockedAfter:(NSInteger)after;
+ (void)setSuperUserCheckinCount:(NSInteger)count;
+ (void)setShareMessage:(NSString *)message;
+ (void)setAppStoreURL:(NSString *)url;

+ (NSString *)getFacebookFetchURL:(NSString *)identifier;

- (BFTask *)saveInBackground;
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;

// Notification Stuff
- (NotificationsSetting)getNotificationStatus:(NotificationType)type;
- (void)setNotificationStatus:(NotificationType)type setting:(NotificationsSetting)setting;

// Settings Stuff
- (id)getUserSetting:(UserSetting)setting;
- (void)setUserSetting:(UserSetting)setting value:(id)value;
- (BOOL)isUsingSmartCellar;

/*!
 * check to see if the OTHER user receives this type of notification
 */
- (BFTask *)canReceiveNotification:(NotificationType)type;

/*!
 * check to see if the CURRENT user receives this type of notification
 */
- (BFTask *)shouldReceiveNotificationFrom:(NSString *)userObjectId withType:(NotificationType)type;

// Methods

- (BOOL)hasFacebook; // Only works with current user via [User currentUser]
- (BOOL)hasTwitter;
- (NSString *)getName;
- (NSString *)getMentionName:(BOOL)includeAt;
- (BOOL)isMentionName:(NSString *)name;
- (NSString *)getFirstName;
- (NSString *)getLastName;
- (NSString *)getShortName;
- (BOOL)hasCellar;
- (BFTask *)getCellar;
- (BFTask *)filterOutWinesInWishlist:(NSArray *)wines;

- (BFTask *)getFriends;//:(void(^)(NSMutableArray *))callback;
- (BFTask<NSArray<User *> *> *)getFriendUsers;
- (BFTask *)getFriendshipWithUser:(User *)user;
- (BFTask *)isFriendsWithUser:(User *)user;
- (BFTask *)isFriendsWithUserId:(NSString *)userObjectId;
- (NSInteger)getFriendCount;

- (BFTask *)updateCellarCount;
- (BFTask *)hasWineInWishList:(unWine *)wine;
- (BFTask *)addWineToCellar:(unWine *)wine;
- (BFTask *)removeWineFromCellar:(unWine *)wine;
- (BOOL)didToastPost:(NewsFeed *)newsfeed;
- (void)toastPost:(NewsFeed *)newsfeed;
- (void)untoastPost:(NewsFeed *)newsfeed;

- (BOOL)hasMerits;
- (NSMutableArray *)getMerits;
- (NSInteger)getNumberOfMeritCellsForUser;
- (NSString *)getProfileImageURL;
- (NSString *)getFacebookImageURL;
- (NSString *)getFacebookFetchURL;
- (NSString *)getGender;
- (NSDate *)getDateOfBirth;
- (int)getAge;
- (NSString *)getLocation;
- (void)setProfileImageWithImage:(UIImage *)image;

- (NSArray *)filterNewsFeedIntoWines:(NSArray *)objects;

- (NSMutableArray *)getCreditedWines;
- (void)addCreditedWines:(unWine *)wine;

- (void)setUserImageForImageView:(PFImageView *)imageView;
//- (void)setCellarImagesForScrollCell:(ScrollCell *)cell;
//- (void)loadFriendsForScrollCell:(ScrollCell *)cell;
- (BFTask *)taskForDownloadingUserImage;

- (BFTask *)updateProfileWithHUD:(MBProgressHUD *)hud;

- (BOOL)isTheCurrentUser;
- (BOOL)isEqualToUser:(User *)other;

- (BOOL)isAnonymous; //only works with current user
- (void)promptGuest:(UIViewController *)controller;

- (void)addRecentCheckinsObject:(NSString *)objectId;
- (void)addRecentSearchesObject:(NSString *)search;
- (void)removeRecentSearchesObject:(NSString *)search;
- (NSMutableArray *)getRecentSearchesObjects;
- (NSMutableArray *)getRecentCheckinsObjects;

- (NSMutableArray *)getFollowedWineries;
- (BOOL)isFollowingWinery:(Winery *)winery;
- (void)followWinery:(Winery *)winery;
- (void)unfollowWinery:(Winery *)winery;

- (BFTask *)updateUniqueWinesCount;

+ (void)witnessed:(NSString *)key;
+ (void)unwitness:(NSString *)key;
+ (BOOL)hasSeen:(NSString *)key;
+ (void)setWitnessState:(NSString *)key state:(NSString *)state;
+ (NSString *)getWitnessState:(NSString *)key;
+ (void)setWitnessValue:(id)value key:(NSString *)key;
+ (id)getWitnessValue:(NSString *)key;

- (BOOL)hasUserBlocked:(User *)user;
- (void)blockUser:(User *)user;
- (void)unblockUser:(User *)user;

- (BFTask *)updateSuperUserStatus;
- (BFTask *)getUniqWines;

- (Level *)getLevel;
- (BFTask *)checkLevel;
+ (BFTask *)getLevels;

- (BFTask<NSArray<Venue *> *> *)getAssociatedVenues;

+ (void)requestPasswordResetWithEmail:(NSString *)email forViewController:(UIViewController *)vc;


- (void)sharedTheApp;
- (void)ratedTheApp;
- (BFTask *)sendFeedbackEmail:(NSString *)feedback;

- (BFTask *)awardRecommendations;
- (BFTask *)randomlySetPromptType;

@end
