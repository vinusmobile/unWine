//
//  NewsFeed.m
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "NewsFeed.h"
#import <Parse/PFObject+Subclass.h>
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>
#import <UIKit/UIKit.h>
#import "NSDate+CurrentDateString.h"

@interface NewsFeed ()<PFSubclassing>

@end

@import AVFoundation;
@import MediaPlayer;
@implementation NewsFeed {
    NSMutableSet *_dirtyFields;
}
@dynamic authorPointer, unWinePointer, meritPointer, Type, relatedUsers, Likes, /*Comments,*/ location, photo, wineType, verified, vintage, connectedMerits, feelingPointer, occasionPointer, Comments, photoDims, venue, video, videoURL, caption, reactionType, commentIds, toasters, express, localDate;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"NewsFeed";
}

+ (PFQuery *)query {
    PFQuery *query = [super query];
    [query includeKey:@"authorPointer"];
    [query includeKey:@"authorPointer.level"];
    [query includeKey:@"unWinePointer"];
    [query includeKey:@"unWinePointer.partner"];
    [query includeKey:@"meritPointer"];
    [query includeKey:@"venue"];
    
    return query;
}

+ (BFTask *)getNewsFeedObjectTask:(NSString *)objectId {
    PFQuery *query = [NewsFeed query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query whereKey:@"Type" containedIn:[NSArray arrayWithObjects:@"Wine", @"Merit", @"Game", nil]];
    [query whereKeyExists:@"authorPointer"];
    [query includeKey:@"meritPointer"];
    [query includeKey:@"gamePointer"];
    [query includeKey:@"feelingPointer"];
    [query includeKey:@"occasionPointer"];
    [query includeKey:@"connectedMerits"];
    [query includeKey:@"venue"];
    
    return [query getFirstObjectInBackground];
}

+ (BFTask *)newsfeedObjectsFromIds:(NSArray *)objectIds {
    return [NewsFeed newsfeedObjectsFromIds:objectIds includeKeys:YES];
}

+ (BFTask *)newsfeedObjectsFromIds:(NSArray *)objectIds includeKeys:(BOOL)include {
    PFQuery *query = [NewsFeed query];
    [query whereKey:@"objectId" containedIn:objectIds];
    [query whereKey:@"Type" containedIn:[NSArray arrayWithObjects:@"Wine", @"Merit", @"Game", nil]];
    [query whereKeyExists:@"authorPointer"];
    if(include) {
        [query includeKey:@"authorPointer"];
        [query includeKey:@"authorPointer.level"];
        [query includeKey:@"unWinePointer"];
        [query includeKey:@"unWinePointer.partner"];
        [query includeKey:@"meritPointer"];
        [query includeKey:@"gamePointer"];
        [query includeKey:@"feelingPointer"];
        [query includeKey:@"occasionPointer"];
        [query includeKey:@"connectedMerits"];
        [query includeKey:@"venue"];
    }
    
    return [query findObjectsInBackground];
}

+ (instancetype)prepareWithWine:(unWine *)wine {
    NewsFeed *checkin = [NewsFeed objectWithClassName:@"NewsFeed"];
    checkin.unWinePointer = wine;
    checkin.authorPointer = [User currentUser];
    checkin.Type = @"Wine";
    checkin.Likes = 0;
    checkin.verified = YES;
    checkin.reactionType = @(ReactionType0None);
    
    return checkin;
}

/*- (void)setObject:(id)object forKey:(NSString *)key {
    if(!_dirtyFields)
        _dirtyFields = [[NSMutableSet alloc] init];
    
    if(![key isEqualToString:@"_dirtyFields"]) {
        [_dirtyFields addObject:key];
    }
    
    [super setObject:object forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if(!_dirtyFields)
        _dirtyFields = [[NSMutableSet alloc] init];
    
    if(![key isEqualToString:@"_dirtyFields"]) {
        [_dirtyFields addObject:key];
    }
    
    [super setValue:value forKey:key];
}*/

- (BOOL)hasMovie {
    return NO; //ISVALID(self.videoURL) || ISVALIDOBJECT(self.video);
}

- (UIButton *)getPlayButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 120, 120)];
    [button setContentMode:UIViewContentModeScaleAspectFill];
    [button setImageEdgeInsets:UIEdgeInsetsZero];
    button.tintColor = [UIColor whiteColor];
    button.userInteractionEnabled = YES;
    
    button.layer.shadowColor = [UNWINE_GRAY_DARK CGColor];
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 2;
    
    return button;
}

