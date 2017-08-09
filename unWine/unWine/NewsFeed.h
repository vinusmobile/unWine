//
//  NewsFeed.h
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "Reaction.h"

@interface MentionObject : NSObject

@property (nonatomic) NSRange range;
@property (nonatomic) User *user;

+ (instancetype)user:(User *)user range:(NSRange)range;
- (BOOL)doesIntersectRange:(NSRange)range;
- (BOOL)isContainedInRange:(NSRange)range;
- (BOOL)isRangeEqual:(NSRange)range;
- (NSComparisonResult)compare:(MentionObject *)other;

@end

@class User, unWine, Merits, Feeling, Occasion, Venue, Comment, Reaction;

@import MediaPlayer;
@interface NewsFeed : PFObject
+ (NSString *)parseClassName;

@property (nonatomic, strong) User           *authorPointer;
@property (nonatomic, strong) unWine         *unWinePointer;
@property (nonatomic, strong) Merits         *meritPointer;
@property (nonatomic, strong) NSString       *Type;
@property (nonatomic, strong) NSMutableArray *relatedUsers;
@property (nonatomic,       ) NSInteger      Likes;
//@property (nonatomic,       ) NSInteger      Comments;
@property (nonatomic, strong) NSString       *location;
@property (nonatomic, strong) PFFile         *photo;
@property (nonatomic, strong) PFFile         *video;
@property (nonatomic, strong) NSString       *videoURL;
@property (nonatomic, strong) NSString       *wineType;
@property (nonatomic,       ) BOOL           verified;
@property (nonatomic,       ) BOOL           express;

@property (nonatomic, strong) NSString       *vintage;
@property (nonatomic, strong) NSMutableArray *connectedMerits;
@property (nonatomic, strong) Feeling        *feelingPointer;
@property (nonatomic, strong) Occasion       *occasionPointer;
/*!
 * Exists for backwards compatability only, remove later, do not edit manually, use methods
 */
@property (nonatomic        ) NSInteger      Comments;
/*!
 * Do not edit manually, use methods
 */
@property (nonatomic, strong) NSMutableArray *commentIds;
/*!
 * Do not edit manually, use methods
 */
@property (nonatomic, strong) NSMutableArray *toasters;
//Skipping game pointer

@property (nonatomic, strong) NSMutableArray *photoDims;
@property (nonatomic, strong) Venue          *venue;

@property (nonatomic, strong) NSMutableArray *caption;
@property (nonatomic) NSNumber               *reactionType;

@property (nonatomic, strong) NSString       *localDate;

+ (instancetype)prepareWithWine:(unWine *)wine;
+ (PFQuery *)query;

- (BOOL)userIsEqualToAuthor:(User *)user;
- (BOOL)currentUserIsAuthor;
- (NSString *)getAuthorName;
//- (BOOL)notificationObjectExistsForUser:(User *)user;
- (BOOL)hasRelatedUsers;
- (BOOL)relatedUsersContainsCurrentUser;
- (BOOL)relatedUsersContainsOnlyTheCurrentUser;
- (BFTask *)addCurrentUserToRelevantUserList;
- (void)sendPushNotificationWithComment:(Comment *)comment except:(NSMutableArray<User *> *)mentionUsers;

- (BOOL)isMeritType;
- (BOOL)isWineType;
- (NSString *)getMeritName;
- (NSString *)getWineName;

- (BOOL)hasCaption;
- (NSMutableAttributedString *)getFormattedCaption:(UIColor *)color;
+ (NSMutableAttributedString *)getFormattedCaption:(NSArray *)raw color:(UIColor *)color;
+ (NSArray *)makeRawCaption:(NSString *)text mentions:(NSArray<MentionObject *> *)mentions;
- (ReactionType)getReaction;
- (ReactionObject *)getReactionObject;
+ (NSString *)getFormattedUserForCaption:(User *)user;

- (BOOL)hasPhoto;
- (BOOL)hasWinePhoto;

- (BOOL)hasMovie;
- (UIButton *)getPlayButton;
- (MPMoviePlayerController *)playMovieFromView:(UIView *)view;
- (void)playMovieFromNVC:(UINavigationController *)controller;

- (BFTask *)getRelatedUsers;
- (BFTask *)getRelatedFriendUsers;

- (NSArray *)getToasters;
- (BFTask *)addToaster:(User *)user;
- (BFTask *)removeToaster:(User *)user;
- (BFTask *)removeToasterId:(NSString *)objectId;
- (BOOL)shouldUpdateToastCount;
- (BFTask *)updateToastCount;
- (BFTask *)updateToastCountIfNecessary;

- (NSArray *)getCommentIds;
- (BOOL)shouldUpdateCommentCount;
- (BFTask *)addComment:(Comment *)comment;
- (BFTask *)removeComment:(Comment *)comment;
- (BFTask *)removeCommentId:(NSString *)objectId;
- (BFTask *)updateCommentCount;
- (BFTask *)updateCommentCountIfNecessary;

+ (BFTask *)getNewsFeedObjectTask:(NSString *)objectId;
+ (BFTask *)newsfeedObjectsFromIds:(NSArray *)objectIds;
+ (BFTask *)newsfeedObjectsFromIds:(NSArray *)objectIds includeKeys:(BOOL)include;

+ (BFTask *)wineCheckinsForUser:(User *)user;

- (NSDictionary *)getShareContent;
- (UIImage *)getShareImage;
- (NSString *)getShareCaption;

+ (NSArray *)getNewsfeedObjectsWithReactionType:(ReactionType)type fromArray:(NSArray *)array;
- (BFTask *)finishSavingCheckinWithExpress:(BOOL)express;

- (BFTask *)finalCheckinWithImage:(UIImage *)newsFeedImage
                             wine:(unWine *)wine
                        wineImage:(UIImage *)wineImage
                        registers:(NSDictionary *)registers
                            venue:(Venue *)venue
                         mentions:(NSArray *)mentions
                          express:(BOOL)express
                 andProgressBlock:(PFProgressBlock)progressBlock;
@end
