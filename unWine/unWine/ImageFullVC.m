//
//  ImageFullVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/3/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ImageFullVC.h"
#define MINIMUM_SCALE .25f
#define MAXIMUM_SCALE 4.0f

@interface ImageFullVC ()
@end

@implementation ImageFullVC
@synthesize scrollView, doneButton, wineImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //scrollView.minimumZoomScale = 1.0;
    //scrollView.maximumZoomScale = 1.0;
    //scrollView.contentSize = wineImage.frame.size;
    //scrollView.delegate = self;
    
    wineImage.contentMode = UIViewContentModeScaleAspectFit;
    
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restore:)];
    //tapGesture.numberOfTapsRequired = 2;
    //[wineImage addGestureRecognizer:tapGesture];
    //UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    //[wineImage addGestureRecognizer:pinchGesture];
    
    doneButton.layer.cornerRadius = 12;
    doneButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    doneButton.layer.borderWidth = 1.0f;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doneButton:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
    [wineImage addGestureRecognizer:swipeGesture];
    wineImage.userInteractionEnabled = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return wineImage;
}

- (void)restore:(UITapGestureRecognizer *)gesture {
    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:.2 animations:^{
        wineImage.transform = transform;
    } completion:^(BOOL finished) {
        scrollView.contentSize = wineImage.frame.size;
    }];
}

/*- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"gesture.scale = %f", gesture.scale);
        
        CGFloat currentScale = wineImage.frame.size.width / wineImage.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;
        
        if (newScale < MINIMUM_SCALE) {
            newScale = MINIMUM_SCALE;
        }
        if (newScale > MAXIMUM_SCALE) {
            newScale = MAXIMUM_SCALE;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        wineImage.transform = transform;
        
        scrollView.contentSize = wineImage.frame.size;
        
        gesture.scale = 1;
    }
}*/

- (void) setImage:(UIImage *)image {
    self.wineImage.image = image;
    [self restore:nil];
    
    //scrollView.center = wineImage.center;
    //scrollView.contentSize = wineImage.frame.size;
    
    /*[UIView animateWithDuration:.1 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];*/
}

- (IBAction)doneButton:(id)sender {
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