- (MPMoviePlayerController *)playMovieFromView:(UIView *)view {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL URLWithString:ISVALID(self.videoURL) ? self.videoURL : self.video.url];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [player prepareToPlay];
    
    [player.view setFrame:CGRectMake(0, 0, WIDTH(view), HEIGHT(view))];
    player.view.backgroundColor = [UIColor clearColor];
    player.controlStyle = MPMovieControlStyleNone;
    player.scalingMode = MPMovieScalingModeAspectFit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    
    //UIView *movieBox = [[UIView alloc] initWithFrame:player.view.frame];
    //[movieBox setBackgroundColor:[UIColor clearColor]];
    //[movieBox addSubview:player.view];
    
    [view addSubview:player.view];
    
    [player play];
    
    return player;
}

- (void)playMovieFromNVC:(UINavigationController *)controller {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL URLWithString:ISVALID(self.videoURL) ? self.videoURL : self.video.url];
    
    MPMoviePlayerViewController *playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [controller presentViewController:playerView animated:YES completion:nil];
}

- (void)movieFinished:(MPMoviePlayerController *)player {
    [player.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
}

- (BOOL)userIsEqualToAuthor:(User *)user {
    return [self.authorPointer.objectId isEqualToString:user.objectId];
}

- (BOOL)currentUserIsAuthor {
    return [self userIsEqualToAuthor:[User currentUser]];
}

- (NSString *)getAuthorName {
    return [self.authorPointer getName];
}

- (BFTask *)notificationObjectExistsForUser:(User *)user {
    PFQuery *notificationQuery = [Notification query];
    
    [notificationQuery whereKey:@"Author"           equalTo:[User currentUser]];
    [notificationQuery whereKey:@"Owner"            equalTo:user];
    [notificationQuery whereKey:@"NewsFeedObject"   equalTo:self.objectId];
    [notificationQuery whereKey:@"isComment"        equalTo:[NSNumber numberWithBool:NO]];
    
    return [notificationQuery countObjectsInBackground];
}

- (BOOL)hasRelatedUsers {
    //LOGGER(self.relatedUsers.description);
    return (self.relatedUsers && self.relatedUsers.count > 0);
}

- (BOOL)relatedUsersContainsCurrentUser {
    return ([self hasRelatedUsers] && [self.relatedUsers containsObject:[User currentUser].objectId]);
}

- (BOOL)relatedUsersContainsOnlyTheCurrentUser {
    return ([self relatedUsersContainsCurrentUser] && self.relatedUsers.count == 1);
}

- (BFTask *)getRelatedUsers {
    PFQuery *userQuery = [User query];
    [userQuery whereKey:@"objectId" containedIn:self.relatedUsers];
    return [userQuery findObjectsInBackground];
}

- (BFTask *)getRelatedFriendUsers {
    return [[self getRelatedUsers] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            return [BFTask taskWithError:task.error];
        }
        
        NSMutableSet *relatedUsers = [NSMutableSet setWithArray:task.result];
        return [[[User currentUser] getFriends] continueWithBlock:^id(BFTask *friends) {
            NSMutableSet *relatedFriends = [NSMutableSet setWithArray:friends.result];
            [relatedFriends intersectSet:relatedUsers];
            
            LOGGER(relatedFriends);
            
            return [BFTask taskWithResult:relatedFriends];
        }];
    }];
}

- (BFTask *)addCurrentUserToRelevantUserList {
    User *user = [User currentUser];
    
    if ([self currentUserIsAuthor]) {
        LOGGER(@"currentUser is Author. Returning");
        return [BFTask taskWithResult:@(NO)];
    }
    
    if(!self.relatedUsers)
        self.relatedUsers = [[NSMutableArray alloc] init];
    
    if ([self relatedUsersContainsCurrentUser]) {
        LOGGER(@"currentUser is already in the relatedUsers from NewsFeed. Returning");
        return [BFTask taskWithResult:@(NO)];
    }
    
    LOGGER(@"Adding currentUser to relatedUsers from NewsFeed");
    [self.relatedUsers addObject:user.objectId];
    
    NSMutableDictionary *data = [self getCloudData:@{
                                                     @"keys": @[@"relatedUsers"],
                                                     @"relatedUsers": self.relatedUsers
                                                     }];
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async(dispatch_get_main_queue(), ^{
        [source setResult:[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data]];
    });
    return source.task;
}

