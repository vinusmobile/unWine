 //
//  main.m
//  unWine
//
//  Created by Fabio Gomez on 9/28/13.
//  Copyright (c) 2013 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "unWineAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        int retValue = -1;
        @try {
            retValue = UIApplicationMain(argc, argv, nil, NSStringFromClass([unWineAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
        return retValue;
    }
}
