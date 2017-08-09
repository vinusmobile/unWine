//
//  commentFooterView.m
//  unWine
//
//  Created by Fabio Gomez on 5/21/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentFooterView.h"
#import <QuartzCore/QuartzCore.h>

@interface commentFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation commentFooterView

@synthesize commentField;
@synthesize mainView;

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320, 44.0f)];
        //mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]];
        mainView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        mainView.layer.borderWidth = 0.5f;
        
        [self addSubview:mainView];
        
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thoughtbubblegray.png"]];
        messageIcon.frame = CGRectMake( 10.0f, 7.0f, 30.0f, 30.0f);
        [mainView addSubview:messageIcon];
        
        /*
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TextFieldComment.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f)]];
        commentBox.frame = CGRectMake(35.0f, 8.0f, 237.0f, 35.0f);
        [mainView addSubview:commentBox];
        */
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 48.0f, 7.0f, 252.0f, 30.0f)];
        commentField.font = [UIFont systemFontOfSize:14.0f];
        commentField.placeholder = @"Add a comment";
        commentField.returnKeyType = UIReturnKeySend;
        //commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //[commentField setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        
        commentField.layer.cornerRadius = 8.0f;
        commentField.layer.masksToBounds = YES;
        commentField.layer.borderColor = [[UIColor grayColor] CGColor];
        commentField.layer.borderWidth = 1.0f;
        
        [mainView addSubview:commentField];
    }
    return self;
}

#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f);
}

@end
