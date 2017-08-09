//
//  SearchCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell {
    BOOL hasSetup;
    UIToolbar *numberToolbar;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup {
    if(!hasSetup) {
        hasSetup = YES;
        
        numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self), 44)];
        numberToolbar.barStyle = UIBarStyleDefault;
        numberToolbar.tintColor = UNWINE_RED;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resignField)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               nil];
        [numberToolbar sizeToFit];
        
        self.searchBar.inputAccessoryView = numberToolbar;
        self.searchBar.tintColor = UNWINE_RED;
    }
}

- (void)resignField {
    [self.searchBar resignFirstResponder];
}

@end