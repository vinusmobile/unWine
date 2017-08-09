//
//  AWEditCell.m
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWEditCell.h"
#import "ParseSubclasses.h"

@implementation AWEditCell
@synthesize hasSetup;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    if(!hasSetup) {
        hasSetup = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.historyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.historyLabel.numberOfLines = 0;
        self.historyLabel.textColor = [UIColor whiteColor];
        [self.historyLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        
        self.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.userImage.layer.borderWidth = .5f;
        self.userImage.layer.cornerRadius = .5f * WIDTH(self.userImage);
        self.userImage.clipsToBounds = YES;
        [self.userImage setContentMode:UIViewContentModeScaleAspectFill];
    }
}

- (void)configure:(PFObject *)object { //history object actually
    self.history = object;
    
    self.historyLabel.text = [AWEditCell getHistory:object];
    [self.historyLabel sizeToFit];
    
    [self configureUserImage:object];
}

+ (NSString *)getHistory:(PFObject *)history {
    NSString *username = [[NSString stringWithFormat:@"%@", history[@"editor"][@"canonicalName"]] capitalizedString];
    NSString *createdAt = [[history.createdAt formattedAsTimeAgo] lowercaseString];
    return [NSString stringWithFormat:@"%@ edited this wine's %@ field %@.", username, history[@"field"], (createdAt == nil)? @"just now" : createdAt];
}

- (void)configureUserImage:(PFObject *)history {
    User *user = (history[@"editor"] == nil) ? [User currentUser] : history[@"editor"];
    
    [user setUserImageForImageView:self.userImage];
    
}

@end
