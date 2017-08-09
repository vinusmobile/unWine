//
//  unWineAlertView.m
//  unWine
//
//  Created by Bryce Boesen on 9/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWineActionSheet.h"
#import "ParseSubclasses.h"
#import "UIImage-JTColor.h"
#import "CastProfileVC.h"
#import "ProfileTVC.h"

static NSInteger cell_title_height = 40;
static NSInteger cell_button_height = 50;
static NSInteger cell_cancel_height = 60;
static NSInteger elements_per_page = 4;
static NSInteger cell_scroll_height = 120;
static NSInteger shift_height = 48;

@implementation unWineActionSheet {
    UIView *showView;
    UILabel *titleView;
    UIButton *cancelButton;
    NSMutableArray *viewQueue;
    UIView *shadowView;
    NSInteger logoViewAlpha;
}
typedef void(^actionSheetComplete)(void);

- (id)initWithTitle:(NSString *)title delegate:(id<unWineActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT + shift_height)];
    if(self) {
        self.title = title;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonTitles;
        self.shouldDismiss = YES;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title delegate:(id<unWineActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle customContent:(NSArray *)content {
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT + shift_height)];
    if(self) {
        self.title = title;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        self.customContent = content;
        self.shouldDismiss = YES;
    }
    return self;
}

- (void)constructViews:(UIView *)view {
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;
    
    shadowView = [[UIView alloc] initWithFrame:(CGRect){0, -SCREENHEIGHT, {SCREENWIDTH, SCREENHEIGHT * 2 + shift_height}}];
    shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    
    shadowView.alpha = 0;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [shadowView addGestureRecognizer:gesture];
    
    [self addSubview:shadowView];
    
    viewQueue = [[NSMutableArray alloc] init];
    
    NSInteger nextY = 0;
    NSInteger index = 0;
    if(self.cancelButtonTitle != nil) {
        cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setBackgroundColor:UNWINE_GRAY_LIGHT];
        [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [cancelButton addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(0, HEIGHT(view) - (nextY += cell_cancel_height), WIDTH(view), cell_cancel_height + shift_height)];
        cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, shift_height, 0);
        
        cancelButton.tag = index++;
        cancelButton.alpha = 0;
        
        [viewQueue addObject:cancelButton];
        [self addSubview:cancelButton];
    }
    
    if(self.otherButtonTitles != nil) {
        for(NSInteger i = [self.otherButtonTitles count] - 1; i >= 0; i--) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setBackgroundColor:UNWINE_GRAY_DARK];
            [button setTitle:[self.otherButtonTitles objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
            [button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setFrame:CGRectMake(0, HEIGHT(view) - (nextY += cell_button_height), WIDTH(view), cell_button_height)];
            
            button.tag = index++;
            button.alpha = 0;
            
            if(i != [self.otherButtonTitles count] - 1) {
                CALayer *border = [CALayer layer];
                border.backgroundColor = [UNWINE_GRAY_LIGHT CGColor];
                border.frame = CGRectMake(40, button.frame.size.height - 1, button.frame.size.width - 80, 1);
                [button.layer addSublayer:border];
            }
            
            [viewQueue addObject:button];
            [self addSubview:button];
        }
    }
    
    if(self.customContent != nil) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEIGHT(view) - (nextY += cell_scroll_height), WIDTH(view), cell_scroll_height)];
        [scrollView setBackgroundColor:UNWINE_GRAY_DARK];
        scrollView.clipsToBounds = YES;
        [scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [scrollView setBounces:YES];
        
        NSInteger x = 0;
        for(NSInteger i = 0; i < [self.customContent count]; i++) {
            ScrollElementView *element = [self.customContent objectAtIndex:i];
            [element setFrame:CGRectMake(x, 0, WIDTH(element), HEIGHT(element))];
            element.delegate = self;
            
            [scrollView addSubview:element];
            //NSLog(@"%ld, %ld", (long)element.tag, (long)x);
            x += WIDTH(element);
        }
        NSInteger offset = (SCREEN_WIDTH - x) / 2;
        if(offset > 0)
            [scrollView setLayoutMargins:UIEdgeInsetsMake(0, offset, 0, 10)];
        else
            [scrollView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
        scrollView.contentSize = CGSizeMake(MAX(x, SCREEN_WIDTH + 1), HEIGHT(scrollView));
        scrollView.tag = index++;
        scrollView.alpha = 0;
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [UNWINE_GRAY_LIGHT CGColor];
        border.frame = CGRectMake(40, scrollView.frame.size.height - 1, MIN(scrollView.contentSize.width - 80, WIDTH(scrollView) - 80), 1);
        [scrollView.layer addSublayer:border];
        
        [viewQueue addObject:scrollView];
        [self addSubview:scrollView];
    }
    
    if(self.title != nil) {
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT(view) - (nextY + cell_title_height), WIDTH(view), cell_title_height)];
        [titleView setBackgroundColor:UNWINE_GRAY];
        [titleView setText:self.title];
        [titleView setTextAlignment:NSTextAlignmentCenter];
        [titleView setTextColor:[UIColor whiteColor]];
        
        titleView.numberOfLines = 0;
        [titleView sizeToFit];
        NSInteger newHeight = MAX(HEIGHT(titleView) + (cell_title_height - titleView.font.pointSize), cell_title_height);
        [titleView setFrame:(CGRect){0, HEIGHT(view) - (nextY += newHeight), {WIDTH(view), newHeight}}];
        
        titleView.alpha = 0;
        titleView.userInteractionEnabled = YES;
        
        [viewQueue addObject:titleView];
        [self addSubview:titleView];
    }
}

