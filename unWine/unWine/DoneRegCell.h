//
//  DoneRegCell.h
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegistrationTVC;

@interface DoneRegCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

- (void)setUpWithParent:(RegistrationTVC *)parentTVC;

@end
