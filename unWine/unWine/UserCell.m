//
//  MentionFriendCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/4/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "UserCell.h"
#import "CastProfileVC.h"

@interface UserCell () <unWineAlertViewDelegate>

@end

@implementation UserCell
@synthesize singleTheme;

static NSInteger bufferX = 12;
static NSInteger bufferY = 16;
//static NSInteger offset = 3;
static NSInteger buffer = 4;
static NSInteger height = 60;

static NSMutableArray<Friendship *> *friends = nil;

+ (BOOL)hasCachedFriends {
    return friends != nil;
}

+ (BFTask<NSArray<User *> *> *)getFriends {
    User *curr = [User currentUser];
    if(friends == nil) {
        return [[curr getFriends] continueWithBlock:^id(BFTask *task) {
            friends = [task.result mutableCopy];
            
            return [UserCell getFriends];
        }];
    } else {
        NSMutableArray<User *> *users = [[NSMutableArray alloc] init];
        for(Friendship *obj in friends)
            if(obj) {
                User *other = [obj getTheFriend:curr];
                if(other && ![other isKindOfClass:[NSNull class]])
                    [users addObject:other];
            }
        
        return [BFTask taskWithResult:users];
    }
}

+ (void)setFriends:(NSArray<Friendship *> *)friendsArray {
    friends = [friendsArray mutableCopy];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    self.userInteractionEnabled = YES;
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.userImage = [[PFImageView alloc] initWithFrame:(CGRect){buffer, buffer, {height - buffer * 2, height - buffer * 2}}];
        self.userImage.layer.cornerRadius = SEMIWIDTH(self.userImage);
        self.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
        self.userImage.layer.borderWidth = .5f;
        self.userImage.clipsToBounds = YES;
        self.userImage.userInteractionEnabled = YES;
        [self.userImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed)]];
        [self.contentView addSubview:self.userImage];
        
        self.friendshipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.friendshipButton setFrame:(CGRect){SCREENWIDTH - height - buffer, 0, {height, height}}];
        [self.friendshipButton setImage:[UIImage imageNamed:@"friendPlus"] forState:UIControlStateNormal];
        [self.friendshipButton setContentMode:UIViewContentModeScaleAspectFill];
        [self.friendshipButton addTarget:self action:@selector(friendshipPressed) forControlEvents:UIControlEventTouchUpInside];
        self.friendshipButton.tintColor = self.backgroundColor;
        self.friendshipButton.layer.cornerRadius = 12;
        self.friendshipButton.clipsToBounds = YES;
        self.friendshipButton.backgroundColor = [ThemeHandler getSeperatorColor:singleTheme];
        self.friendshipButton.bounds = CGRectMake(0, 0, 50, 44);
        [self.friendshipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [self.contentView addSubview:self.friendshipButton];
        
        self.userLabel = [[UILabel alloc] initWithFrame:(CGRect){WIDTH(self.userImage) + bufferX, 0, {WIDTH(self.contentView) - WIDTH(self.userImage) - bufferY, height}}];
        [self.userLabel setTextAlignment:NSTextAlignmentLeft];
        [self.userLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [self.userLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        self.userLabel.adjustsFontSizeToFitWidth = YES;
        self.userLabel.minimumScaleFactor = .75;
        [self.contentView addSubview:self.userLabel];
        
        /*self.usernameLabel = [[UILabel alloc] initWithFrame:(CGRect){WIDTH(self.userImage) + bufferX, 0, {WIDTH(self.contentView) - WIDTH(self.userImage) - bufferY, height}}];
        [self.usernameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.usernameLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        self.usernameLabel.adjustsFontSizeToFitWidth = YES;
        self.usernameLabel.minimumScaleFactor = .5;
        [self.contentView addSubview:self.usernameLabel];*/
    }
}

- (void)configure:(User *)user {
    self.user = user;
    
    [self.user setUserImageForImageView:self.userImage];
    [self.userLabel setText:[self.user getName]];
    [self updateFriendshipButton];
    /*if(ISVALID(self.user.username))
        [self.usernameLabel setText:[NSString stringWithFormat:@"@%@", self.user.username]];
    else
        [self.usernameLabel setText:@""];
    [self adjustLabels];*/
}

- (void)reconfigure {
    [self configure:self.user];
}

/*- (void)adjustLabels {
    [self.userLabel sizeToFit];
    [self.usernameLabel sizeToFit];
    
    NSInteger sumHeight = ISVALID(self.user.username) ? HEIGHT(self.userLabel) + offset + HEIGHT(self.usernameLabel) : HEIGHT(self.userLabel);
    NSInteger y = (height - sumHeight) / 2;
    [self.userLabel setFrame:(CGRect){WIDTH(self.userImage) + bufferX, y, {WIDTH(self.contentView) - WIDTH(self.userImage) - bufferY, HEIGHT(self.userLabel)}}];
    [self.usernameLabel setFrame:(CGRect){WIDTH(self.userImage) + bufferX, Y2(self.userLabel) + HEIGHT(self.userLabel) + offset, {WIDTH(self.contentView) - WIDTH(self.userImage) - bufferY, HEIGHT(self.usernameLabel)}}];
}*/

- (void)profilePressed {
    [self.delegate resignFirstResponder];
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    [profile setProfileUser:self.user];
    [self.delegate presentViewControllerFromCell:profile];
}

- (void)friendshipPressed {
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [self.delegate resignFirstResponder];
        
        [user promptGuest:self.delegate];
        return;
    }
    
    if(friends == nil) {
        [[UserCell getFriends] continueWithBlock:^id(BFTask<NSArray<User *> *> *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self friendshipPressed];
            });
            
            return nil;
        }];
    } else {
        BOOL isUsersFriend = NO;
        for(Friendship *friendship in friends) {
            if([friendship isFriendshipBetween:self.user and:user] && [friendship isAccepted])
                isUsersFriend = YES;
        }
        
        if(isUsersFriend) {
            [Friendship showUnfriendDialogue:self returnTag:0];
        } else {
            NSLog(@"Delegate - %@, PresentationView - %@", self.delegate, [self getPresentationView]);
            [[Friendship sendFriendRequest:self.user fromController:self] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<Friendship *> *task) {
                if([task.result isAccepted]) {
                    [friends addObject:task.result];
                    [self updateFriendshipButton];
                }
                
                ANALYTICS_TRACK_EVENT(EVENT_USER_SENT_FRIEND_INVITE_AFTER_SEARCHING_USER);
                
                return nil;
            }];
        }
    }
}

