//
//  PopoverVC.m
//  unWine
//
//  Created by Bryce Boesen on 9/28/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "PopoverVC.h"

#define POPOVER_WIDTH (SCREEN_WIDTH - 48)
#define POPOVER_HEIGHT 200

@implementation PopoverVC {
    UINavigationController *destNav;
    UILabel *textLabel;
    UITapGestureRecognizer *gesture;
}

+ (PopoverVC *)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (UINavigationController *)setup:(NSString *)text {
    if(destNav == nil)
        destNav = [[UINavigationController alloc] initWithRootViewController:self];
    //self.view.backgroundColor = UNWINE_RED;
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    destNav.navigationBarHidden = YES;
    
    if(textLabel == nil)
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH - 16, POPOVER_HEIGHT - 16)];
    else
        [textLabel setFrame:CGRectMake(0, 0, POPOVER_WIDTH - 16, POPOVER_HEIGHT - 16)];
    
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel sizeToFit];
    
    textLabel.frame = CGRectMake(8, 8, POPOVER_WIDTH - 16, HEIGHT(textLabel));
    textLabel.userInteractionEnabled = YES;
    
    if(gesture == nil) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [textLabel addGestureRecognizer:gesture];
    }
    
    if(![textLabel isDescendantOfView:self.view])
        [self.view addSubview:textLabel];
    
    CGSize pref = CGSizeMake(POPOVER_WIDTH, HEIGHT(textLabel) + 16);
    destNav.preferredContentSize = pref;
    self.preferredContentSize = pref;
    self.view.backgroundColor = UNWINE_RED;
    
    return destNav;
}

- (void)showFrom:(UIViewController *)host sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect text:(NSString *)text {
    [self showFrom:host sourceView:sourceView sourceRect:sourceRect direction:(UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp) text:text];
}

- (void)showFrom:(UIViewController *)host sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect direction:(UIPopoverArrowDirection)direction text:(NSString *)text {
    if(_displayed) {
        LOGGER(@"balloon popover is already displayed and is attempting to be reused");
        return;
    }
    if([host isBeingDismissed] || [host.view isHidden] || [host.view.window isHidden] || [sourceView isHidden] || [sourceView.window isHidden]) {
        LOGGER(@"displayer or sourceView is hidden");
        return;
    }
    _displayed = YES;
    LOGGER(text);
    UINavigationController *presenter = [self setup:text];
    
    self.popover = presenter.popoverPresentationController;
    self.popover.backgroundColor = UNWINE_RED;
    [self.popover setPermittedArrowDirections:direction];
    self.popover.delegate = self;
    self.popover.sourceView = sourceView;
    self.popover.sourceRect = sourceRect;
    
    self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, HEIGHT(textLabel) + 16);
    self.popover.backgroundColor = UNWINE_RED;
    
    [host presentViewController:presenter animated:YES completion:nil];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self undisplay];
}

- (void)dismiss {
    [destNav dismissViewControllerAnimated:YES completion:^{
        [self undisplay];
    }];
}

- (void)undisplay {
    _displayed = NO;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(popoverDismissed)]) {
        [self.delegate popoverDismissed];
        self.delegate = nil;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)isDisplayed {
    return _displayed;
}

@end