- (NSMutableDictionary *)getCloudData:(NSDictionary *)extra {
    User *user = [User currentUser];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"currentUser"] = user.objectId;
    dict[@"objectId"] = self.objectId;
    [dict addEntriesFromDictionary:extra];
    
    return dict;
}





// Like Notification


// Comment Notification
- (void)sendPushNotificationWithComment:(Comment *)comment except:(NSMutableArray<User *> *)mentionUsers {
    [self addCurrentUserToRelevantUserList];
    
    if ([self currentUserIsAuthor] == NO) {
        [self sendPushNotificationToUser:self.authorPointer usingComment:comment];
    }
    
    // Do this to prevent having to make an extra query
    if ([self relatedUsersContainsOnlyTheCurrentUser]) {
        LOGGER(@"relatedUsers ONLY contains currentUser. Returning!");
        return;
    }
    [[self getRelatedUsers] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if(task.error) {
            LOGGER(@"sketchyness happened while acquiring list of users to send notifications to");
            return nil;
        }
        
        NSMutableArray<User *> *users = [task.result mutableCopy];
        if(mentionUsers) {
            for(User *mUser in mentionUsers)
                for(User *aUser in users)
                    if([aUser.objectId isEqualToString:mUser.objectId]) {
                        [users removeObject:aUser];
                        break;
                    }
        }
        
        for (User *user in users) {
            if (![user isTheCurrentUser]) {
                if(!comment) {
                    [[self notificationObjectExistsForUser:user] continueWithBlock:^id(BFTask *task) {
                        if([task.result integerValue] == 0)
                            [self sendPushNotificationToUser:user usingComment:comment];
                        
                        return nil;
                    }];
                } else {
                    [self sendPushNotificationToUser:user usingComment:comment];
                }
            }
        }
        return nil;
    }];
}

- (void)sendPushNotificationToUser:(User *)user usingComment:(Comment *)comment {
    NSString *message = !comment ? [self getToastPushNotificationMessageForUser:user] : [self getCommentPushNotificationMessageForUser:user];
    NotificationType type = !comment ? NotificationTypeToast : NotificationTypeComment;
    
    [[[Push sendPushNotification:type toUser:user withMessage:message] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            LOGGER(@"Something happened sending a Push Notification");
            LOGGER(task.error);
        } else {
            LOGGER(@"Push Notification sent to User");
            NSLog(@"NewsFeed objectId - %@", [user objectId]);
        }
        
        // Create notification object, unless
        return [Notification createNotificationObjectFor:self usingComment:comment andUser:user];
    }] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            LOGGER(@"Something happened sending a push Notification");
            LOGGER(task.error);
        } else {
            LOGGER(@"Notification object created for User");
        }
        
        return nil;
    }];
}

- (BOOL)isMeritType {
    return ([self.Type isEqualToString:@"Merit"] && self.meritPointer);
}

- (BOOL)isWineType {
    return ([self.Type isEqualToString:@"Wine"] && self.unWinePointer);
}

- (NSString *)getMeritName {
    return self.meritPointer.name;
}

- (NSString *)getWineName {
    return [self.unWinePointer getWineName];
}


// Utility Stuff
- (NSString *)getToastPushNotificationMessageForUser:(User *)user {
    
    NSString *message = @"";
    if ([self userIsEqualToAuthor:user]) {
        message = [NSString stringWithFormat:@"%@ toasted your %@", [[User currentUser] getName], self.Type];
    } else {
        message = [NSString stringWithFormat:@"%@ toasted %@'s %@", [[User currentUser] getName], [self getAuthorName], self.Type];
    }
    
    return message;
}

- (NSString *)getCommentPushNotificationMessageForUser:(User *)user {
    
    NSString *message = @"";
    if ([self userIsEqualToAuthor:user]) {
        message = [NSString stringWithFormat:@"%@ commented on your %@", [[User currentUser] getName], self.Type];
    } else {
        message = [NSString stringWithFormat:@"%@ commented on %@'s %@", [[User currentUser] getName], [self getAuthorName], self.Type];
    }
    
    return message;
}

