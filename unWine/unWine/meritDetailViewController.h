//
//  meritDetailViewController.h
//  unWine
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface meritDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *meritImage;

@property (strong, nonatomic) NSArray *meritDetailModel;
@property (weak, nonatomic) IBOutlet UILabel *meritLabel;
@property (weak, nonatomic) IBOutlet UILabel *meritDescription;

@end
