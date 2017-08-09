//
//  MentionTVC.m
//  unWine
//
//  Created by Bryce Boesen on 12/4/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "MentionTVC.h"

@interface MentionTVC ()

@property (nonatomic, strong) NSArray<User *> *objects;
@property (nonatomic) NSRange tempRange;

@end

@implementation MentionTVC {
    NSMutableArray<User *> *users;
    NSString *searchString;
    BFTask *expectedTask;
    UIView *noFriendsView;
}

+ (void)setupMentionsView:(UIViewController<MentionTVCDelegate> *)delegate {
    delegate.mention = [[MentionTVC alloc] initWithStyle:UITableViewStylePlain];
    delegate.mention.delegate = delegate;
    delegate.mention.mentions = [[NSMutableArray alloc] init];
    delegate.mention.view.alpha = 0;
    delegate.mention.view.backgroundColor = [UIColor whiteColor];
    delegate.mention.view.layer.borderWidth = .5;
    delegate.mention.view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    delegate.mention.tempRange = NSMakeRange(0, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadObjects {
    LOGGER(@"getting friends for mentions");
    User *user = [User currentUser];
    [[user getFriends] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
        }
        [UserCell setFriends:task.result];
        
        users = [[NSMutableArray alloc] init];
        for(Friendship *ship in task.result)
            [users addObject:[ship getTheFriend:user]];
        self.objects = users;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self mentionDidLoad];
        });
        
        return nil;
    }];
}

#pragma No Friends View

static NSString *ummFace = @"😳";

- (void)showNoFriendsView {
    if(!noFriendsView) {
        noFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view))];
        noFriendsView.backgroundColor = [UIColor whiteColor];
        
        NSInteger y = 60;
        UILabel *faceLabel = [[UILabel alloc] initWithFrame:(CGRect){0, y, {SCREEN_WIDTH, 64}}];
        [faceLabel setText:ummFace];
        [faceLabel setTextAlignment:NSTextAlignmentCenter];
        [faceLabel setFont:[UIFont fontWithName:@"OpenSans" size:48]];
        [noFriendsView addSubview:faceLabel];
        
        UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:(CGRect){12, Y2(faceLabel) + HEIGHT(faceLabel) - 10, {SCREEN_WIDTH - 24, 80}}];
        [noResultsLabel setText:[NSString stringWithFormat:@"Looks like you haven't added any friends yet. Keep typing to search unWiners for mentioning!"]];
        [noResultsLabel setTextAlignment:NSTextAlignmentCenter];
        [noResultsLabel setTextColor:[UIColor blackColor]];
        [noResultsLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        noResultsLabel.numberOfLines = 0;
        noResultsLabel.tag = 10;
        [noFriendsView addSubview:noResultsLabel];
    }
    
    if(![noFriendsView superview])
        [self.view addSubview:noFriendsView];
    [self.view bringSubviewToFront:noFriendsView];
}