- (void)alterButton:(UIButton *)button {
    
}

- (UIView *)getShowView {
    return showView;
}

- (void)show:(UIView *)view {
    //logoViewAlpha = (GET_APP_DELEGATE).ctbc.logoView.alpha;
    //(GET_APP_DELEGATE).ctbc.logoView.alpha = 0;
    NSMutableArray *viewFrames = [[NSMutableArray alloc] init];
    for(UIView *subview in viewQueue) {
        [viewFrames addObject:NSStringFromCGRect(subview.frame)];
        subview.frame = CGRectMake(0, HEIGHT(view) - 1, WIDTH(view), HEIGHT(subview));
        subview.alpha = 1;
    }
    
    [UIView animateWithDuration:.35 animations:^{
        [shadowView setAlpha:1];
        for(NSInteger i = 0; i < [viewQueue count]; i++) {
            UIView *subview = [viewQueue objectAtIndex:i];
            [subview setFrame:CGRectFromString((NSString *)[viewFrames objectAtIndex:i])];
        }
    }];
}

- (void)dismiss {
    [self dismiss:^{ }];
}

- (void)dismiss:(actionSheetComplete)compblock {
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y -= 48;
        [self setFrame:frame];
    } completion:^(BOOL fin1) {
        [UIView animateWithDuration:.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:
        ^{
            CGRect frame = self.frame;
            frame.origin.y = SCREENHEIGHT - 1;
            [self setFrame:frame];
            [shadowView setAlpha:0];
        } completion:^(BOOL fin2) {
            [UIView animateWithDuration:.15 animations:^{
                for(UIView *view in viewQueue)
                    [view setAlpha:0];
            } completion:^(BOOL fin3) {
                [shadowView removeFromSuperview];
                [self removeFromSuperview];
                //(GET_APP_DELEGATE).ctbc.logoView.alpha = logoViewAlpha;
                compblock();
            }];
        }];
    }];
}

- (void)showFromTabBar:(UIView *)view {
    showView = view;
    if(self.delegate && [self.delegate respondsToSelector:@selector(willPresentActionSheet:)])
        [self.delegate willPresentActionSheet:self];
    
    [self constructViews:view];
    customTabBarController *tabBar = (GET_APP_DELEGATE).ctbc;
    if(!tabBar.tabBar.hidden) {
        [tabBar.view addSubview:self];
        [tabBar.view bringSubviewToFront:self];
    } else {
        [view addSubview:self];
        [view bringSubviewToFront:self];
    }
    [self show:view];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didPresentActionSheet:)])
        [self.delegate didPresentActionSheet:self];
}

