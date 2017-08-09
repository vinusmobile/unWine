//
//  AWDetailCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWDetailCell.h"
#import "CastDetailTVC.h"
#import "MarqueeLabel+Extra.h"
#import "ParseSubclasses.h"

@implementation AWDetailCell
@synthesize delegate, hasSetup, myPath, fieldEditor, accessoryView, editView, canModify;
@synthesize icon, title;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    [super setup:indexPath];
    
    if(!hasSetup) {
        hasSetup = YES;
        
        [self.title setTextColor:[UIColor whiteColor]];
        [self.title setTintColor:[UIColor whiteColor]];
        [self.title setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        
        self.icon.userInteractionEnabled = YES;
        [self.icon setContentMode:UIViewContentModeScaleAspectFit];
        
        CastDetailTVC *parent = (CastDetailTVC *)delegate;
        editView = [[UIView alloc] initWithFrame:parent.navigationController.view.frame];
        editView.backgroundColor = [UIColor darkGrayColor];
        editView.alpha = .6;
        editView.layer.zPosition = 1005;
        editView.userInteractionEnabled = YES;
        [editView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelModify)]];
        
        CGRect frame = CGRectMake(SEMIWIDTH(editView) - FIELD_EDITOR_WIDTH / 2,
                                  108,
                                  FIELD_EDITOR_WIDTH,
                                  FIELD_EDITOR_HEIGHT);
        fieldEditor = [[UIPlaceHolderTextView alloc] initWithFrame:frame];
        fieldEditor.backgroundColor = [UIColor whiteColor];
        [fieldEditor setTextColor:[UIColor blackColor]];
        [fieldEditor setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        fieldEditor.placeholderColor = [UIColor lightTextColor];
        
        fieldEditor.layer.borderWidth = 2;
        fieldEditor.layer.shadowRadius = 2;
        fieldEditor.layer.shadowColor = [ALMOST_BLACK CGColor];
        fieldEditor.layer.borderColor = [[UIColor whiteColor] CGColor];
        fieldEditor.layer.cornerRadius = 8;
        fieldEditor.layer.zPosition = 1006;
        
        fieldEditor.autocapitalizationType = UITextAutocapitalizationTypeWords;
        fieldEditor.returnKeyType = UIReturnKeyDefault;
        fieldEditor.delegate = self;
        
    }
}

- (void) configure:(unWine *)wineObject path:(NSIndexPath *)indexPath {
    [super configure:wineObject];
    myPath = indexPath;
    NSInteger row = indexPath.row;
    
    self.tag = row;
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    //specialButton.userInteractionEnabled = YES;
    
    if(row == 0) {
        self.icon.image = WINERY_ICON;
        if(parent.isNew)
            self.title.text = DEFAULT_ADD_WINERY;
        else if(!ISVALID([wineObject getVineYardName]))
            self.title.text = DEFAULT_NO_WINERY;
        else
            self.title.text = [wineObject getVineYardName];
    } else if(row == 1) {
        self.icon.image = REGION_ICON;
        if(parent.isNew)
            self.title.text = DEFAULT_ADD_REGION;
        else if(!ISVALID(wineObject.region))
            self.title.text = DEFAULT_NO_REGION;
        else
            self.title.text = wineObject.region.capitalizedString;
    } else if(row == 2) {
        self.icon.image = GRAPE_ICON;
        if(parent.isNew)
            self.title.text = DEFAULT_ADD_WINE_TYPE;
        else if(!ISVALID(wineObject.wineType))
            self.title.text = DEFAULT_NO_WINE_TYPE;
        else
            self.title.text = wineObject.wineType.capitalizedString;
        //specialButton.userInteractionEnabled = NO;
    }
    
    if (!parent.lockAllWines && parent.isNew) {
        self.canModify = YES;
    } else {
        self.canModify = [wineObject isEditable];
    }
    
    if([[User currentUser] isAnonymous])
        self.canModify = NO;
}

- (void)modifyField {
    NSString *debug = [NSString stringWithFormat:@"Can modify = %@", canModify ? @"Yes": @"No"];
    LOGGER(debug);
    
    if(!canModify)
        return;
    
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    editView.alpha = 0;
    fieldEditor.alpha = 0;
    [parent.navigationController.view addSubview:editView];
    [parent.navigationController.view bringSubviewToFront:editView];
    [parent.navigationController.view addSubview:fieldEditor];
    [parent.navigationController.view bringSubviewToFront:fieldEditor];
    
    NSInteger tag = self.tag;//[(UIButton *)sender tag];
    
    [UIView animateWithDuration:.15 animations:^{
        editView.alpha = .6;
        fieldEditor.alpha = 1;
    } completion:^(BOOL finished) {
        fieldEditor.tag = tag;
        
        if(tag == 0) {
            fieldEditor.placeholder = DEFAULT_ADD_WINERY;
            if(![self.title.text isEqualToString:DEFAULT_ADD_WINERY] && ![self.title.text isEqualToString:DEFAULT_NO_WINERY])
                fieldEditor.text = self.title.text;
            else
                fieldEditor.text = @"";
        } else if(tag == 1) {
            fieldEditor.placeholder = DEFAULT_ADD_REGION;
            if(![self.title.text isEqualToString:DEFAULT_ADD_REGION] && ![self.title.text isEqualToString:DEFAULT_NO_REGION])
                fieldEditor.text = self.title.text;
            else
                fieldEditor.text = @"";
        } else if(tag == 2) {
            fieldEditor.placeholder = DEFAULT_ADD_WINE_TYPE;
            if(![self.title.text isEqualToString:DEFAULT_ADD_WINE_TYPE] && ![self.title.text isEqualToString:DEFAULT_NO_WINE_TYPE])
                fieldEditor.text = self.title.text;
            else
                fieldEditor.text = @"";
        }
        
        [fieldEditor becomeFirstResponder];
    }];
}

- (void)completeModify {
    NSString *text = [fieldEditor.text lowercaseString];
    if(![text isEqualToString:@""] && ![text isEqualToString:[self.title.text lowercaseString]]) {
        
        self.title.text = text.capitalizedString;
        CastDetailTVC *parent = (CastDetailTVC *)delegate;
        if(fieldEditor.tag == 0)
            [parent registerRecord:@"vineyard" asValue:text];
        else if(fieldEditor.tag == 1)
            [parent registerRecord:@"region" asValue:text];
        else if(fieldEditor.tag == 2)
            [parent registerRecord:@"wineType" asValue:text];
    }
    
    [super completeModify];
}

- (void)cancelModify {
    [super cancelModify];
}

@end
