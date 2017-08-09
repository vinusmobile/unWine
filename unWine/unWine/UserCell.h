//
//  MentionFriendCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/4/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "ParseSubclasses.h"
#import "ThemeHandler.h"

@protocol UserCellDelegate;
@interface UserCell : UITableViewCell <PFObjectCell, FriendshipDelegate, Themeable>

@property (nonatomic) UIViewController<UserCellDelegate> *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Friendship *friendship;
@property (nonatomic) User *user;

@property (nonatomic, strong) PFImageView *userImage;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIButton *friendshipButton;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(User *)user;
- (void)reconfigure;
- (void)profilePressed;

/*!
 * BFTask wrapper to fetch friends if necessary, encapsulated to provide a completion block if necessary
 */
+ (BFTask<NSArray<User *> *> *)getFriends;
+ (void)setFriends:(NSArray<Friendship *> *)friends;

@end

@protocol UserCellDelegate <NSObject>

@required - (void)reconfigureCells;
//@required - (void)updateCachedFriends;

/*!
 * Ideally push the ViewController on the navigationController's stack
 */
@required - (void)presentViewControllerFromCell:(UIViewController *)controller;

@end
