//
//  CheckinTVC.h
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"

@interface CheckinTVC : UITableViewController {
    NSMutableArray *_wines;
}

- (void)addWine:(unWine *)wine;

@end
