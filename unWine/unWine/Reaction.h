//
//  Reaction.h
//  unWine
//
//  Created by Bryce Boesen on 12/2/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>
#define REACTION_GREAT_WINES @"😍 Wines"
#define REACTION_GOOD_WINES @"🙂 Wines"
#define REACTION_OK_WINES @"😐 Wines"
#define REACTION_BAD_WINES @"🙁 Wines"
#define REACTION_AWFUL_WINES @"😞 Wines"
#define REACTION_NO_REACTION @"No Reaction"
#define REACTION_TITLES @[REACTION_GREAT_WINES,REACTION_GOOD_WINES,REACTION_OK_WINES,REACTION_BAD_WINES,REACTION_AWFUL_WINES,REACTION_NO_REACTION]

typedef enum ReactionType {
    ReactionType5Aweful,
    ReactionType4Bad,
    ReactionType3Okay,
    ReactionType2Good,
    ReactionType1Great,
    ReactionType0None
} ReactionType;

@protocol ReactionViewDelegate;
@interface ReactionView : UIView

@property (nonatomic) id<ReactionViewDelegate> delegate;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *reactionButton;
@property (nonatomic, strong) UILabel *quantityLabel;
@property (nonatomic) ReactionType type;

/*!
 * minimum frame height of 80
 */
+ (instancetype)reactWithFrame:(CGRect)frame type:(ReactionType)type;
- (void)updateQuantity:(BFTask *)task;
- (void)setReactionSize:(NSInteger)fontSize;
- (void)setReaction:(ReactionType)type;

@end

@interface ReactionObject : NSObject

@property (nonatomic) ReactionType type;
@property (nonatomic, strong) NSString *react;
@property (nonatomic, strong) NSString *descriptor;

+ (instancetype)type:(ReactionType)type react:(NSString *)react descriptor:(NSString *)descriptor;

@end

@class User;
@class unWine;
@class NewsFeed;
@interface Reaction : PFObject <PFSubclassing>

@property (nonatomic, strong) User           *user;
@property (nonatomic, strong) unWine         *wine;
@property (nonatomic, strong) NewsFeed       *newsfeed;
@property (nonatomic)         NSNumber       *type;

+ (NSString *)parseClassName;
+ (NSArray<ReactionObject *> *)reactions;
- (BOOL)isNewsFeedReaction;
- (ReactionType)getReactionType;
- (ReactionObject *)getReactionObject;
+ (ReactionObject *)getReactionObject:(ReactionType)type;
+ (BFTask *)reactionsFromObjects:(NSArray<NSString *> *)objectIds;

@end

@protocol ReactionViewDelegate <NSObject>
- (void)reactionPressed:(ReactionType)type;
@end
