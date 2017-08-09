//
//  MentionTVC.h
//  unWine
//
//  Created by Bryce Boesen on 12/4/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "UserCell.h"
#import "PHFComposeBarView.h"

@protocol MentionTVCDelegate, MentionInputDelegate;
@interface MentionTVC : UITableViewController <UserCellDelegate>

@property (nonatomic) UIViewController<MentionTVCDelegate> *delegate;
@property (nonatomic) NSMutableArray<MentionObject *> *mentions;
@property (nonatomic) BOOL isShowingMentions;

+ (void)setupMentionsView:(UIViewController<MentionTVCDelegate> *)delegate;
- (void)showMentions:(CGFloat)offset;
- (void)hideMentions;
- (void)loadObjects;

- (void)addMention:(id<MentionInputDelegate>)delegate user:(User *)user;
- (BOOL)shouldModifyMentions:(id<MentionInputDelegate>)delegate range:(NSRange)range replacing:(NSString *)text;
- (void)updateMentionView:(id<MentionInputDelegate>)delegate text:(NSString *)text;
- (BOOL)shouldShowMentions:(NSRange)range;
- (void)didChangeSelection:(id<MentionInputDelegate>)delegate;

@end

/*!
 * Used for TVC that present the MentionsTVC
 */
@protocol MentionTVCDelegate <NSObject>

@property (nonatomic) MentionTVC *mention;
@property (nonatomic) id<MentionInputDelegate> input;
@property (nonatomic) NSRange mentionIndicator;

- (void)addCaption:(NSString *)caption mentions:(NSMutableArray<MentionObject *> *)_mentions;
@optional - (void)mentionedUser:(User *)user;
- (void)showMentions:(CGFloat)offset;
- (void)hideMentions;

- (UITableView *)getTableView;
@optional - (NSIndexPath *)getLastIndexPath;

@end

/*!
 * Used for the View that has the PHFComposebarView, if applicable
 */
@protocol MentionInputDelegate <NSObject>

@property (nonatomic) PHFComposeBarView *realInputView;
@property (nonatomic) NSInteger keyboardHeight;

@optional - (void)mentionedUser:(User *)user;

@end

/*!
 * Used for PHFComposeBarView ideally
 */
/*@protocol MentionTextViewDelegate <NSObject>

@end*/
