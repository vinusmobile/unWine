//
//  CaptionCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/9/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CaptionCell.h"

@implementation CaptionCell {
    CALayer *border;
}

static NSInteger bufferX = 5;
static NSInteger bufferY = 3;

- (void)setup {
    [super setup];
    self.clipsToBounds = YES;
    
    self.captionView = [[UITextView alloc] init];
    self.captionView.delegate = self;
    self.captionView.tintColor = UNWINE_RED;
    [self.captionView setEditable:NO];
    [self.captionView setScrollEnabled:NO];
    self.captionView.backgroundColor = [UIColor whiteColor];
    //[self formatCaptionView];
    
    [self.contentView addSubview:self.captionView];
    
    border = [CALayer layer];
    border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border.frame = CGRectZero;
    [self.contentView.layer addSublayer:border];
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    [self.captionView setFrame:(CGRect){bufferX, bufferY, {SCREEN_WIDTH - bufferX * 2, [CaptionCell getAppropriateHeight:object] - bufferY * 2}}];
    self.captionView.attributedText = [object getFormattedCaption:[UIColor blackColor]];
    
    [border setFrame:CGRectMake(20, [CaptionCell getAppropriateHeight:self.object] - 1, SCREEN_WIDTH - 40, .5)];
}

- (void)formatCaptionView {
    self.captionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.captionView.layer.borderWidth = .5;
    self.captionView.layer.cornerRadius = 6;
    self.captionView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.captionView.layer.shadowOffset = (CGSize){0, 0};
    self.captionView.layer.shadowOpacity = .5;
    self.captionView.layer.shadowRadius = 1.5;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[UIApplication sharedApplication] openURL:URL]; // Fix for iOS 9 bug
        
        return NO;
    }
    
    return YES;
}

+ (CGFloat)getAppropriateHeight:(NewsFeed *)object {
    CaptionCell *demo = [CaptionCell new];
    [demo setup];
    
    [demo.captionView setFrame:(CGRect){bufferX, bufferY, {SCREEN_WIDTH - bufferX * 2, 300}}];
    demo.captionView.attributedText = [object getFormattedCaption:[UIColor blackColor]];
    [demo.captionView sizeToFit];
    
    return HEIGHT(demo.captionView) + bufferY * 2;
}

@end
