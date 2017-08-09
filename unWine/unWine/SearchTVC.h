//
//  SearchTVC.h
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"

typedef enum SearchTVCMode {
    SearchTVCModeWines,
    SearchTVCModeUsers,
    SearchTVCModeWinery,
    SearchTVCModeRegion
} SearchTVCMode;

typedef enum SearchTVCState {
    SearchTVCStateDefault = 1, //Natural state, showing recent checkin/searches
    SearchTVCStateSearching = 2, //Active reload mediator
    SearchTVCStateSearched = 3 //Stopped typing, resting phase
} SearchTVCState;

@interface SearchTVC : UITableViewController

@property (nonatomic, strong) NSString *presearch;
@property (nonatomic) SearchTVCMode mode;
@property (nonatomic) SearchTVCState state;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *_results;

+ (UINavigationController *)sharedInstance;
+ (CGFloat)similarityBetween:(NSString *)string1 and:(NSString *)string2;

- (void)presentKeyboard;

@end
