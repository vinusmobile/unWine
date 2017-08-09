//
//  MessengerCell.h
//  unWine
//
//  Created by Bryce Boesen on 11/10/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "MessengerTVC.h"
#import "ParseSubclasses.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

#define MESSENGER_LABEL_BUFFER 3
#define MESSAGE_LINK_ATTRIBUTES @{(id)kCTForegroundColorAttributeName: UNWINE_RED, (id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone]};

@protocol MessageCellDelegate;

@interface MessengerCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic) UIViewController<MessageCellDelegate> *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) PFObject<MessageDelegate> *object;

@property (strong, nonatomic) UILabel *timeStampLabel;
@property (strong, nonatomic) PFImageView *userImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) TTTAttributedLabel *messageLabel;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(PFObject<MessageDelegate> *)object;
- (void)focus;
- (void)unfocus;
- (void)adjustNameMessageLabels;

- (CGFloat)calculateMessageHeight;

+ (CGFloat)calculateMessageHeight:(UIViewController<MessageCellDelegate> *)delegate message:( PFObject<MessageDelegate> *)object indexPath:(NSIndexPath *)path;

@end

@protocol MessageCellDelegate <NSObject>

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSIndexPath *focusPath;

@required - (BOOL)isLastInGroup:(NSIndexPath *)path;

@end
