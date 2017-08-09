//
//  Notification.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@class User, NewsFeed, Comment, Winery;

@interface Notification : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (nonatomic, strong) User     *Author;
@property (nonatomic, strong) User     *Owner;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) Comment  *commentPointer;
@property (nonatomic, strong) PFObject *constant;// No longer used I guess
@property (nonatomic,       ) BOOL     isComment;
@property (nonatomic, strong) NewsFeed *newsFeedPointer;
@property (nonatomic, strong) unWine   *winePointer;
@property (nonatomic, strong) Winery   *wineryPointer;
@property (nonatomic,       ) BOOL     viewed;

+ (BFTask *)createNotificationObjectFor:(NewsFeed *)newsFeedObject usingComment:(Comment *)comment andUser:(User *)user;
+ (BFTask *)createCheckinNotification:(NewsFeed *)newsFeedObject andUser:(User *)user;
+ (BFTask *)createRecommendationNotification:(NewsFeed *)newsFeedObject andUser:(User *)user;
+ (BFTask *)createRecommendationObjectFor:(unWine *)winePointer andUser:(User *)user;
+ (BFTask *)createMentionNotification:(NewsFeed *)newsFeedObject andUser:(User *)user atCheckin:(BOOL)atCheckin;
+ (BFTask *)createRecommendationObjectForWinery:(Winery *)wineryPointer andUser:(User *)user;

- (NSString *)getAuthorName;
- (NSString *)getNewsFeedAuthorName;
- (BOOL)ownerIsEqualToNewsFeedAuthor;

- (NSString *)getNotificationMessage;
- (NSString *)getToastMessage;
- (NSString *)getCommentMessage;
- (NSString *)getAlertMessage;

- (BOOL)isAlertNotification;
- (BOOL)isRecommendationNotification;
- (BOOL)isToastNotification;
- (BOOL)isCommentNotification;

- (BOOL)hasSeen;
- (BFTask *)markSeen;

+ (BFTask *)sendMentionNotificationsFromMentions:(NSArray *)mentions forCheckin:(NewsFeed *)checkin atCheckin:(BOOL)atCheckin;
+ (BFTask *)sendCheckinNotificationsToFriendsExcept:(NSMutableArray<User *> *)mentionUsers forCheckin:(NewsFeed *)checkin andWine:(unWine *)wine;

@end