- (NSArray *)getToasters {
    if(!self.toasters)
        self.toasters = [[NSMutableArray alloc] init];
    
    return self.toasters;
}

- (BFTask *)addToaster:(User *)user {
    if(!user)
        return [BFTask taskWithResult:@(NO)];
    
    self.toasters = [[NSMutableArray alloc] initWithArray:self.toasters];
    if(![self.toasters containsObject:[user objectId]]) {
        [self.toasters addObject:[user objectId]];
        self.Likes = self.Likes + 1;
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"toasters", @"Likes"],
                                                         @"toasters": self.toasters,
                                                         @"Likes": @(self.Likes)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data]];
        });
        return source.task;
    }
    
    return [BFTask taskWithResult:@(NO)];
}

- (BFTask *)removeToaster:(User *)user {
    if(!user)
        return nil;
    
    return [self removeToasterId:[user objectId]];
}

- (BFTask *)removeToasterId:(NSString *)objectId {
    if(!self.toasters)
        return nil;
    
    self.toasters = [[NSMutableArray alloc] initWithArray:self.toasters];
    if([self.toasters containsObject:objectId]) {
        [self.toasters removeObject:objectId];
        self.Likes = self.Likes - 1;
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"toasters", @"Likes"],
                                                         @"toasters": self.toasters,
                                                         @"Likes": @(self.Likes)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data]];
        });
        return source.task;
    }
    
    return [BFTask taskWithResult:@(NO)];
}

- (BOOL)shouldUpdateToastCount {
    return self.toasters == nil || self.Likes != [self.toasters count];
}

- (BFTask *)updateToastCount {
    PFQuery *query = [User query];
    [query whereKey:@"Likes" containsAllObjectsInArray:@[self.objectId]];
    
    return [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
        NSArray *result = task.result;
        for(User *user in result)
            [self addToaster:user];
        
        self.Likes = [result count];
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"Likes"],
                                                         @"Likes": @(self.Likes)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data] continueWithBlock:^id _Nullable(BFTask<id> * _Nonnull task) {
                return [BFTask taskWithResult:@(YES)];
            }]];
        });
        return source.task;
    }];
}

- (BFTask *)updateToastCountIfNecessary {
    if(!self.toasters)
        self.toasters = [[NSMutableArray alloc] init];
    else
        self.toasters = [[NSMutableArray alloc] initWithArray:self.toasters];
    
    if(!self.Likes)
        self.Likes = 0;
    
    if([self shouldUpdateToastCount])
        return [self updateToastCount];
    else
        return [BFTask taskWithResult:@(NO)];
}

- (NSArray *)getCommentIds {
    if(!self.commentIds)
        self.commentIds = [[NSMutableArray alloc] init];
    else
        self.commentIds = [[NSMutableArray alloc] initWithArray:self.commentIds];
    
    return self.commentIds;
}

- (BFTask *)addComment:(Comment *)comment {
    if(!comment || [comment isKindOfClass:[NSNull class]])
        return [BFTask taskWithResult:@(NO)];
    
    self.commentIds = [[NSMutableArray alloc] initWithArray:self.commentIds];
    
    if(![self.commentIds containsObject:[comment objectId]]) {
        [self.commentIds addObject:[comment objectId]];
        self.Comments = self.Comments + 1;
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"commentIds", @"Comments"],
                                                         @"commentIds": self.commentIds,
                                                         @"Comments": @(self.Comments)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data]];
        });
        return source.task;
    }
    
    return [BFTask taskWithResult:@(NO)];
}

- (BFTask *)removeComment:(Comment *)comment {
    if(!comment || [comment isKindOfClass:[NSNull class]] || !self.commentIds || [self.commentIds count] == 0)
        return nil;
    
    return [self removeCommentId:[comment objectId]];
}
    
- (BFTask *)removeCommentId:(NSString *)objectId {
    self.commentIds = [[NSMutableArray alloc] initWithArray:self.commentIds];
    
    if([self.commentIds containsObject:objectId]) {
        [self.commentIds removeObject:objectId];
        self.Comments = self.Comments - 1;
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"commentIds", @"Comments"],
                                                         @"commentIds": self.commentIds,
                                                         @"Comments": @(self.Comments)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data]];
        });
        return source.task;
    }
    
    return [BFTask taskWithResult:@(NO)];
}

