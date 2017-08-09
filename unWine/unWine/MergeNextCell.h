//
//  MergeNextCell.h
//  unWine
//
//  Created by Bryce Boesen on 6/13/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MergeNextCell : UITableViewCell

@property (nonatomic) id delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *myPath;
@property (nonatomic) PFObject *wine;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(PFObject *)object;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end
