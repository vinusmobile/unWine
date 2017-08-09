//
//  commentFooterView.h
//  unWine
//
//  Created by Fabio Gomez on 5/21/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commentFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;

+ (CGRect)rectForView;

@end
