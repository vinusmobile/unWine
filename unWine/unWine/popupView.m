//
//  popupView.m
//  unWine
//
//  Created by Bryce Boesen on 9/13/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "popupView.h"

#define MAIN_FRAME_SHIFT CGRectMake(X2(mainView), (SCREENHEIGHT - 64) / 2, WIDTH(mainView), 64)
#define SUB_FRAME_SHIFT CGRectMake(X2(subView), (HEIGHT(mainView) - 0) / 2, WIDTH(subView), .5)
#define SCROLL_SPEED .6
#define VISIBILITY_SPEED .6

@implementation popupView {
    CGRect mainFrame, subFrame;
    UIView *mainView, *subView;
    BOOL isOpen;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        
        UIView *shadowView = [[UIView alloc] initWithFrame:self.frame];
        shadowView.backgroundColor = [UIColor darkGrayColor];
        shadowView.alpha = .6;
        UITapGestureRecognizer *tapOpen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
        [self addGestureRecognizer:tapOpen];
        [self addSubview:shadowView];
        
        CGSize size = CGSizeMake(SCREENWIDTH * .80, 300);
        mainView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH - size.width) / 2, (SCREENHEIGHT - size.height) / 2, size.width, size.height)];
        mainView.backgroundColor = UNWINE_RED;
        mainView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        mainView.layer.borderWidth = .5;
        [self addSubview:mainView];
        
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, 32, WIDTH(mainView), HEIGHT(mainView) - 64)];
        subView.backgroundColor = [UIColor whiteColor];
        subView.clipsToBounds = YES;
        [mainView addSubview:subView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width * .10, 3, size.width * .80, 24)];
        _titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16.0f];
        _titleLabel.text = @"Title";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [mainView addSubview:_titleLabel];
        
        _exitButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH(mainView) - 30, 4, 22, 22)];
        _exitButton.tintColor = [UIColor blackColor];
        [_exitButton setImage:[UIImage imageNamed:@"exitbutton"] forState:UIControlStateNormal];
        UITapGestureRecognizer *tapExit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [_exitButton addGestureRecognizer:tapExit];
        [mainView addSubview:_exitButton];
        _exitButton.alpha = 0;
        
        _clv = [[CascadingLabelView alloc] initWithFrame:CGRectMake(0, 0, size.width, HEIGHT(subView) - 20)];
        [_clv setPadding:PaddingMake(6, 6, 6, 6)];
        [subView addSubview:_clv];
        
        mainFrame = mainView.frame;
        subFrame = subView.frame;
        mainView.frame = MAIN_FRAME_SHIFT;
        subView.frame = SUB_FRAME_SHIFT;
    }
    return self;
}

- (void)dismiss:(UIGestureRecognizer *)recognizer {
    [self hide:YES];
}

- (void)toggle {
    if(isOpen)
        [self close];
    else
        [self open];
    
    isOpen = !isOpen;
}

- (void)open {
    [UIView animateWithDuration:SCROLL_SPEED animations:^{
        mainView.frame = mainFrame;
        subView.frame = subFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            _exitButton.alpha = 1;
        }];
    }];
}

- (void)close {
    [UIView animateWithDuration:.2 animations:^{
        _exitButton.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:SCROLL_SPEED animations:^{
            mainView.frame = MAIN_FRAME_SHIFT;
            subView.frame = SUB_FRAME_SHIFT;
        } completion:^(BOOL finished) {
            //[self removeFromSuperview];
        }];
    }];
}

- (void)show {
    [UIView animateWithDuration:VISIBILITY_SPEED animations:^{
        self.alpha = 1;
    }];
}
- (void)showAndOpen {
    [UIView animateWithDuration:VISIBILITY_SPEED animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        isOpen = true;
        [self open];
    }];
}

- (void)hide:(BOOL)destroy {
    [UIView animateWithDuration:VISIBILITY_SPEED animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if(ISVALID(self.exitLink)) {
            /*Not working
             UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Follow the Link?"
                                  message: @"unWine is attempting to navigate you away from all the awesomeness we offer, do you want to open Safari?"
                                  delegate: self
                                  cancelButtonTitle:@"Yes"
                                  otherButtonTitles:@"No", nil];
             [alert show];*/
            if(isOpen) {
                NSURL *url = [NSURL URLWithString:self.exitLink];
                
                if (![[UIApplication sharedApplication] openURL:url]) {
                    NSLog(@"%@%@",@"Failed to open url:",[url description]);
                }
            }
        }
        
        if(destroy)
            [self removeFromSuperview];
    }];
}

/*Not working*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex: %li", (long)buttonIndex);
    if(buttonIndex == 0) {
    }
}

- (void)addExitLink:(NSString *)link {
    self.exitLink = link;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