- (void)hideNoFriendsView {
    if(noFriendsView && [noFriendsView superview])
        [noFriendsView removeFromSuperview];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UserCell getDefaultHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.objects) {
        NSInteger count = [self.objects count];
        if(count == 0)
            [self showNoFriendsView];
        else
            [self hideNoFriendsView];
        return count;
    } else {
        [self showNoFriendsView];
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.delegate = self;
    cell.singleTheme = unWineThemeLight;
    
    if([self.objects count] > indexPath.row) {
        User *user = [self.objects objectAtIndex:indexPath.row];
        
        [cell setup:indexPath];
        [cell configure:user];
        
        return cell;
    } else {
        return [[UITableViewCell alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.objects objectAtIndex:indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(mentionedUser:)])
        [self.delegate mentionedUser:user];
    
    [self hideMentions];
    [self addMention:self.delegate.input user:user];
    self.objects = users;
    
    //[self updateMentionView:self.delegate.input text:[self getRealInputView].text];
}

- (void)mentionDidLoad {
    if(self.view.tag == 1) {
        LOGGER(@"showing mentions");
        [UIView animateWithDuration:.1 animations:^{
            [self.view setAlpha:1];
        } completion:^(BOOL finished) {
            [[self.delegate getTableView] setExclusiveTouch:NO];
            [[self.delegate getTableView] setScrollEnabled:NO];
        }];
    }
}

- (void)showMentions:(CGFloat)offset {
    CGFloat mentionWidth = WIDTH(self.delegate.view);
    if(self.isShowingMentions) {
        [self.view setFrame:(CGRect){0, 64, {mentionWidth, SCREENHEIGHT - 64 - offset}}];
        [self.view setAlpha:1];
        return;
    }
    
    if(![self.tableView superview])
        [self.delegate.navigationController.view addSubview:self.tableView];
    
    self.isShowingMentions = YES;
    
    //UITextView *textView = self.delegate.input.realInputView.textView;
    //NSString *text = [NSString stringWithFormat:@"%@", textView.text];
    if([self getSelectedRange].location - 1 == self.delegate.mentionIndicator.location)
        self.objects = users;
    
    [self.view setFrame:(CGRect){0, 64, {mentionWidth, SCREENHEIGHT - 64 - offset}}];
    self.view.tag = 1;
    [self.view setAlpha:1];
    
    expectedTask = nil;
    [self loadObjects];
    
    //[UIView animateWithDuration:.2 animations:^{
    //}];
}

- (void)hideMentions {
    self.isShowingMentions = NO;
    
    [[self.delegate getTableView] setScrollEnabled:YES];
    if(self.view.tag == 1) {
        self.view.tag = 0;
        //[UIView animateWithDuration:.1 animations:^{
            [self.view setAlpha:0];
        //}];
    }
}

- (void)unhide {
    [self.view setAlpha:1];
}

- (void)hideTemporarily {
    [self.view setAlpha:0];
}

- (void)addMention:(id<MentionInputDelegate>)delegate user:(User *)user {
    NSString *text = [NSString stringWithFormat:@"%@", delegate.realInputView.text];
    
    NSLog(@"mentionIndicator - %@", NSStringFromRange(self.delegate.mentionIndicator));
    NSString *begin = [text substringToIndex:self.delegate.mentionIndicator.location]; //before and @
    NSLog(@"begin - %@", begin);
    NSString *mentionName = [user getMentionName:YES];
    NSLog(@"mentionName - %@", mentionName);
    NSString *end = [text substringFromIndex:[self getSelectedRange].location]; //after cursor
    NSLog(@"end - %@", end);

    NSString *front = [[begin stringByAppendingString:mentionName] stringByAppendingString:@" "];
    NSString *newText = [front stringByAppendingString:end];
    NSLog(@"newText - %@", newText);
    NSRange range = NSMakeRange([begin length], [mentionName length]);
    NSLog(@"mention range %@", NSStringFromRange(range));
    NSLog(@"substring: '%@'", [newText substringWithRange:range]);
    [self offsetMentions:range from:searchString to:[newText substringWithRange:range] shiftIndicator:NO];
    [self.mentions addObject:[MentionObject user:user range:range]];
    for(MentionObject *obj in self.mentions) {
        NSLog(@"MentionObject %@: %@", [obj.user getName], NSStringFromRange(obj.range));
    }
    
    self.tempRange = NSMakeRange([front length], 0);
    [delegate.realInputView setText:newText];
    [delegate.realInputView.textView setSelectedRange:self.tempRange];
    NSLog(@"tempRange %@", NSStringFromRange(self.tempRange));
    self.tempRange = NSMakeRange(0, 0);
    
    [delegate.realInputView textViewDidChange:delegate.realInputView.textView];
}

- (void)offsetMentions:(NSRange)range from:(NSString *)substring to:(NSString *)text shiftIndicator:(BOOL)shift {
    NSInteger offset = text.length - substring.length;
    for(MentionObject *mention in self.mentions) {
        if(mention.range.location >= range.location) {
            mention.range = NSMakeRange(mention.range.location + offset, mention.range.length);
        }
    }
    
    if(shift && ![text isEqualToString:@"@"] && self.delegate.mentionIndicator.location >= range.location) {
        NSLog(@"offsetMentions - from:%@, to:%@", substring, text);
        NSLog(@"offsetMentions - preRange %@", NSStringFromRange(self.delegate.mentionIndicator));
        self.delegate.mentionIndicator = NSMakeRange(self.delegate.mentionIndicator.location + offset, self.delegate.mentionIndicator.length);
        NSLog(@"offsetMentions - postRange %@", NSStringFromRange(self.delegate.mentionIndicator));
    }
}

- (BOOL)shouldShowMentions:(NSRange)range {
    BOOL should = YES;
    for(MentionObject *mention in self.mentions)
        if([mention doesIntersectRange:range]) {
            should = NO;
            break;
        }
    
    return should && [self getSelectedRange].length == 0;
}

- (BOOL)shouldModifyMentions:(id<MentionInputDelegate>)delegate range:(NSRange)range replacing:(NSString *)text {
    if(self.view.alpha == 1 && !self.isShowingMentions) {
        [self hideMentions];
    }
    
    UITextView *textView = delegate.realInputView.textView;
    NSString *substring = [textView.text substringWithRange:range]; //old stuff
    NSInteger len = [self getSelectedRange].length;
    NSRange intersectRange = NSMakeRange([self getSelectedRange].location, len == 0 ? 1 : len);
    
    BOOL response = YES;
    for(MentionObject *mention in self.mentions) {
        if([mention doesIntersectRange:range] || ([mention doesIntersectRange:intersectRange] && intersectRange.location != mention.range.location)) {
            if([mention isRangeEqual:range]) {
                [self.mentions removeObject:mention];
                response = YES;
                break;
            } else {
                [delegate.realInputView.textView setSelectedRange:mention.range];
                response = NO;
                break;
            }
        }
    }
    
    if(response) {
        if([text isEqualToString:@"@"])
            self.delegate.mentionIndicator = [self getCharRangeBeforeCursor];
        
        [self offsetMentions:range from:substring to:text shiftIndicator:YES];
        
        NSLog(@"shouldModifyMentions text - '%@'", text);
        NSLog(@"shouldModifyMentions substring - '%@'", substring);
        NSLog(@"shouldModifyMentions range - '%@'", NSStringFromRange(range));
        
        if(self.isShowingMentions) {
            if(([substring containsString:@"@"] && [self does:range intersectRange:self.delegate.mentionIndicator]) || [text isEqualToString:@" "])
                [self hideMentions];
        }
    }
    
    return response;
}

/*!
 * text = full text
 */
- (void)updateMentionView:(id<MentionInputDelegate>)delegate text:(NSString *)text {
    [self.delegate addCaption:text mentions:self.mentions];
    
    NSRange range = [self getCharRangeBeforeCursor];
    NSRange textRange = NSMakeRange(0, [text length]);
    NSLog(@"updateMentionView text - %@", text);
    NSLog(@"updateMentionView range - %@", NSStringFromRange(range));
    if(!self.isShowingMentions && [self does:range intersectRange:textRange] && [[text substringWithRange:[self getCharRangeBeforeCursor]] isEqualToString:@"@"]) {
        if([self getSelectedRange].length == 0)
            [self showMentions:HEIGHT(delegate.realInputView) + delegate.keyboardHeight];
    } else if(self.isShowingMentions && text.length > 0 && [text containsString:@"@"]) {
        if(![self shouldShowMentions:range] && [[text substringWithRange:range] isEqualToString:@"@"]) {
            self.delegate.mentionIndicator = range;
        }
        
        NSString *search = @"";
        
        NSInteger postIndicator = self.delegate.mentionIndicator.location + 1;
        NSInteger cursor = [self getSelectedRange].location;
        //NSLog(@"searchRange = %li > %li", cursor, postIndicator);
        if(cursor >= postIndicator) {
            NSRange searchRange = NSMakeRange(postIndicator, cursor - postIndicator);
            search = [text substringWithRange:searchRange];
        }
        
        if([search containsString:@" "] || [search containsString:@"@"]) {
            search = @"";
        }
        LOGGER(search);
        searchString = search;
        
        if(search.length > 0 && ![search isEqualToString:@"@"]) {
            /*if(self.objects != users) {
                self.objects = users;
                [self.tableView reloadData];
            }*/
            BFTask *task = [User findTask:search];
            expectedTask = task;
            [task continueWithBlock:^id(BFTask *task) {
                if(task != expectedTask)
                    return nil;
                
                if(task.error || [task.result count] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideTemporarily];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self unhide];
                        self.objects = task.result;
                        [self.tableView reloadData];
                    });
                }
                
                return nil;
            }];
        } else {
            [self unhide];
            if(self.objects != users) {
                self.objects = users;
                [self.tableView reloadData];
            }
        }
    } else {
        [self hideMentions];
    }
}

