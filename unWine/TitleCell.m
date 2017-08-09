//
//  WineNameCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "TitleCell.h"
#import "ParseSubclasses.h"

@implementation TitleCell

- (void)configureCell:(PFObject *)object andTitle:(NSString *)title {
    [super configureCell:object];
    
    //self.wineNameLabel.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:16];
    self.wineNameLabel.text = title;
}

+ (NSString *)getWineName:(PFObject *)object {
    PFObject *wine = [VineCastCell getWineForObject:object];
    NSString *wineName = [wine.parseClassName isEqualToString:[unWine parseClassName]] ? [((unWine *)wine) getWineName] : ((unwinePending *)wine).name.capitalizedString;
    
    return wineName == nil || [wineName isEqualToString:@""] ? @"Uh oh! Dropped a wine bottle" : wineName;
}

@end
