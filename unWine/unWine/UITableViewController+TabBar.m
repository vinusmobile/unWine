//
//  UITableViewController+TabBar.m
//  unWine
//
//  Created by Fabio Gomez on 2/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "UITableViewController+TabBar.h"

@implementation UITableViewController (TabBar)

// Helper Methods
- (NSUInteger)getTabBarIndex {
    return [self.tabBarController.viewControllers indexOfObjectIdenticalTo:self.navigationController];
}

- (int)getCurrentTabItemBadgeValue {
    NSUInteger currentTabIndex = [self.tabBarController.viewControllers indexOfObjectIdenticalTo:self.navigationController];
    NSString *currentTabBadgeValue = [[self.tabBarController.tabBar.items objectAtIndex:currentTabIndex] badgeValue];
    int value = [currentTabBadgeValue intValue];
    
    return value;
}

// Methods that set the badge value
- (void)updateTabBadgeWithValue:(int)value{
    
    NSUInteger index = [self getTabBarIndex];
    int currentBadgeValue = [self getCurrentTabItemBadgeValue];
    
    if (value < 0) {
        NSLog(@"%s - Invalid Value = %i", __PRETTY_FUNCTION__, value);
        return;
    }

    NSLog(@"%s - currentBadgeValue       = %i", __PRETTY_FUNCTION__, currentBadgeValue);
    
    // Sanity Check
    if (value == 0) {
        [self clearTabItemBadgeValue];
        return;
    }
    
    [[self.tabBarController.tabBar.items objectAtIndex:index] setBadgeValue: [NSString stringWithFormat:@"%i", value]];
    
}

- (void)incrementTabBadgeValueByAmount:(int)amount {
    
    int currentBadgeValue = [self getCurrentTabItemBadgeValue];
    int newBadgeValue = 0;
    
    if (amount <= 0) {
        NSLog(@"%s - Invalid Increment Amount = %i", __PRETTY_FUNCTION__, amount);
        return;
    }
    
    NSLog(@"%s - Current Badge Value = %i", __PRETTY_FUNCTION__, currentBadgeValue);
    newBadgeValue = currentBadgeValue + amount;
    
    //[self updateTabBadgeWithValue:newBadgeValue];
}

- (void)decrementTabBadgeValueByAmount:(int)amount {
    
    int currentBadgeValue = [self getCurrentTabItemBadgeValue];
    int newBadgeValue = 0;
    
    if (amount <= 0) {
        NSLog(@"%s - Invalid Decrement Amount = %i", __PRETTY_FUNCTION__, amount);
        return;
    }
    
    NSLog(@"%s - Current Badge Value = %i", __PRETTY_FUNCTION__, currentBadgeValue);
    newBadgeValue = currentBadgeValue - amount;
    
    if (newBadgeValue <= 0) {
        [self clearTabItemBadgeValue];
        return;
    }
    
    //[self updateTabBadgeWithValue:newBadgeValue];
}



- (void)clearTabItemBadgeValue {
    [[self.tabBarController.tabBar.items objectAtIndex:[self getTabBarIndex]] setBadgeValue: nil];
}

@end
