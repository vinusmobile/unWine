//
//  CommentVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "CommentVC.h"
#import "MentionTVC.h"

@interface CommentVC () <MentionTVCDelegate, MentionInputDelegate>

@end

@implementation CommentVC {
    NSMutableArray *rawCaption;
}
@synthesize mention, realInputView, keyboardHeight, mentionIndicator, input;

- (instancetype)initWithNewsFeed:(NewsFeed *)newsfeed {
    self = [super init];
    if (self) {
        self.messenger = self.commenter = [[CommentTVC alloc] initWithStyle:UITableViewStyleGrouped];
        self.commenter.newsfeed = self.newsfeed = newsfeed;
        self.commenter.parent = self;
        self.tableView = self.commenter.tableView;
        [self addChildViewController:self.commenter];
        [self.view addSubview:self.commenter.view];
        [self.commenter didMoveToParentViewController:self];
        self.input = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    keyboardHeight = 0;
    [MentionTVC setupMentionsView:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self.headerView removeFromSuperview];
    
    [self.commenter.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.view) - HEIGHT(self.composeBarView))];
    [self.composeBarView setFrame:CGRectMake(0, HEIGHT(self.view) - PHFComposeBarViewInitialHeight, SCREEN_WIDTH, PHFComposeBarViewInitialHeight)];
    
    [self.view bringSubviewToFront:self.composeBarView];
    self.realInputView = self.composeBarView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideMentions];
    [self.realInputView resignFirstResponder];
}

- (void)presentComposeBarView {
    if(![self.realInputView isFirstResponder] && [self.realInputView canBecomeFirstResponder])
        [self.realInputView becomeFirstResponder];
}

- (void)activeReload {
    self.commenter.loadQuietly = YES;
    [self.commenter loadObjects];
}

- (void)sendMessage:(NSString *)text {
    LOGGER(text);
    rawCaption = [[NewsFeed makeRawCaption:text mentions:self.mention.mentions] mutableCopy];
    
    Comment *comment = [Comment object];
    comment.Author = [User currentUser];
    comment.NewsFeed = self.newsfeed.objectId;
    comment.Comment = text;
    comment.caption = rawCaption;
    comment.hidden = NO;
    
    __block NSMutableArray<User *> *mentionUsers = [[NSMutableArray alloc] init];
    for(MentionObject *object in self.mention.mentions)
        [mentionUsers addObject:object.user];
    
    [Notification sendMentionNotificationsFromMentions:self.mention.mentions forCheckin:self.newsfeed atCheckin:NO];
    [self.mention.mentions removeAllObjects];
    
    [[[[comment saveInBackground] continueWithBlock:^id(BFTask *task) {
        LOGGER(@"Saved - Updating Comment Count");
        return [self.newsfeed updateCommentCountIfNecessary];
    }] continueWithBlock:^id(BFTask<NSNumber *> *task) {
        LOGGER(@"Updated - Adding Comment to Checkin");
        NSLog(@"commentId - %@", [comment objectId]);
        return [self.newsfeed addComment:comment];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask<NSNumber *> *task) {
        LOGGER(@"Added - Reloading");
        if (!task.error) {
            [self activeReload];
            [self sendNotifications:comment except:mentionUsers];
        } else {
            [unWineAlertView showAlertViewWithTitle:nil error:task.error];
        }
        
        return nil;
    }];
}

- (void)sendNotifications:(Comment *)comment except:(NSMutableArray *)mentionUsers {
    [self.newsfeed addCurrentUserToRelevantUserList];
    [self.newsfeed sendPushNotificationWithComment:comment except:mentionUsers];
}

- (PHFComposeBarView *)makeComposeBarView:(BOOL)hasInputView {
    PHFComposeBarView *composeBarView = [super makeComposeBarView:hasInputView];
    
    [composeBarView.textView setKeyboardType:UIKeyboardTypeTwitter];
    composeBarView.textView.returnKeyType = UIReturnKeyDone;
    
    return composeBarView;
}

- (void)addCaption:(NSString *)caption mentions:(NSMutableArray<MentionObject *> *)_mentions {
    rawCaption = [[NewsFeed makeRawCaption:caption mentions:_mentions] mutableCopy];
}


- (void)showMentions:(CGFloat)offset {
    if(self.mention)
        [self.mention showMentions:offset];
}

- (void)hideMentions {
    if(self.mention) {
        [self.mention.tableView removeFromSuperview];
        [self.mention hideMentions];
    }
}

- (UITableView *)getTableView {
    return self.tableView;
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame {
    [super composeBarView:composeBarView didChangeFromFrame:startFrame toFrame:endFrame];
    
    if(self.mention && self.mention.isShowingMentions)
        [self.mention showMentions:HEIGHT(self.realInputView) + self.keyboardHeight];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    [super composeBarViewDidPressButton:composeBarView];
    [composeBarView resignFirstResponder];
    [realInputView resignFirstResponder];
    
    [self.mention updateMentionView:self text:composeBarView.text];
    rawCaption = [[NewsFeed makeRawCaption:composeBarView.text mentions:self.mention.mentions] mutableCopy];
    
    [self hideMentions];
}


- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.mention didChangeSelection:self];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    keyboardHeight = keyboardSize.height; // - PHFComposeBarViewInitialHeight;
    //NSLog(@"keyboardWasShown %li", keyboardHeight);
}

@end
