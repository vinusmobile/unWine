//
//  WineTVC.h
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "WineContainerVC.h"

typedef enum WineCells {
    WineCellsBasicName,
    WineCellsBasicDetail
} WineCells;

@class WineContainerVC;
@interface WineTVC : UITableViewController <Themeable>

@property (nonatomic) WineContainerVC *parent;
@property (nonatomic) unWine *wine;
@property (nonatomic) BOOL isEditingWine;

- (void)configureLastEdit;

@end
