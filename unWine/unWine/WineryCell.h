//
//  WineryCell.h
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "unWineActionSheet.h"

typedef enum WineryCellMode {
    WineryCellModeDefault
} WineryCellMode;

typedef enum WineryCellSource {
    WineryCellSourceWineryView,
    WineryCellSourceWinerySearchView
} WineryCellSource;

@protocol WineryCellDelegate;
@interface WineryCell : UITableViewCell <unWineActionSheetDelegate, PFObjectCell, Themeable>

@property (nonatomic) UIViewController<WineryCellDelegate> *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Winery *winery;
@property (nonatomic) WineryCellMode mode;
@property (nonatomic) WineryCellSource source;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(Winery *)winery;
- (void)configure:(Winery *)winery mode:(WineryCellMode)mode;
- (void)recommendIt;

@end

@protocol WineryCellDelegate <NSObject>

@required - (UIView *)wineMorePresentationView;
@optional - (void)showHUD;
@optional - (void)hideHUD;
/*!
 * Ideally push the ViewController on the navigationController's stack
 */
@required - (void)presentViewControllerFromCell:(UIViewController *)controller;

@end
