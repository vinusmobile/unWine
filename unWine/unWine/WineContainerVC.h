//
//  WineContainerVC.h
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WineTVC.h"
#import "MDCParallaxView.h"
#import "WineDetailCell.h"
#import "unWineActionSheet.h"

@class WineTVC, WineDetailCell;
@interface WineContainerVC : UIViewController <unWineActionSheetDelegate>

@property (nonatomic) WineTVC *wineTable;
@property (nonatomic) unWine *wine;
@property (nonatomic, strong) UIImage *theWineImage;
@property (nonatomic) MDCParallaxView *parallaxView;

@property (nonatomic) CastCheckinSource cameFrom;
@property (nonatomic) BOOL bidirectional;
@property (nonatomic) BOOL isNew;
@property (nonatomic) NSMutableDictionary *registers;

- (void)setWineName:(NSString *)text;
- (void)setWineDetail:(WineDetail)detail toText:(NSString *)text;
@end
