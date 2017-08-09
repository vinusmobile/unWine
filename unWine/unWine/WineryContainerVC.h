//
//  WineryContainerVC.h
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineryTVC.h"
#import "unWineActionSheet.h"

@class WineryTVC;

@interface WineryContainerVC : UIViewController <unWineActionSheetDelegate>

@property (nonatomic) WineryTVC *wineryTable;
@property (nonatomic) Winery *winery;

@property (nonatomic) BOOL isNew;

@end
