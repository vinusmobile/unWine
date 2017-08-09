//
//  unWineAlertView.h
//  unWine
//
//  Created by Bryce Boesen on 10/20/15.
//  Copyright Â© 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Origin)

- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;

@end

typedef enum unWineAlertTheme {
    unWineAlertThemeDefault,
    unWineAlertThemeGray,
    unWineAlertThemeSuccess,
    unWineAlertThemeError,
    unWineAlertThemeRed,
    unWineAlertThemeYesNo
} unWineAlertTheme;

@protocol unWineAlertViewDelegate;
@interface unWineAlertView : NSObject

@property(nonatomic, weak) id<unWineAlertViewDelegate> delegate;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *leftButtonTitle;
@property(nonatomic, copy) NSString *centerButtonTitle;
@property(nonatomic, copy) NSString *rightButtonTitle;

@property(nonatomic) NSInteger tag;
@property(nonatomic) unWineAlertTheme theme;

@property(nonatomic, readonly) BOOL showLogo;
@property(nonatomic, readonly) BOOL showOrLabel;
@property(nonatomic) BOOL emptySpaceDismisses;
@property(nonatomic) BOOL disableDispatch;

+ (id)sharedInstance;
- (id)prepareWithMessage:(NSString *)message;
- (void)shouldShowOrLabel:(BOOL)hmm;
- (void)shouldShowLogo:(BOOL)hmm;
- (void)show;

+ (void)showAlertViewWithBasicSuccess:(NSString *)message;
+ (void)showAlertViewWithTitle:(NSString *)title error:(NSError *)error;
+ (void)showAlertViewWithoutDispatchWithTitle:(NSString *)title error:(NSError *)error;
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message theme:(unWineAlertTheme)theme;
+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle
                         theme:(unWineAlertTheme)theme;
+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
                   yesNoTitles:(NSArray *)buttons;

+ (void)showDisposableAlertView:(NSString *)message
                          theme:(unWineAlertTheme)theme;

@end

@protocol unWineAlertViewDelegate <NSObject>
@optional
- (void)dismissedByEmptySpace;
- (void)leftButtonPressed;
- (void)centerButtonPressed;
- (void)rightButtonPressed;

@end