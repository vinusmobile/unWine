//
//  CIShareCell.h
//  unWine
//
//  Created by Bryce Boesen on 5/2/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIShareCell : UITableViewCell <unWineAlertViewDelegate>

@property (nonatomic) id delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *myPath;
@property (nonatomic) unWine *wine;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wineObject;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
