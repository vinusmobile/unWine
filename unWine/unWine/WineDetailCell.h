//
//  WineDetailCell.h
//  unWine
//
//  Created by Bryce Boesen on 3/7/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"

#define WINE_DETAIL_BASE_HEIGHT 40

typedef enum WineDetail {
    WineDetailVineyard,
    WineDetailRegion,
    WineDetailVarietal,
    //WineDetailGrape,
    WineDetailPrice
} WineDetail;

@protocol WineDetailCellDelegate;
@interface WineDetailCell : UITableViewCell <PFObjectCell, Themeable> {
    BOOL _hasSetup;
}

@property (nonatomic) UIViewController<WineDetailCellDelegate> *delegate;
@property (nonatomic) unWine *wine;
@property (nonatomic) WineDetail detail;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isEditing;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wine detail:(WineDetail)detail;

- (BOOL)wineHasDetail:(WineDetail)detail;

- (NSString *)getLabelText;
- (NSInteger)getAppropriateHeight;

@end

@protocol WineDetailCellDelegate <NSObject>

@end
