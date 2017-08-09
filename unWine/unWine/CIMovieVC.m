//
//  CIMovieVC.m
//  unWine
//
//  Created by Bryce Boesen on 11/9/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CIMovieVC.h"

@interface CIMovieVC ()

@end

@implementation CIMovieVC {
    UIBarButtonItem *done;
    UIBarButtonItem *apply;
}
@synthesize delegate = _delegate, movieData = _movieData, thumbnail = _thumbnail;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(attemptClose)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
    
    done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(attemptDone)];
    self.navigationItem.rightBarButtonItem = done;
    
    self.view.backgroundColor = UNWINE_GRAY_DARK;
    [self basicAppeareanceSetup];
}

- (void)attemptClose {
    [self close];
}

- (void)close {
    if([_delegate respondsToSelector:@selector(willDismiss)])
        [_delegate willDismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)attemptDone {
    [self done];
}

- (void)done {
    [self close];
    if([_delegate respondsToSelector:@selector(willEndPreviewing:thumbnail:)])
        [_delegate willEndPreviewing:_movieData thumbnail:_thumbnail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)basicAppeareanceSetup {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Preview";
}

@end
