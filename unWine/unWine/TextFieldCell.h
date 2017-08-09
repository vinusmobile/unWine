//
//  TextFieldCell.h
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegistrationTVC ;

@interface TextFieldCell : UITableViewCell
@property (strong, nonatomic) IBOutlet  UIImageView *iconView;
@property (strong, nonatomic) IBOutlet  UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *mainView;


- (void)setUpUsernameWithParent:(RegistrationTVC *)parentTVC;
- (void)setUpPasswordWithParent:(RegistrationTVC *)parentTVC;
- (void)setUpPassword2WithParent:(RegistrationTVC *)parentTVC;
- (void)setUpEmailWithParent:(RegistrationTVC *)parentTVC;
- (void)setUpEmail2WithParent:(RegistrationTVC *)parentTVC;
- (void)setUpPhoneWithParent:(RegistrationTVC *)parentTVC;
- (void)setUpLocationWithParent:(RegistrationTVC *)parentTVC;


@end
