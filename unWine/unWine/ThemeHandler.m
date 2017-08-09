//
//  ThemeHandler.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "ThemeHandler.h"
#import "CheckinInterface.h"
#import "VineCastConstants.h"

@interface ThemeHandler ()

@property (nonatomic) unWineTheme theme;

@end

@implementation ThemeHandler

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static ThemeHandler *_sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        _sharedObject.theme = unWineThemeDark;
    });
    
    return _sharedObject;
}

- (void)setTheme:(unWineTheme)theme {
    _theme = theme;
    
    UIViewController *topController = (GET_APP_DELEGATE).window.rootViewController;
    
    do {
        if([topController conformsToProtocol:@protocol(Themeable)])
            [(id<Themeable>)topController updateTheme];
            
        NSArray<__kindof UIViewController *> *children = topController.childViewControllers;
        for(UIViewController *controller in children) {
            if([controller conformsToProtocol:@protocol(Themeable)])
                [(id<Themeable>)controller updateTheme];
            
            if([controller isKindOfClass:[UITableViewController class]]) {
                UITableViewController *tvc = (UITableViewController *)controller;
                for(UITableViewCell *cell in tvc.tableView.visibleCells)
                    if([cell conformsToProtocol:@protocol(Themeable)])
                        [(id<Themeable>)cell updateTheme];
            }
        }
        
        topController = topController.presentedViewController;
    } while(topController.presentedViewController);
}

+ (void)setTheme:(unWineTheme)theme {
    [[ThemeHandler sharedInstance] setTheme:theme];
}

+ (NSString *)getFontName {
    return @"OpenSans";
}

+ (NSString *)getFontNameBold {
    return [NSString stringWithFormat:@"%@-Bold", [ThemeHandler getFontName]];
}

+ (NSString *)getFontNameItalic {
    return [NSString stringWithFormat:@"%@-Italic", [ThemeHandler getFontName]];
}

+ (UIColor *)getDeepBackgroundColor {
    return [ThemeHandler getDeepBackgroundColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getDeepBackgroundColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_DEEP_BACKGROUND_COLOR;
        case unWineThemeLight:
            return [UIColor colorWithRed:.95 green:.97 blue:.96 alpha:1];
        default:
            return [UIColor whiteColor];
    }
}

+ (UIColor *)getBackgroundColor {
    return [ThemeHandler getBackgroundColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getBackgroundColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_BACKGROUND_COLOR;
        case unWineThemeLight:
            return [UIColor colorWithRed:.93 green:.95 blue:.94 alpha:1];
        default:
            return [UIColor whiteColor];
    }
}

+ (UIColor *)getCellPrimaryColor {
    return [ThemeHandler getCellPrimaryColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getCellPrimaryColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_MIDDGROUND_COLOR;
        case unWineThemeLight:
            return [UIColor whiteColor];
        default:
            return [UIColor whiteColor];
    }
}

+ (UIColor *)getCellSecondaryColor {
    return [ThemeHandler getCellSecondaryColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getCellSecondaryColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_SECONDARY_COLOR;
        case unWineThemeLight:
            return [UIColor whiteColor];
        default:
            return [UIColor whiteColor];
    }
}

+ (UIColor *)getForegroundColor {
    return [ThemeHandler getForegroundColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getForegroundColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_FOREGROUND_COLOR;
        case unWineThemeLight:
            return [UIColor blackColor];
        default:
            return [UIColor whiteColor];
    }
}

+ (UIColor *)getSeperatorColor {
    return [ThemeHandler getSeperatorColor:[ThemeHandler sharedInstance].theme];
}

+ (UIColor *)getSeperatorColor:(unWineTheme)theme {
    switch (theme) {
        case unWineThemeDark:
            return CI_SEPERATOR_COLOR;
        case unWineThemeLight:
            return CI_SEPERATOR_COLOR;
        default:
            return [UIColor whiteColor];
    }
}

@end