- (BOOL)shouldUpdateCommentCount {
    return self.commentIds == nil || self.Comments != [self.commentIds count];
}

- (BFTask *)updateCommentCount {
    PFQuery *commentQuery = [Comment query];
    [commentQuery whereKey:@"NewsFeed" equalTo:self.objectId];
    [commentQuery whereKey:@"hidden" notEqualTo:@(YES)];
    
    return [[commentQuery findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
        NSArray *result = task.result;
        for(Comment *comment in result)
            if(comment && ![comment isKindOfClass:[NSNull class]])
                [self addComment:comment];
        
        self.Comments = [result count];
        
        NSMutableDictionary *data = [self getCloudData:@{
                                                         @"keys": @[@"Comments"],
                                                         @"Comments": @(self.Comments)
                                                         }];
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:[[PFCloud callFunctionInBackground:@"saveNewsfeed" withParameters:data] continueWithBlock:^id _Nullable(BFTask<id> * _Nonnull task) {
                return [BFTask taskWithResult:@(YES)];
            }]];
        });
        return source.task;
    }];
}

- (BFTask *)updateCommentCountIfNecessary {
    if(!self.commentIds)
        self.commentIds = [[NSMutableArray alloc] init];
    else
        self.commentIds = [[NSMutableArray alloc] initWithArray:self.commentIds];
    
    if(!self.Comments)
        self.Comments = 0;
    
    if([self shouldUpdateCommentCount])
        return [self updateCommentCount];
    else
        return [BFTask taskWithResult:@(NO)];
}

+ (BFTask *)wineCheckinsForUser:(User *)user {
    PFQuery *query = [NewsFeed query];
    [query whereKey:@"authorPointer" equalTo:user];
    [query whereKey:@"Type" equalTo:@"Wine"];
    [query includeKey:@"authorPointer"];
    [query includeKey:@"authorPointer.level"];
    [query includeKey:@"unWinePointer"];
    [query includeKey:@"unWinePointer.partner"];
    [query includeKey:@"venue"];
    
    [query orderByDescending:@"createdAt"];
    [query setLimit:1000];
    
    return [query findObjectsInBackground];
}

/*- (void)updateWith:(NewsFeed *)object {
    for(NSString *key in [object allKeys]) {
        id obj = [object objectForKey:key];
        if(![obj isKindOfClass:[PFRelation class]] && ![obj isKindOfClass:[PFObject class]])
            [self setValue:obj forKey:key];
    }
}*/

- (ReactionType)getReaction {
    if([self objectForKey:@"reactionType"] == nil || [self.reactionType isKindOfClass:[NSNull class]])
        self.reactionType = @(ReactionType0None);
    
    return (ReactionType)[self.reactionType integerValue];
}

- (ReactionObject *)getReactionObject {
    return [Reaction getReactionObject:[self getReaction]];
}

- (BOOL)hasPhoto {
    return self.photo && ![self.photo isKindOfClass:[NSNull class]];
}

- (BOOL)hasWinePhoto {
    return self.unWinePointer && ![self.unWinePointer isKindOfClass:[NSNull class]] && self.unWinePointer.image && ![self.unWinePointer.image isKindOfClass:[NSNull class]];
}

- (BOOL)hasCaption {
    return self.caption != nil && [self.caption count] > 0;// && [[self.caption objectAtIndex:0] length] > 0;
}

+ (NSString *)getFormattedUserForCaption:(User *)user {
    return [NSString stringWithFormat:@"user:%@/%@", [user objectId], [user getMentionName:NO]];
}

- (NSMutableAttributedString *)getFormattedCaption:(UIColor *)color {
    return self.caption != nil ? [NewsFeed getFormattedCaption:self.caption color:color] : nil;
}

