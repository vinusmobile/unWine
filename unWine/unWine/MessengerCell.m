//
//  MessengerCell.m
//  unWine
//
//  Created by Bryce Boesen on 11/10/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "MessengerCell.h"
#import "CastProfileVC.h"
#import "unWineAppDelegate+URL_Handling.h"

@implementation MessengerCell
@synthesize delegate = _delegate, hasSetup = _hasSetup, indexPath = _indexPath, object = _object, timeStampLabel = _timeStampLabel, userImage = _userImage, messageLabel = _messageLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        
        self.userImage = [[PFImageView alloc] init];
        [self.userImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.userImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed)]];
        self.userImage.userInteractionEnabled = YES;
        [self addSubview:self.userImage];
        
        self.timeStampLabel = [[UILabel alloc] init];
        [self.timeStampLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        self.timeStampLabel.textColor = [UIColor darkTextColor];
        self.timeStampLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeStampLabel];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:15]];
        self.nameLabel.textColor = [UIColor darkTextColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed)]];
        self.nameLabel.userInteractionEnabled = YES;
        [self addSubview:self.nameLabel];
        
        self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [self.messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:15]];
        self.messageLabel.textColor = [UIColor darkTextColor];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.userInteractionEnabled = YES;
        self.messageLabel.delegate = self;
        [self addSubview:self.messageLabel];
    }
}

- (void)configure:(PFObject<MessageDelegate> *)object {
    self.object = object;
    
    if(![self.delegate isLastInGroup:self.indexPath])
        self.userImage.alpha = self.nameLabel.alpha = 0;
    else
        self.userImage.alpha = self.nameLabel.alpha = 1;
    
    NSIndexPath *focusPath = self.delegate.focusPath;
    if(focusPath &&
       focusPath.section == self.indexPath.section && focusPath.row == self.indexPath.row) {
        [self focus];
    } else
        [self unfocus];
}

- (void)profilePressed {
    User *user = [self.object getAssociatedUser];
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    [profile setProfileUser:user];
    [self.delegate.navigationController pushViewController:profile animated:YES];
}

- (void)focus {
    self.timeStampLabel.backgroundColor = [UIColor colorWithRed:0.928431 green:0.929209 blue:0.92116 alpha:1];
    self.timeStampLabel.alpha = 1;
}

- (void)unfocus {
    self.timeStampLabel.backgroundColor = [UIColor whiteColor];
    self.timeStampLabel.alpha = 0;
}

+ (CGFloat)calculateMessageHeight:(UIViewController<MessageCellDelegate> *)delegate message:( PFObject<MessageDelegate> *)object indexPath:(NSIndexPath *)path {
    NSString *senderName = [object getSenderName];
    NSString *message = [object getMessage];
    
    if([[delegate.groups objectAtIndex:path.section] count] == 1 || [delegate isLastInGroup:path]) {
        CGFloat labelX = 12;
        CGFloat labelWidth = SCREEN_WIDTH - DEFAULT_MESSAGE_CELL_HEIGHT - labelX - 9;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, 30)];
        [title setFont:[UIFont fontWithName:@"OpenSans-Bold" size:15]];
        title.textColor = [UIColor darkTextColor];
        title.lineBreakMode = NSLineBreakByTruncatingTail;
        [title setText:senderName];
        [title sizeToFit];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, 30)];
        [label setFont:[UIFont fontWithName:@"OpenSans" size:15]];
        label.textColor = [UIColor darkTextColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setText:message];
        [label sizeToFit];
        
        return MAX(HEIGHT(title) + HEIGHT(label) + MESSENGER_LABEL_BUFFER * 4 + 10, DEFAULT_MESSAGE_CELL_HEIGHT);
    } else {
        CGFloat labelX = 12;
        CGFloat labelWidth = SCREEN_WIDTH - DEFAULT_MESSAGE_CELL_HEIGHT - labelX - 9;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, 30)];
        [label setFont:[UIFont fontWithName:@"OpenSans" size:15]];
        label.textColor = [UIColor darkTextColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setText:message];
        [label sizeToFit];
        
        return MAX(HEIGHT(label) + MESSENGER_LABEL_BUFFER * 2, SLIM_MESSAGE_CELL_HEIGHT);
    }
}

- (CGFloat)calculateMessageHeight {
    CGFloat labelX = 12;
    CGFloat labelWidth = SCREEN_WIDTH - WIDTH(self.userImage) - Y2(self.userImage) - labelX - 9;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, 30)];
    [label setFont:[UIFont fontWithName:@"OpenSans" size:15]];
    label.textColor = [UIColor darkTextColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label setText:[self.object getMessage]];
    [label sizeToFit];
    
    return HEIGHT(label);
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *link = [url absoluteString];
    if([link hasPrefix:@"unwineapp:"]) {
        [(GET_APP_DELEGATE) handleProtocolURL:@{@"url": link}];
    } else {
        SFSafariViewController *view = [[SFSafariViewController alloc] initWithURL:url];
        view.view.tintColor = UNWINE_RED;
        [self.delegate presentViewController:view animated:YES completion:nil];
    }
}

- (void)adjustNameMessageLabels {
    if([self.object respondsToSelector:@selector(hasAttributedString)] && [self.object hasAttributedString]) {
        self.messageLabel.linkAttributes = nil;
        self.messageLabel.enabledTextCheckingTypes = 0;
    } else {
        self.messageLabel.linkAttributes = MESSAGE_LINK_ATTRIBUTES;
        self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    }
}

@end
