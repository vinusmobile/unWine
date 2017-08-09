//
//  CheckinTVC.m
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CheckinTVC.h"

@implementation CheckinTVC

#pragma ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)addWine:(unWine *)wine {
    if(!_wines)
        _wines = [[NSMutableArray alloc] init];
    
    BOOL shouldAdd = YES;
    for(unWine *w in _wines)
        shouldAdd &= ![wine isEqual:w];
    
    if(shouldAdd)
        [_wines addObject:wine];
}

@end
