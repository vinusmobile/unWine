//
//  FacebookButtonView.h
//  unWine
//
//  Created by Fabio Gomez on 3/5/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainLogInViewController;

@interface LoginGenericButtonView : UIView

@property (nonatomic, strong) UIViewController          *parentController;
@property (nonatomic, strong) IBOutlet UIImageView      *iconView;
@property (nonatomic, strong) IBOutlet UILabel          *titleLabel;

- (void)doFacebookSetup;
- (void)doRegularSetup;
- (void)doSignUpSetup;
- (void)doLoginSetup;

@end
