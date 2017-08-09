//
//  popupView.h
//  unWine
//
//  Created by Bryce Boesen on 9/13/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface popupView : UIView <UIAlertViewDelegate>

@property (nonatomic, retain) UIButton *exitButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) CascadingLabelView *clv;
@property (nonatomic, retain) NSString *exitLink;

-(void)open;
-(void)hide:(BOOL)destroy;
-(void)show;
-(void)showAndOpen;
-(void)close;
-(void)addExitLink:(NSString *)link;

@end
