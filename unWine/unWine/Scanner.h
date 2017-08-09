//
//  ScannerVC.h
//  unWine
//
//  Created by Fabio Gomez on 4/24/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VineCastTVC;
@interface Scanner : NSObject

@property (nonatomic, strong) VineCastTVC *delegate;

- (void)showScanner;

@end
