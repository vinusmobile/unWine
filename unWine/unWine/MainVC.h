//
//  MainVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/27/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "ParseSubclasses.h"

@protocol StateControl;
@interface MainVC : UIViewController

@property (nonatomic, strong) UIViewController<StateControl> *presented;

+ (instancetype)sharedInstance;

/*!
 * BFTask completion wrapper
 */
- (BFTask *)presentIfNecessary:(BOOL)animated;

/*!
 * BFTask completion wrapper, completion includes a presentIfNecessary
 */
- (BFTask *)dismissPresented:(BOOL)animated;
- (void)checkPresentView;

- (void)enqueueProtocolURL:(NSDictionary *)dict;

@end

@protocol StateControl <NSObject>

@end