- (void)updateFriendshipButton {
    self.friendshipButton.alpha = [self.user isTheCurrentUser] ? 0 : 1;
    
    if([self areFriends])
        [self.friendshipButton setImage:[UIImage imageNamed:@"friendMinus"] forState:UIControlStateNormal];
    else
        [self.friendshipButton setImage:[UIImage imageNamed:@"friendPlus"] forState:UIControlStateNormal];
}

- (void)rightButtonPressed {
    [Friendship confirmUnfriend:self.user fromController:self];
}

- (void)updateFriendshipStatus:(User *)user {
    if(friends == nil) {
        [[UserCell getFriends] continueWithBlock:^id(BFTask<NSArray<User *> *> *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate reconfigureCells];
            });
            
            return nil;
        }];
    } else {
        for(Friendship *friendship in friends) {
            if([friendship isFriendshipBetween:user and:[User currentUser]]) {
                [friends removeObject:friendship];
                [self updateFriendshipButton];
                break;
            }
        }
    }
}

- (BOOL)areFriends {
    if(friends) {
        BOOL isUsersFriend = NO;
        
        for(Friendship *friendship in friends) {
            if([friendship isFriendshipBetween:self.user and:[User currentUser]] && [friendship isAccepted])
                isUsersFriend = YES;
        }
        
        return isUsersFriend;
    } else {
        [[UserCell getFriends] continueWithBlock:^id(BFTask<NSArray<User *> *> *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate reconfigureCells];
            });
            
            return nil;
        }];
    }
    
    return NO;
}

+ (NSInteger)getDefaultHeight {
    return height;
}

- (UIView *)getPresentationView {
    return self.delegate.navigationController.view;
}

- (void)updateTheme {
}

@end
