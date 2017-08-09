//
//  FullWineCell.m
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineNameCell.h"

@implementation WineNameCell {
    UILabel *_nameLabel;
    CALayer *_border;
}
@synthesize singleTheme;

static NSInteger buffer = 8;

- (void)setDelegate:(UIViewController<WineNameCellDelegate> *)delegate {
    _delegate = delegate;
    self.singleTheme = unWineThemeDark;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    self.tintColor = [ThemeHandler getForegroundColor:singleTheme];
    
    if(!_hasSetup) {
        _hasSetup = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(buffer, 0, SCREEN_WIDTH - buffer * 2, 200)];
        [_nameLabel setFont:[UIFont fontWithName:[ThemeHandler getFontNameBold] size:14]];
        [_nameLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 0;
        [self.contentView addSubview:_nameLabel];
    }
    
    _border = [CALayer layer];
    _border.backgroundColor = [[ThemeHandler getSeperatorColor:singleTheme] CGColor];
    _border.frame = CGRectZero;//CGRectMake(2, VC_HEADER_CELL_HEIGHT - .5, SCREEN_WIDTH - 4, .5);
    //[self.layer addSublayer:_border];
}

- (void)configure:(unWine *)wine {
    self.wine = wine;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    NSInteger buffer = self.isEditing ? 20 : 0;
    [_nameLabel setFrame:CGRectMake(buffer, 0, SCREEN_WIDTH - buffer * 2, 200)];
    _nameLabel.text = [self.wine getWineName];
    if(self.isEditing && !ISVALID([self.wine getWineName]))
        _nameLabel.text = @"Tap to add Wine Name";
    
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(buffer, 0, SCREEN_WIDTH - buffer * 2, HEIGHT(_nameLabel) + 14)];
    
    _border.frame = CGRectMake(2, Y2(_nameLabel) + HEIGHT(_nameLabel) - .5, SCREEN_WIDTH - 4, .5);
    [CATransaction commit];
    
    if(self.isEditing)
        self.accessoryType = UITableViewCellAccessoryDetailButton;
    else
        self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)updateTheme {
}

- (NSInteger)getAppropriateHeight {
    //NSLog(@"appropriateHeight - %f", HEIGHT(_nameLabel));
    return HEIGHT(_nameLabel);
}

- (NSString *)getLabelText {
    return ISVALID([self.wine getWineName]) ? [self.wine getWineName] : @"";
}

+ (NSInteger)getDefaultHeight {
    return SCREEN_WIDTH;
}

@end
