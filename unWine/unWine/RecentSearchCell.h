//
//  RecentSearchCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RECENT_SEARCH_CELL_HEIGHT 44

@protocol RecentSearchCellDelegate;
@interface RecentSearchCell : UITableViewCell {
    BOOL _hasSetup;
}

@property (nonatomic) id<RecentSearchCellDelegate> delegate;
@property (nonatomic) NSString *searchString;
@property (nonatomic) NSIndexPath *indexPath;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(NSString *)searchString;

- (void)interact:(UIGestureRecognizer *)gesture;

@end

@protocol RecentSearchCellDelegate <NSObject>

@optional - (void)expressPressed:(NSString *)searchString;

@end