- (void)clickedButton:(UIButton *)button {
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
        [self.delegate actionSheet:self clickedButtonAtIndex:button.tag];
    
    if(!self.shouldDismiss) {
        self.shouldDismiss = YES;
        for(id subview in self.subviews) {
            if([subview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrolly = (UIScrollView *)subview;
                [scrolly flashScrollIndicators];
            }
        }
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
        [self.delegate actionSheet:self willDismissWithButtonIndex:button.tag];
    
    [self dismiss:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
                [self.delegate actionSheet:self didDismissWithButtonIndex:button.tag];
        });
    }];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)index {
    for(UIView *subview in viewQueue) {
        if([subview isKindOfClass:[UIButton class]]) {
            UIButton *someButton = (UIButton *)subview;
            if(someButton.tag == index)
                return someButton.titleLabel.text;
        }
    }
    
    return nil;
}

- (NSMutableArray *)getSelectedElements {
    if(self.customContent == nil)
        return nil;
    
    NSMutableArray *selected = [[NSMutableArray alloc] init];
    for(ScrollElementView *element in self.customContent) {
        if([element isElementSelected])
            [selected addObject:element];
    }
    return selected;
}

@end

@implementation ScrollElement

+ (id)title:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag {
    ScrollElement *obj = [[ScrollElement alloc] init];
    obj.title = title;
    obj.image = image;
    obj.tag = tag;
    return obj;
}

+ (id)inviteFriends {
    return [ScrollElement title:@"Invite Friends" image:[UIImage imageWithColor:UNWINE_RED] tag:SCROLL_ELEMENT_INVITE_FRIENDS];
}

+ (id)selectAll {
    return [ScrollElement title:@"Select All" image:[UIImage imageWithColor:UNWINE_RED] tag:SCROLL_ELEMENT_SELECT_ALL];
}

@end

static NSInteger element_buffer = 8;
static NSInteger check_dim = 28;

@implementation ScrollElementView

+ (NSMutableArray *)scrollElementsFrom:(NSArray *)array {
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    if(array == nil)
        return elements;
    
    for(id obj in array) {
        if([obj isKindOfClass:[PFObject class]]) {
            PFObject *object = (PFObject *)obj;
            if([object.parseClassName isEqualToString:[Friendship parseClassName]]) {
                Friendship *friendship = (Friendship *)object;
                [elements addObject:[ScrollElementView makeElementFromUser:[friendship getTheFriend:[User currentUser]]]];
            } else if([object.parseClassName isEqualToString:[User parseClassName]]) {
                [elements addObject:[ScrollElementView makeElementFromUser:(User *)object]];
            }
        } else if([obj isKindOfClass:[ScrollElement class]]) {
            [elements addObject:[ScrollElementView makeElementFromObject:(ScrollElement *)obj]];
        }
    }
    
    return elements;
}

+ (ScrollElementView *)makeElementFromObject:(ScrollElement *)object {
    NSInteger dim = SCREEN_WIDTH / elements_per_page;
    ScrollElementView *element = [[ScrollElementView alloc] initWithFrame:CGRectMake(0, 0, dim, cell_scroll_height)];
    element.tag = object.tag;
    element.object = object;
    element.userInteractionEnabled = YES;
    element.clipsToBounds = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:element action:@selector(tappedElement:)];
    [element addGestureRecognizer:gesture];
    
    [element setupImageView];
    [element.imageView setImage:object.image];
    
    [element setupLabel];
    [element.label setFrame:element.imageView.frame];
    [element.label setText:object.title];
    element.label.numberOfLines = 0;
    [element.label sizeToFit];
    [element.label setFrame:element.imageView.frame];
    
    return element;
}