+ (NSMutableAttributedString *)getFormattedCaption:(NSArray *)pieces color:(UIColor *)color {
    NSMutableAttributedString *total = [[NSMutableAttributedString alloc] init];
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:14];
    for(NSInteger i = 0; i < [pieces count]; i++) {
        //if(i > 0)
        //    [total appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        NSString *piece = [pieces objectAtIndex:i];
        if([piece hasPrefix:@"user:"]) {
            NSArray *parts = [[piece stringByReplacingOccurrencesOfString:@"user:" withString:@""] componentsSeparatedByString:@"/"];
            NSString *objectId = parts[0];
            NSString *displayName = [parts[1] hasPrefix:@"@"] ? parts[1] : [NSString stringWithFormat:@"@%@", parts[1]];
            NSURL *deepLink = [NSURL URLWithString:[NSString stringWithFormat:@"unwineapp://user/%@", objectId]];
            
            NSMutableAttributedString *form = [[NSMutableAttributedString alloc] initWithString:displayName];
            
            [form addAttributes:@{NSForegroundColorAttributeName: UNWINE_RED,
                                  NSBackgroundColorAttributeName: [UIColor whiteColor],
                                  NSFontAttributeName: font,
                                  NSLinkAttributeName: deepLink}
                          range:NSMakeRange(0, displayName.length)];
            
            [total appendAttributedString:form];
        } else if([piece hasPrefix:@"wine:"]) {
            NSString *objectId = [piece stringByReplacingOccurrencesOfString:@"wine:" withString:@""];
            NSURL *deepLink = [NSURL URLWithString:[NSString stringWithFormat:@"unwineapp://wine/%@", objectId]];
            
            NSMutableAttributedString *form = [[NSMutableAttributedString alloc] initWithString:piece];
            
            [form addAttributes:@{NSForegroundColorAttributeName: UNWINE_RED,
                                  NSBackgroundColorAttributeName: [UIColor whiteColor],
                                  NSFontAttributeName: font,
                                  NSLinkAttributeName: deepLink}
                          range:NSMakeRange(0, piece.length)];
            
            [total appendAttributedString:form];
        } else if([piece hasPrefix:@"http://"] || [piece hasPrefix:@"https://"]) {
            NSURL *deepLink = [NSURL URLWithString:[NSString stringWithFormat:@"%@", piece]];
            
            NSMutableAttributedString *form = [[NSMutableAttributedString alloc] initWithString:piece];
            
            [form addAttributes:@{NSForegroundColorAttributeName: UNWINE_RED,
                                  NSBackgroundColorAttributeName: [UIColor whiteColor],
                                  NSFontAttributeName: font,
                                  NSLinkAttributeName: deepLink}
                          range:NSMakeRange(0, piece.length)];
            
            [total appendAttributedString:form];
        } else {
            NSMutableAttributedString *form = [[NSMutableAttributedString alloc] initWithString:piece];
            
            [form addAttributes:@{NSForegroundColorAttributeName: color,
                                  NSFontAttributeName: font}
                          range:NSMakeRange(0, piece.length)];
            
            [total appendAttributedString:form];
        }
    }
    
    return total;
}

+ (NSString *)trimEnd:(NSString *)string {
    NSInteger i;
    for (i = [string length]; i > 0; i--) {
        unichar c = [string characterAtIndex:(i - 1)];
        if(![[NSCharacterSet whitespaceCharacterSet] characterIsMember:c])
            break;
    }
    
    return [string substringWithRange:NSMakeRange(0, i)];
}

+ (NSArray *)makeRawCaption:(NSString *)text mentions:(NSArray<MentionObject *> *)mentions {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSString *raw = [NewsFeed trimEnd:text]; //[[NSString stringWithFormat:@"%@", text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(mentions == nil || [mentions count] == 0) {
        [ret addObject:raw];
        return ret;
    }
    
    mentions = [mentions sortedArrayUsingSelector:@selector(compare:)];
    
    NSRange fullRange = NSMakeRange(0, [raw length]);
    NSLog(@"fullRange - %@", NSStringFromRange(fullRange));
    
    NSUInteger cursor = 0;
    for(MentionObject *object in mentions) {
        //NSLog(@"range: %@", NSStringFromRange(object.range));
        if([object isContainedInRange:fullRange]) {
            NSString *formattedUser = [NewsFeed getFormattedUserForCaption:object.user];
            NSInteger len = object.range.location - cursor;
            if(len > 0)
                [ret addObject:[raw substringWithRange:NSMakeRange(cursor, len)]];
            cursor = object.range.location + object.range.length;
            [ret addObject:formattedUser];
        } else {
            LOGGER(@"sketchy stuff happened when parsing for mentions");
        }
    }
    NSInteger check = [raw length] - cursor;
    if(check > 0)
        [ret addObject:[raw substringWithRange:NSMakeRange(cursor, check)]];
    LOGGER(ret);
    
    return ret;
}

