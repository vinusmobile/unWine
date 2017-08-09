//
//  CIMovieVC.h
//  unWine
//
//  Created by Bryce Boesen on 11/9/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CIMovieDelegate;
@interface CIMovieVC : UIViewController

@property (nonatomic, strong) id<CIMovieDelegate> delegate;
@property (nonatomic, strong) NSData *movieData;
@property (nonatomic, strong) UIImage *thumbnail;

@end

@protocol CIMovieDelegate <NSObject>
- (void)willDismiss;
- (void)willEndPreviewing:(NSData *)movieData thumbnail:(UIImage *)thumbnail;
@end