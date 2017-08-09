//
//  WineWorldVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/25/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WineWorldDelegate;
@interface WineWorldVC : UIViewController

@property (nonatomic) id<WineWorldDelegate> delegate;

+ (BFTask *)fetchNearbyWineries:(id<WineWorldDelegate>)delegate;

@end

@protocol WineWorldDelegate <NSObject>

@optional - (void)didChangeAuthorizationStatus;

@end