- (NSString *)getShareURL {
    LOGGER(@"Getting the latest config for IOS_APP_STORE_URL...");
    PFConfig *config = [PFConfig currentConfig];
    return config[@"IOS_APP_STORE_URL"];
}

- (NSDictionary *)getShareContent {
    UIImage *img = nil;
    if (self.photo) {
        img = [UIImage imageWithData:[self.photo getData]];
    } else {
        img = [self.unWinePointer getImage];
    }
    
    NSString *caption = [NSString stringWithFormat:
                         @"%@ just checked in with the \"%@\" wine on the unWine app!\n\n%@",
                         [self.authorPointer getFirstName],
                         [self.unWinePointer getWineName],
                         [self getShareURL]];
    
    return @{@"image": img, @"caption": caption};
}

- (UIImage *)getShareImage {
    return [self getShareContent][@"image"];
}

- (NSString *)getShareCaption {
    return [self getShareContent][@"caption"];
}

+ (NSArray *)getNewsfeedObjectsWithReactionType:(ReactionType)type fromArray:(NSArray *)array {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    for (NewsFeed *nf in array) {
        if (nf.reactionType.intValue == type) {
            [filtered addObject:nf];
        }
    }
    return [filtered mutableCopy];
}

- (BFTask *)finishSavingCheckinWithExpress:(BOOL)express {
    self.authorPointer = [User currentUser];
    self.localDate = [NSDate getCurrentDateString];
    self.express = express;
    
    NSString *s = [NSString stringWithFormat: @"Saving checkin %@", self];
    LOGGER(s);
    return [self saveInBackground];
}

- (BFTask *)saveImage:(UIImage *)image andDimensions:(NSMutableArray *)photoDimentions withProgressBlock:(PFProgressBlock)progressBlock {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSData *imageData = UIImageJPEGRepresentation(image, .3);
    PFFile *imageFile = [PFFile fileWithName:@"checkin_photo.jpg" data:imageData];
    
    if(imageFile == nil || imageData == nil || image == nil) {
        LOGGER(@"Image expected. Got nothing");
        NSString *message = @"Expected image";
        NSError *error = [unWineError createGenericErrorWithMessage:message];
        return [BFTask taskWithError:error];
    }
    
    LOGGER(@"Saving image");
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            LOGGER(@"Error saving checkin image");
            [theTask setError:error];
            return;
        }
        
        LOGGER(@"Saved checkin image. Now setting it to NewsFeed object");
        self.photo = imageFile;
        self.photoDims = photoDimentions;
        
        [[self saveInBackground] continueWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
            if (t.error) {
                LOGGER(@"Something happened setting PFFile to NewsFeed");
                LOGGER(t.error);
                [theTask setError:t.error];
                
            } else {
                LOGGER(@"Finished setting PFFile to NewsFeed");
                [theTask setResult:t.result];
            }
            return nil;
        }];
        
        
    } progressBlock: progressBlock];
    
    return theTask.task;
}

+ (NSArray *)arrayFromSize:(CGSize)size {
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:size.width], [NSNumber numberWithInt:size.height], nil];
}


