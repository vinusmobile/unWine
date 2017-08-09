//
//  commentQueryTableViewController+commentBox.h
//  unWine
//
//  Created by Fabio Gomez on 6/26/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "commentQueryTableViewController.h"

@class PHFComposeBarView;

@interface commentQueryTableViewController (commentBox)
- (PHFComposeBarView *)makeComposeBarView;
- (void)composeBarView:(PHFComposeBarView *)composeBarView didChangeFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame;
- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView;
- (void)keyboardWillShow:(NSNotification*)note;
- (void)postComment:(NSString *)commentString;
@end
