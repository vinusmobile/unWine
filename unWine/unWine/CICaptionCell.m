//
//  CICaptionCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/27/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CICaptionCell.h"
#import "CastCheckinTVC.h"
#import "PHFComposeBarView.h"

@interface CICaptionCell () <UITableViewDelegate, PHFComposeBarViewDelegate>

@end

@implementation CICaptionCell {
    PHFComposeBarView *shadowView;
}
@synthesize delegate, hasSetup, myPath, wine, captionView;
@synthesize realInputView, keyboardHeight;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    myPath = indexPath;
    
    if(!hasSetup) {
        hasSetup = YES;
        keyboardHeight = 0;
        [self setMentions:[[NSMutableArray alloc] init]];
        
        captionView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        captionView.layer.cornerRadius = 6;
        captionView.layer.borderWidth = .5;
        captionView.backgroundColor = ALMOST_BLACK_2;
        captionView.text = @"";
        captionView.tintColor = UNWINE_RED;
        captionView.textColor = [UIColor whiteColor];
        captionView.placeholder = @"Add a caption or notes! You can use '@' to mention other unWiners!";
        captionView.placeholderColor = [UIColor colorWithWhite:1 alpha:1];
        captionView.delegate = self;
        captionView.editable = NO;
        [captionView setKeyboardType:UIKeyboardTypeTwitter];
        
        shadowView = [self makeComposeBarView];
        shadowView.textView.inputAccessoryView = realInputView = [self makeComposeBarView];
        shadowView.alpha = 0;
        [shadowView setFrame:captionView.frame];
        [self.contentView addSubview:shadowView];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showShadowView)];
        [captionView addGestureRecognizer:gesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
    }
}

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    keyboardHeight = keyboardSize.height - PHFComposeBarViewInitialHeight;
}

- (void)showShadowView {
    [shadowView becomeFirstResponder];
}

- (PHFComposeBarView *)makeComposeBarView {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, PHFComposeBarViewInitialHeight);
    PHFComposeBarView *composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    
    [composeBarView setMaxCharCount:CAPTION_CHAR_LIMIT];
    [composeBarView setMaxLinesCount:5];
    [composeBarView setPlaceholder:@"Type something..."];
    [composeBarView setDelegate:self];
    composeBarView.buttonTitle = @"Done";
    composeBarView.buttonTintColor = UNWINE_RED;
    composeBarView.tintColor = UNWINE_RED;
    //composeBarView set;
    
    [composeBarView.textView setKeyboardType:UIKeyboardTypeTwitter];
    composeBarView.textView.returnKeyType = UIReturnKeyDone;
    
    return composeBarView;
}

- (void)configure:(unWine *)wineObject {
    self.wine = wineObject;
}

- (NSMutableArray<MentionObject *> *)getMentions {
    return delegate.mention.mentions;
}

- (void)setMentions:(NSMutableArray<MentionObject *> *)_mentions {
    delegate.mention.mentions = _mentions;
}

// ComposeBarViewStuff
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame {
    
    if(self.delegate.mention && self.delegate.mention.isShowingMentions)
        [self.delegate.mention showMentions:HEIGHT(self.realInputView) + self.keyboardHeight];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    realInputView = composeBarView;
    
    [composeBarView resignFirstResponder];
    [shadowView resignFirstResponder];
    [realInputView resignFirstResponder];

    NSArray *rawCaption = [NewsFeed makeRawCaption:composeBarView.text mentions:[self getMentions]];
    LOGGER(rawCaption);
    self.captionView.attributedText = [NewsFeed getFormattedCaption:rawCaption color:[UIColor whiteColor]];
    [self.delegate.mention updateMentionView:self text:composeBarView.text];
    [self.delegate hideMentions];
}


- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.delegate.mention didChangeSelection:self];
}

- (void)textViewDidChange:(UITextView *)textView {
    if([textView viewWithTag:999].alpha > 0) {
        [UIView animateWithDuration:.1 animations:^{
            [[textView viewWithTag:999] setAlpha:0];
        }];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [realInputView becomeFirstResponder];
    
    [UIView animateWithDuration:.1 animations:^{
        [[textView viewWithTag:999] setAlpha:0];
    }];
    
    //if ([self.delegate getTableView].contentSize.height > [self.delegate getTableView].frame.size.height) {
        //CGPoint offset = CGPointMake(0, [self.delegate getTableView].contentSize.height);
        //[[self.delegate getTableView] setContentOffset:offset animated:YES];
    //}
    
    NSIndexPath *last = [self.delegate getLastIndexPath];
    //NSIndexPath *path = [NSIndexPath indexPathForRow:last.row inSection:last.section - 1];
    [[self.delegate getTableView] scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:.1 animations:^{
        if([[textView text] length] == 0) {
            [[textView viewWithTag:999] setAlpha:1];
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[UIApplication sharedApplication] openURL:URL]; // Fix for iOS 9 bug
        
        return NO;
    }
    
    return YES;
}

@end