+ (ScrollElementView *)makeElementFromUser:(User *)user {
    NSInteger dim = SCREEN_WIDTH / elements_per_page;
    ScrollElementView *element = [[ScrollElementView alloc] initWithFrame:CGRectMake(0, 0, dim, cell_scroll_height)];
    element.tag = 0;
    element.object = user;
    element.userInteractionEnabled = YES;
    element.clipsToBounds = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:element action:@selector(tappedElement:)];
    [element addGestureRecognizer:gesture];
    
    [element setupImageView];
    [user setUserImageForImageView:element.imageView];
    
    [element setupLabel];
    [element.label setText:[user getFirstName]];
    
    return element;
}

- (void)setupImageView {
    NSInteger dim = SCREEN_WIDTH / elements_per_page;
    
    _imageView = [[PFImageView alloc] initWithFrame:CGRectMake(element_buffer, element_buffer, dim - element_buffer * 2, dim - element_buffer * 2)];
    
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = SEMIWIDTH(_imageView);
    _imageView.layer.shadowColor = [UNWINE_GRAY CGColor];
    _imageView.layer.shadowOffset = CGSizeMake(0, 1);
    _imageView.layer.shadowOpacity = 1;
    _imageView.layer.shadowRadius = 1;
    
    [self addSubview:_imageView];
}

- (void)setupLabel {
    NSInteger dim = SCREEN_WIDTH / elements_per_page;
    NSInteger labelHeight = cell_scroll_height - dim;
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(2, Y2(_imageView) + HEIGHT(_imageView), WIDTH(self) - 4, labelHeight)];
    
    [_label setTextColor:[UIColor whiteColor]];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont fontWithName:@"OpenSans" size:12]];
    _label.minimumScaleFactor = .5;
    _label.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:_label];
}

- (void)addCheck {
    if(_checkView == nil)
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"acceptIcon"]];
    
    NSInteger brCornerX = X2(_imageView) + WIDTH(_imageView) - element_buffer;
    NSInteger brCornerY = Y2(_imageView) + HEIGHT(_imageView) - element_buffer;
    
    CGFloat scaleDim = check_dim * 4 / 5;
    [_checkView setFrame:CGRectMake(brCornerX - scaleDim / 2, brCornerY - scaleDim / 2, scaleDim, scaleDim)];
    [_checkView setContentMode:UIViewContentModeScaleAspectFit];
    
    if([_checkView superview] == nil)
        [self addSubview:_checkView];
    
    [UIView animateWithDuration:.2 animations:^{
        [_checkView setFrame:CGRectMake(brCornerX - check_dim / 2, brCornerY - check_dim / 2, check_dim, check_dim)];
    }];
}

- (void)removeCheck {
    if(_checkView != nil) {
        NSInteger brCornerX = X2(_imageView) + WIDTH(_imageView) - element_buffer;
        NSInteger brCornerY = Y2(_imageView) + HEIGHT(_imageView) - element_buffer;
        
        [UIView animateWithDuration:.2 animations:^{
            CGFloat scaleDim = check_dim * 3 / 5;
            [_checkView setFrame:CGRectMake(brCornerX - scaleDim / 2, brCornerY - scaleDim / 2, scaleDim, scaleDim)];
        } completion:^(BOOL finished) {
            [_checkView removeFromSuperview];
        }];
    }
}

- (BOOL)isElementSelected {
    return ([_checkView superview] != nil);
}

- (void)tappedElement:(UITapGestureRecognizer *)gesture {
    NSInteger tag = gesture ? [gesture view].tag : 0;
    if(tag == SCROLL_ELEMENT_SELECT_DEFAULT) {
        if([_checkView superview])
            [self removeCheck];
        else
            [self addCheck];
    } else if(tag == SCROLL_ELEMENT_SELECT_ALL) {
        if(_delegate) {
            NSArray *content = [_delegate customContent];
            for(ScrollElementView *view in content)
                if(view != self && view.tag == SCROLL_ELEMENT_SELECT_DEFAULT)
                    [view tappedElement:nil];
        }
    } else if(tag == SCROLL_ELEMENT_INVITE_FRIENDS) {
        [[(GET_APP_DELEGATE).ctbc getProfileVC].profileTable inviteFriends:[self.delegate.delegate actionSheetPresentationViewController]];
    }
}

@end
