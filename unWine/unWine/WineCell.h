//
//  WineCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "unWineActionSheet.h"

#define WINE_CELL_HEIGHT 60
#define WINE_CELL_HEIGHT_EXTENDED 80

typedef enum WineCellMode {
    WineCellModeDefault,
    WineCellModeRecentCheckin,
    WineCellModeTopResult,
    WineCellModeResult,
    WineCellModeHeightCheck,
    WineCellModeCheckin,
    WineCellModeVinecast
} WineCellMode;

typedef enum WineCellSubtitleMode {
    WineCellSubtitleModeWinery,
    WineCellSubtitleModeRegion,
    WineCellSubtitleModeCustom
} WineCellSubtitleMode;

typedef enum WineCellSource {
    WineCellSourceWinery
} WineCellSource;

@protocol WineCellDelegate;
@interface WineCell : UITableViewCell <unWineActionSheetDelegate, PFObjectCell, Themeable> {
    BOOL _hasSetup;
}

@property (nonatomic) UIViewController<WineCellDelegate> *delegate;
@property (nonatomic) unWine *wine;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) WineCellMode mode;
@property (nonatomic) WineCellSubtitleMode subtitleMode;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) BOOL assumeExtended;
@property (nonatomic) WineCellSource source;

/*!
 * Happens once regardless of the number of times called, useful for one shot assignments and creations for non-variable elements
 */
- (void)setup:(NSIndexPath *)indexPath;

/*!
 * Configure with Wine objectId and specified WineCellMode
 */
- (void)configureWithObjectId:(NSString *)objectId mode:(WineCellMode)mode;

/*!
 * Reconfigure the reusable cell with the specified wine and default WineCellMode
 */
- (void)configure:(unWine *)wine;

/*!
 * Reconfigure the reusable cell with the specified wine and specified WineCellMode
 */
- (void)configure:(unWine *)wine mode:(WineCellMode)mode;

- (void)interact:(UIGestureRecognizer *)gesture;

- (void)recommendIt;

+ (NSInteger)getExtendedHeight:(PFObject *)object mode:(WineCellMode)mode;

@end

/*!
 * Must synthesize extendedPath variable on delegate ViewControllers
 */
@protocol WineCellDelegate <NSObject>

@property (nonatomic) NSIndexPath *extendedPath;

/*!
 * Ideally the tabBarController's view
 */
@required - (UIView *)wineMorePresentationView;

/*!
 * Ideally push the ViewController on the navigationController's stack
 */
@required - (void)presentViewControllerFromCell:(UIViewController *)controller;

@optional - (void)resignIfNecessary;
@optional - (void)showHUD;
@optional - (void)hideHUD;
@optional - (void)updateCells;

@end