- (BFTask *)finalCheckinWithImage:(UIImage *)newsFeedImage
                             wine:(unWine *)wine
                        wineImage:(UIImage *)wineImage
                        registers:(NSDictionary *)registers
                            venue:(Venue *)venue
                         mentions:(NSArray *)mentions
                          express:(BOOL)express
                 andProgressBlock:(PFProgressBlock)progressBlock {
    
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block User *user = [User currentUser];
    
    BFTask *imageTask = nil;
    
    if (newsFeedImage == nil) {
        LOGGER(@"No photo to save");
        imageTask = [BFTask taskWithResult:@(true)];
    } else {
        LOGGER(@"Saving image");
        imageTask = [self saveImage:newsFeedImage
                              andDimensions:[NewsFeed arrayFromSize:newsFeedImage.size].mutableCopy
                          withProgressBlock:progressBlock];
    }
    
    [[[[[[[[[imageTask continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Done saving image");
        LOGGER(@"Creating Wine Records");
        return [wine createRecordsAndSaveWineWithRegisters:registers];

    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Saving final checkin info");
        return [self finishSavingCheckinWithExpress:express];
        
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Saving reaction and photoDims to wine");
        wine.photoDims = [NewsFeed arrayFromSize:wineImage.size].mutableCopy;
        wine.userGeneratedFlag = true;
        // checkin count will be updated via Cloud Code after checkin is saved
        //[wine incrementKey:@"checkinCount"];
        
        if([self.reactionType integerValue] != ReactionType0None) {
            LOGGER(@"Adding Non-0 Reaction");
            [wine addCheckinReaction:self];
        }
        
        return [wine saveInBackground];
        
    }] continueWithSuccessBlock:^id(BFTask *task) {
        LOGGER(@"Updating super user status");
        return [user updateSuperUserStatus];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Saving venue stuff");
        
        if (!venue || (venue && [venue isKindOfClass:[NSNull class]])) {
            LOGGER(@"No venue stuff to save");
            return [BFTask taskWithResult:@(YES)]; //Fodder to pass into the next block
        }
        
        return venue.isDirty ? [venue saveInBackground] : [BFTask taskWithResult:@(true)];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull task) {
        LOGGER(@"Saving locations and recent checkins for user");
        PFRelation *locations = user.locations;
        if (venue != nil) {
            LOGGER(@"Adding venue");
            [locations addObject:venue];
        }
        
        PFRelation *checkins = user.checkins;
        [checkins addObject:self];
        
        [user addRecentCheckinsObject:wine.objectId];
        
        return [user saveInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Sending mention notifications");
        
        return [Notification sendMentionNotificationsFromMentions:mentions forCheckin:self atCheckin:YES];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Sending checkin notification to friends");
        
        NSMutableArray<User *> *mentionUsers = [[NSMutableArray alloc] init];
        
        for(MentionObject *object in mentions)
            [mentionUsers addObject:object.user];
        
        return [Notification sendCheckinNotificationsToFriendsExcept:mentionUsers forCheckin:self andWine:wine];
        
    }] continueWithBlock:^id(BFTask *task) {
        LOGGER(@"Finished Checkin in");
        
        if (task.error) {
            LOGGER(@"Something happened");
            LOGGER(task.error);
            [theTask setError:task.error];
            
        } else {
            [theTask setResult:@(true)];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

/*
 // Potential video one
- (BFTask *)saveImage:(UIImage *)image andDimensions:(NSMutableArray *)photoDimentions withProgressBlock:(PFProgressBlock)progressBlock {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSData *imageData = UIImageJPEGRepresentation(image, .3);
    PFFile *imageFile = [PFFile fileWithName:@"checkin_photo.jpg" data:imageData];
    
    if(imageFile == nil || imageData == nil || image == nil) {
        LOGGER(@"Image expected. Got nothing");
        NSString *message = @"Expected image";
        NSError *error = [unWineError createGenericErrorWithMessage:message];
        return [BFTask taskWithError:error];
    }
    
    LOGGER(@"Saving image");
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            LOGGER(@"Error saving checkin image");
            [Analytics trackError:error withName:@"Saving checkin image" withMessage:@"Something happened"];
            [theTask setError:error];
            return;
        }
        
        LOGGER(@"Saved checkin image. Now setting it to NewsFeed object");
        self.photo = imageFile;
        self.photoDims = photoDimentions;
        
        [[self saveInBackground] continueWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
            if (t.error) {
                LOGGER(@"Something happened setting PFFile to NewsFeed");
                LOGGER(t.error);
                [theTask setError:t.error];
                
            } else {
                LOGGER(@"Finished setting PFFile to NewsFeed");
                [theTask setResult:t.result];
            }
            return nil;
        }];
        
        
    } progressBlock: progressBlock];
    
    return theTask.task;
}*/

@end

@implementation MentionObject

+ (instancetype)user:(User *)user range:(NSRange)range {
    MentionObject *obj = [[MentionObject alloc] init];
    obj.user = user;
    obj.range = range;
    return obj;
}

- (BOOL)doesIntersectRange:(NSRange)range {
    NSRange intersect = NSIntersectionRange(self.range, range);
    return intersect.length > 0;
}

- (BOOL)isContainedInRange:(NSRange)range {
    NSInteger len = range.location + range.length;
    NSRange intersect = NSUnionRange(self.range, range);
    return intersect.length >= len;
}

- (BOOL)isRangeEqual:(NSRange)range {
    return NSEqualRanges(self.range, range);
}

- (NSComparisonResult)compare:(MentionObject *)other {
    return [@(self.range.location) compare:@(other.range.location)];
}

@end
