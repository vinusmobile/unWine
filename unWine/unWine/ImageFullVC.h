//
//  ImageFullVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/3/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

@interface ImageFullVC : UIViewController

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *wineImage;
@property (weak, nonatomic) IBOutlet UIView *detailView;

- (void)setImage:(UIImage *)image;

@end
