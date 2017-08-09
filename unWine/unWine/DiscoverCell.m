//
//  DiscoverCell.m
//  unWine
//
//  Created by Bryce Boesen on 3/4/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "DiscoverCell.h"
#import "CIFilterVC.h"

#define DISCOVER_CELL_BUFFER 4

@implementation DiscoverCell {
    UIImageView *_iconView;
    UILabel *_discoverLabel;
    UILabel *_discoverSublabel;
}
@synthesize singleTheme;

static NSInteger buffer = DISCOVER_CELL_BUFFER;
static NSInteger dim = DISCOVER_CELL_HEIGHT;
static NSInteger offset = 4;
static NSInteger inset = 12;

- (void)setDelegate:(DiscoverTVC *)delegate {
    _delegate = delegate;
    self.singleTheme = unWineThemeDark;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    if(!_hasSetup) {
        _hasSetup = YES;
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _iconView = [[UIImageView alloc] initWithFrame:(CGRect){inset, inset, {dim - inset * 2, dim - inset * 2}}];
        _iconView.bounds = _iconView.frame;
        _iconView.layer.cornerRadius = 6;
        _iconView.clipsToBounds = YES;
        [self.contentView addSubview:_iconView];
        
        NSInteger x = dim + buffer;
        NSInteger w = SCREEN_WIDTH - x - buffer;
        _discoverLabel = [[UILabel alloc] initWithFrame:(CGRect){x, offset, {w, 32}}];
        [_discoverLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [_discoverLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _discoverLabel.clipsToBounds = YES;
        [self.contentView addSubview:_discoverLabel];
        
        _discoverSublabel = [[UILabel alloc] initWithFrame:(CGRect){x, HEIGHT(_discoverLabel), {w, 20}}];
        [_discoverSublabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [_discoverSublabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _discoverSublabel.clipsToBounds = YES;
        [self.contentView addSubview:_discoverSublabel];
    }
}

- (void)configure:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle {
    self.icon = icon;
    
    [_iconView setFrame:(CGRect){inset, inset, {dim - inset * 2, dim - inset * 2}}];
    [_iconView setImage:icon/*[CIFilterVC squareImageFromImage:icon scaledToSize:dim - inset * 2]*/];
    [_iconView setContentMode:UIViewContentModeScaleAspectFill];
    
    _discoverLabel.text = title;
    _discoverSublabel.text = subtitle;
}

- (void)updateTheme {
    
}

@end
