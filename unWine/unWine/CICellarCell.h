//
//  CICellar.h
//  unWine
//
//  Created by Fabio Gomez on 10/13/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "AWCell.h"

@interface CICellarCell : AWCell

@property (nonatomic, retain) UIPopoverPresentationController *popover;
@property (weak, nonatomic) IBOutlet UIButton *cellarButton;
@property (weak, nonatomic) IBOutlet UILabel *basicLabel;
@property (weak, nonatomic) __block IBOutlet UIButton *lastEdit;

@end
