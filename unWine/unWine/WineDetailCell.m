//
//  WineDetailCell.m
//  unWine
//
//  Created by Bryce Boesen on 3/7/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineDetailCell.h"

#define WINERY_ICON     [UIImage imageNamed:@"wineryIcon"]
#define REGION_ICON     [UIImage imageNamed:@"newRegionIcon"]
#define RATING_ICON     [UIImage imageNamed:@"newHeartIcon"]
#define PRICE_ICON      [UIImage imageNamed:@"priceIcon"]
#define GRAPE_ICON      [UIImage imageNamed:@"grapeIcon"]
#define VARIETAL_ICON   [UIImage imageNamed:@"varietalIcon"]
#define SMALL_COG_ICON  [UIImage imageNamed:@"smallCogIcon"]

@implementation WineDetailCell {
    UIImageView *_iconView;
    UILabel *_nameLabel;
}
@synthesize singleTheme;

static NSInteger buffer = 16;
static NSInteger padding = 7;

- (void)setDelegate:(UIViewController<WineDetailCellDelegate> *)delegate {
    _delegate = delegate;
    self.singleTheme = unWineThemeDark;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.clipsToBounds = YES;
    self.backgroundColor = [ThemeHandler getCellSecondaryColor:singleTheme];
    self.tintColor = [ThemeHandler getForegroundColor:singleTheme];
    
    if(!_hasSetup) {
        _hasSetup = YES;
        
        NSInteger dim = WINE_DETAIL_BASE_HEIGHT - padding * 2;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, dim, dim)];
        [_iconView setContentMode:UIViewContentModeScaleAspectFill];
        _iconView.tintColor = [ThemeHandler getForegroundColor:singleTheme];
        [self.contentView addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setFont:[UIFont fontWithName:[ThemeHandler getFontNameBold] size:14]];
        [_nameLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 0;
        [self.contentView addSubview:_nameLabel];
    }
}

- (void)configure:(unWine *)wine detail:(WineDetail)detail {
    self.wine = wine;
    self.detail = detail;
    
    NSInteger dim = WINE_DETAIL_BASE_HEIGHT - padding * 2;
    [_nameLabel setFrame:CGRectMake(dim + buffer, 0, SCREEN_WIDTH - buffer * 3 - dim, 200)];
    NSString *money = @"$";
    switch(detail) {
        /*case WineDetailGrape:
            _iconView.image = GRAPE_ICON;
            _nameLabel.text = [self.wine.wineType capitalizedString];
            
            if(self.isEditing) {
                self.accessoryType = UITableViewCellAccessoryDetailButton;
                if(!ISVALID(self.wine.wineType))
                    _nameLabel.text = @"Tap to add the wine's Grape Type";
            } else
                self.accessoryType = UITableViewCellAccessoryNone;
            
            break;*/
        case WineDetailPrice:
            _iconView.image = PRICE_ICON;
            
            if(ISVALID(self.wine.price)) {
                _nameLabel.text = [self.wine.price stringByReplacingOccurrencesOfString:money withString:@""];
            } else
                _nameLabel.text = @"";
            
            if(self.isEditing) {
                self.accessoryType = UITableViewCellAccessoryDetailButton;
                if(!ISVALID(self.wine.price))
                    _nameLabel.text = @"Tap to add the wine's Price";
            } else
                self.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        case WineDetailRegion:
            _iconView.image = REGION_ICON;
            _nameLabel.text = [self.wine.region capitalizedString]; //split by > and make into searchable deep links
            
            if(self.isEditing) {
                self.accessoryType = UITableViewCellAccessoryDetailButton;
                if(!ISVALID(self.wine.region))
                    _nameLabel.text = @"Tap to add the wine's Region";
            } else
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case WineDetailVarietal:
            _iconView.image = VARIETAL_ICON;
            _nameLabel.text = [self.wine.varietal capitalizedString];
            if(!ISVALID(self.wine.varietal))
                _nameLabel.text = [self.wine.wineType capitalizedString];
            
            if(self.isEditing) {
                self.accessoryType = UITableViewCellAccessoryDetailButton;
                if(!ISVALID(self.wine.varietal) && !ISVALID(self.wine.wineType))
                    _nameLabel.text = @"Tap to add the wine's Varietal";
            } else
                self.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        case WineDetailVineyard:
            _iconView.image = WINERY_ICON;
            _nameLabel.text = [self.wine getVineYardName];
            
            if(self.isEditing) {
                self.accessoryType = UITableViewCellAccessoryDetailButton;
                if(!ISVALID([self.wine getVineYardName]))
                    _nameLabel.text = @"Tap to add the wine's Vineyard";
            } else
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        default:
            _nameLabel.text = @"";
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(dim + buffer, 0, SCREEN_WIDTH - buffer * 3 - dim, MAX(HEIGHT(_nameLabel) + 12, WINE_DETAIL_BASE_HEIGHT))];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    if(accessoryType == UITableViewCellAccessoryNone)
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    else
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (BOOL)wineHasDetail:(WineDetail)detail {
    if(self.isEditing)
        return YES;
    
    switch(detail) {
        //case WineDetailGrape:
        //    return ISVALID(self.wine.wineType); // is this right?
        case WineDetailPrice:
            return ISVALID(self.wine.price);
        case WineDetailRegion:
            return ISVALID(self.wine.region);
        case WineDetailVarietal:
            return ISVALID(self.wine.varietal) || ISVALID(self.wine.wineType);
        case WineDetailVineyard:
            return ISVALID(self.wine.vineyard);
        default:
            return NO;
    }
}

- (void)updateTheme {
}

- (NSString *)getLabelText {
    switch(self.detail) {
        //case WineDetailGrape:
        //    return self.wine.wineType ? self.wine.wineType : @""; // is this right?
        case WineDetailPrice:
            return self.wine.price ? self.wine.price : @"";
        case WineDetailRegion:
            return self.wine.region ? self.wine.region : @"";
        case WineDetailVarietal:
            return self.wine.varietal ? self.wine.varietal : (self.wine.wineType ? self.wine.wineType : @"");
        case WineDetailVineyard:
            return self.wine.vineyard ? self.wine.vineyard : @"";
        default:
            return @"";
    }
}

- (NSInteger)getAppropriateHeight {
    return [self wineHasDetail:self.detail] ? HEIGHT(_nameLabel) : 0;
}

+ (NSInteger)getDefaultHeight {
    return WINE_DETAIL_BASE_HEIGHT;
}

@end
