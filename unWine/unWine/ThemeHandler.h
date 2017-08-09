//
//  ThemeHandler.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum unWineTheme {
    unWineThemeLight,
    unWineThemeDark
} unWineTheme;

@protocol Themeable;
@interface ThemeHandler : NSObject

+ (instancetype)sharedInstance;
+ (void)setTheme:(unWineTheme)theme;

+ (NSString *)getFontName;
+ (NSString *)getFontNameBold;
+ (NSString *)getFontNameItalic;
+ (UIColor *)getDeepBackgroundColor;
+ (UIColor *)getBackgroundColor;
+ (UIColor *)getSeperatorColor;
+ (UIColor *)getCellPrimaryColor;
+ (UIColor *)getCellSecondaryColor;
+ (UIColor *)getForegroundColor;
+ (UIColor *)getDeepBackgroundColor:(unWineTheme)theme;
+ (UIColor *)getBackgroundColor:(unWineTheme)theme;
+ (UIColor *)getSeperatorColor:(unWineTheme)theme;
+ (UIColor *)getCellPrimaryColor:(unWineTheme)theme;
+ (UIColor *)getCellSecondaryColor:(unWineTheme)theme;
+ (UIColor *)getForegroundColor:(unWineTheme)theme;

@end

@protocol Themeable <NSObject>

@property (nonatomic) unWineTheme singleTheme;

@required - (void)updateTheme;

@end
