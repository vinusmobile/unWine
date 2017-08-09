//
//  MessengerSelfCell.m
//  
//
//  Created by Bryce Boesen on 10/3/15.
//
//

#import "MessengerSelfCell.h"
#import "ParseSubclasses.h"
#import "NSDate+NVTimeAgo.h"

@implementation MessengerSelfCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        [super setup:indexPath];

        CGFloat buffer = 2;
        CGFloat dim = DEFAULT_MESSAGE_CELL_HEIGHT - buffer * 2;
        [self.userImage setFrame:CGRectMake(SCREEN_WIDTH - dim - buffer, buffer, dim, dim)];
        self.userImage.layer.cornerRadius = SEMIWIDTH(self.userImage);
        self.userImage.clipsToBounds = YES;
        
        [self.timeStampLabel setFrame:CGRectMake(0, DEFAULT_MESSAGE_CELL_HEIGHT, SCREEN_WIDTH, EXTENDED_MESSAGE_CELL_HEIGHT)];
    }
}

- (void)adjustNameMessageLabels {
    [super adjustNameMessageLabels];
    
    CGFloat labelX = 12;
    CGFloat labelWidth = SCREEN_WIDTH - WIDTH(self.userImage) - Y2(self.userImage) - labelX - 9;
    
    if(self.nameLabel.alpha == 0) {
        [self.nameLabel setFrame:CGRectMake(labelX, 0, labelWidth, 20)];
        [self.messageLabel setFrame:CGRectMake(labelX, 0, labelWidth, [self calculateMessageHeight])];
    } else {
        [self.nameLabel setFrame:CGRectMake(labelX, 10, labelWidth, 20)];
        [self.messageLabel setFrame:CGRectMake(labelX, Y2(self.nameLabel) + HEIGHT(self.nameLabel) + MESSENGER_LABEL_BUFFER * 2 + 1, labelWidth, [self calculateMessageHeight])];
    }
}

- (void)configure:(PFObject<MessageDelegate> *)object {
    [super configure:object];
    self.object = object;
    
    User *user = [object getAssociatedUser];
    [user setUserImageForImageView:self.userImage];
    self.nameLabel.text = [user getName];
    
    self.timeStampLabel.text = [object.createdAt formattedAsTimeAgo];
    
    [self adjustNameMessageLabels];
    if([object respondsToSelector:@selector(hasAttributedString)] && [object hasAttributedString])
        self.messageLabel.text = [object getAttributedString];
    else
        self.messageLabel.text = [object getMessage];
    [self.messageLabel sizeToFit];
}

- (void)focus {
    [super focus];
    
    CGFloat height = [MessengerCell calculateMessageHeight:self.delegate message:self.object indexPath:self.indexPath];
    [self.timeStampLabel setFrame:CGRectMake(0, height, SCREEN_WIDTH, EXTENDED_MESSAGE_CELL_HEIGHT)];
}

@end
