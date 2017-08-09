//
//  unWineAlertView.h
//  unWine
//
//  Created by Bryce Boesen on 9/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "ParseSubclasses.h"

#define SCROLL_ELEMENT_SELECT_DEFAULT 0
#define SCROLL_ELEMENT_SELECT_ALL 1
#define SCROLL_ELEMENT_INVITE_FRIENDS 2

#define UAS_TAG_CHECKIN 0

@interface ScrollElement : NSObject

@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *title;
@property (nonatomic) NSInteger tag;

+ (id)title:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag;
+ (id)inviteFriends;
+ (id)selectAll;

@end

@class unWineActionSheet;
@interface ScrollElementView : UIView

@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) unWineActionSheet *delegate;
@property (nonatomic, strong) id object;

+ (NSMutableArray *)scrollElementsFrom:(NSArray *)array;
+ (ScrollElementView *)makeElementFromObject:(ScrollElement *)object;
+ (ScrollElementView *)makeElementFromUser:(User *)object;
- (void)tappedElement:(UITapGestureRecognizer *)gesture;
- (BOOL)isElementSelected;

@end

@protocol unWineActionSheetDelegate;
@interface unWineActionSheet : UIView

@property (nonatomic, strong) id<unWineActionSheetDelegate> delegate;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *cancelButtonTitle;
@property (nonatomic) NSArray *customContent;
@property (nonatomic) NSArray *otherButtonTitles;
@property (nonatomic) BOOL shouldDismiss;
@property (nonatomic, strong) Merits *merit;
@property (nonatomic, strong) NewsFeed *checkin;

- (id)initWithTitle:(NSString *)title delegate:(id<unWineActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
- (id)initWithTitle:(NSString *)title delegate:(id<unWineActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle customContent:(NSArray *)content;
- (void)showFromTabBar:(UIView *)view;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;
- (NSMutableArray *)getSelectedElements;
- (UIView *)getShowView;

@end

@protocol unWineActionSheetDelegate <NSObject>
@required - (UIViewController *)actionSheetPresentationViewController;
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)willPresentActionSheet:(unWineActionSheet *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(unWineActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(unWineActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end
