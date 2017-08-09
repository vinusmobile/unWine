//
//  meritDetailViewController.m
//  unWine
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritDetailViewController.h"

@interface meritDetailViewController ()

@end

@implementation meritDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    // Display the merit details 
    _meritImage.image = (UIImage *)_meritDetailModel[0];
    _meritLabel.text = (NSString *)_meritDetailModel[1];
    _meritDescription.text = (NSString *)_meritDetailModel[2];
    
    NSLog(@"The merit label is %@  !!!!!!!!", self.meritLabel);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
