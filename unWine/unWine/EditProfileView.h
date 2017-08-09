//
//  EditProfileView.h
//  unWine
//
//  Created by Bryce Boesen on 2/18/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeHandler.h"

@class ProfileTVC;
@interface EditProfileView : UIView <Themeable>

@property (nonatomic) ProfileTVC *parent;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addName:(UILabel *)nameLabel relativeFrame:(CGRect)frame;
- (void)addLocation:(UIButton *)locationButton relativeFrame:(CGRect)frame;
- (void)addBirthday;

- (void)dismissFields;

@end