- (void)didChangeSelection:(id<MentionInputDelegate>)delegate {
    UITextView *textView = delegate.realInputView.textView;
    if((self.isShowingMentions && [self getSelectedRange].length > 1) ||
       [self getSelectedRange].location == 0) {
        [self hideMentions];
        return;
    }
    
    NSRange range = [self getCharRangeBeforeCursor];
    NSString *substring = [textView.text substringWithRange:range];
    if([substring isEqualToString:@"@"])
        self.delegate.mentionIndicator = range;
    
    if([substring isEqualToString:@"@"] && !self.isShowingMentions) {
        if([self shouldShowMentions:range])
            [self showMentions:HEIGHT(delegate.realInputView) + delegate.keyboardHeight];
    } else if(self.isShowingMentions) {
        if(range.location < self.delegate.mentionIndicator.location)
            [self hideMentions];
    }
}

- (NSRange)getCharRangeBeforeCursor {
    UITextView *textView = [self getRealInputView].textView;
    NSRange range = [self getSelectedRange];
    if(range.location > 0 && range.location + range.length <= [textView.text length])
        return NSMakeRange(range.location - 1, 1);
    else
        return NSMakeRange(0, 0);
}

- (NSRange)getSelectedRange {
    if(self.tempRange.location == 0 && self.tempRange.length == 0)
        return [self getRealInputView].textView.selectedRange;
    else
        return self.tempRange;
}

- (PHFComposeBarView *)getRealInputView {
    return self.delegate.input.realInputView;
}

- (void)reconfigureCells {
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[UserCell class]]) {
            UserCell *userCell = (UserCell *)cell;
            [userCell reconfigure];
        }
    }
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)does:(NSRange)range1 intersectRange:(NSRange)range2 {
    NSRange intersect = NSIntersectionRange(range1, range2);
    return intersect.length > 0;
}

@end
