//
//  SearchCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

- (void)setup;

@end