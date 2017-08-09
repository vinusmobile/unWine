//
//  FullWineCell.h
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "unWineActionSheet.h"

@protocol WineNameCellDelegate;
@interface WineNameCell : UITableViewCell <PFObjectCell, Themeable> {
    BOOL _hasSetup;
}

@property (nonatomic) UIViewController<WineNameCellDelegate> *delegate;
@property (nonatomic) unWine *wine;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isEditing;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wine;

- (NSString *)getLabelText;
- (NSInteger)getAppropriateHeight;

@end

@protocol WineNameCellDelegate <NSObject>

@end