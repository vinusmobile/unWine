//
//  CICaptionCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/27/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWCell.h"
#import "UIPlaceHolderTextView.h"
#import "MentionTVC.h"

@interface CICaptionCell : UITableViewCell <UITextViewDelegate, MentionInputDelegate>

@property (nonatomic) UIViewController<MentionTVCDelegate> *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *myPath;
@property (nonatomic) unWine *wine;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wineObject;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *captionView;

@end
