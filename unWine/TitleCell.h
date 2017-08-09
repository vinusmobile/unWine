//
//  WineNameCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"

@interface TitleCell : VineCastCell

@property (strong, nonatomic) IBOutlet UILabel *wineNameLabel;
- (void)configureCell:(PFObject *)object andTitle:(NSString *)title;

+ (NSString *)getWineName:(PFObject *)object;

@end
