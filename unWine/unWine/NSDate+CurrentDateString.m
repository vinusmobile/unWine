//
//  NSDate+CurrentDateString.m
//  unWine
//
//  Created by Fabio Gomez on 7/5/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "NSDate+CurrentDateString.h"

@implementation NSDate (CurrentDateString)
+ (NSString *)getCurrentDateString {
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"MMM dd, YYYY, HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    return dateString;
}
@end
