//
//  AWHeaderCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWHeaderCell.h"
#import "CastDetailTVC.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>

@implementation AWHeaderCell {
    UILabel *addPhotoLabel;
}
@synthesize delegate, hasSetup, myPath, fieldEditor, accessoryView, editView, canModify;
@synthesize wineImageView, nameLabel, verifiedView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    [super setup:indexPath];
    
    if(!hasSetup) {
        hasSetup = YES;
        
        verifiedView.backgroundColor = [UIColor clearColor];
        verifiedView.layer.borderWidth = 0;
        verifiedView.clipsToBounds = YES;
        [verifiedView setContentMode:UIViewContentModeScaleAspectFill];
        
        self.wineImageView.backgroundColor = UNWINE_RED;
        self.wineImageView.layer.borderWidth = 2;
        self.wineImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.wineImageView.layer.cornerRadius = 6;
        self.wineImageView.layer.masksToBounds = YES;
        self.wineImageView.clipsToBounds = YES;
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
        self.wineImageView.userInteractionEnabled = YES;
        [self.wineImageView addGestureRecognizer:gesture1];
        
        addPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(SEMIWIDTH(self.wineImageView) - 60,
                                                                  .70 * HEIGHT(self.wineImageView),
                                                                  120,
                                                                  30)];
        addPhotoLabel.backgroundColor = [UIColor clearColor];
        [addPhotoLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [addPhotoLabel setTextColor:[UIColor whiteColor]];
        [addPhotoLabel setTextAlignment:NSTextAlignmentCenter];
        [addPhotoLabel setText:@"Add Photo"];
        addPhotoLabel.shadowColor = [UIColor darkGrayColor];
        addPhotoLabel.shadowOffset = CGSizeMake(0, 1);
        [self.wineImageView addSubview:addPhotoLabel];
        
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifyField:)];
        nameLabel.tag = 1;
        nameLabel.userInteractionEnabled = YES;
        [nameLabel addGestureRecognizer:gesture2];
        
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

- (void) configure:(unWine *)wineObject {
    [super configure:wineObject];
    
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    
    //__block UIImage *image;
    
    if([wineObject getImageURL] != nil) {
        
        [wineObject setWineImageForImageView:self.wineImageView];
        addPhotoLabel.alpha = 0;
        
        if (!parent.isNew)
            [self.wineImageView setContentMode:UIViewContentModeScaleAspectFit];
        else
            [self.wineImageView setContentMode:UIViewContentModeCenter];
        
    } else {
        if(parent.isNew) {
            [addPhotoLabel setTextColor:[UIColor whiteColor]];
            [self.wineImageView setImage:ADD_WINE_PLACEHOLDER];
            [self.wineImageView setContentMode:UIViewContentModeCenter];
        } else {
            [addPhotoLabel setTextColor:UNWINE_RED];
            [self.wineImageView setImage:VINECAST_PLACEHOLDER];
            [self.wineImageView setContentMode:UIViewContentModeScaleAspectFit];
        }
        
        addPhotoLabel.alpha = 1;
    }
    
    if (!parent.lockAllWines && parent.isNew) {
        self.canModify = YES;
    } else {
        self.canModify = [wineObject isEditable];
    }
    
    if([[User currentUser] isAnonymous])
        self.canModify = NO;
    
    if(!self.canModify) {
        if([self.wineImageView.image isEqual:ADD_WINE_PLACEHOLDER]) {
            [self.wineImageView setImage:VINECAST_PLACEHOLDER];
            [addPhotoLabel setTextColor:UNWINE_RED];
        }
        addPhotoLabel.alpha = 0;
    }
    
    NSString *wineName = [wineObject getWineName];
    
    nameLabel.text = ISVALID(wineName)? wineName: DEFAULT_WINE_NAME;
    [nameLabel sizeToFit];
    [self configureVerified:wineObject];
}

- (void)configureVerified:(unWine *)wineObject {
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    if(parent.checkinForWeathered == -1 || parent.checkinForVerification == -1)
        return;
    
    [wineObject checkIfVerified];
    
    if(wineObject.checkinCount > parent.checkinForWeathered) {
        [verifiedView setImage:[UIImage imageNamed:@"verifiedWeathered"]];
        [verifiedView setHidden:NO];
    } else if(wineObject.checkinCount > parent.checkinForVerification) {
        [verifiedView setImage:[UIImage imageNamed:@"verifiedIcon"]];
        [verifiedView setHidden:NO];
    } else if(wineObject.verified) {
        [verifiedView setImage:[UIImage imageNamed:@"verifiedIcon"]];
        [verifiedView setHidden:NO];
    } else
        [verifiedView setHidden:YES];
}

- (void)modifyField:(UITapGestureRecognizer *)gesture {
    if(!self.canModify)
        return;
    
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    editView.alpha = 0;
    fieldEditor.alpha = 0;
    [parent.navigationController.view addSubview:editView];
    [parent.navigationController.view bringSubviewToFront:editView];
    [parent.navigationController.view addSubview:fieldEditor];
    [parent.navigationController.view bringSubviewToFront:fieldEditor];
    
    NSInteger tag = [[gesture view] tag];
    
    [UIView animateWithDuration:.15 animations:^{
        editView.alpha = .6;
        fieldEditor.alpha = 1;
    } completion:^(BOOL finished) {
        fieldEditor.tag = tag;
        
        if(tag == 1) {
            if(![nameLabel.text isEqualToString:DEFAULT_WINE_NAME])
                fieldEditor.text = nameLabel.text;
            else
                fieldEditor.text = @"";
        }
        
        [fieldEditor becomeFirstResponder];
    }];
}

- (void)completeModify {
    NSString *text = [fieldEditor.text lowercaseString];
    if(![text isEqualToString:@""] && ![text isEqualToString:[nameLabel.text lowercaseString]]) {
        nameLabel.text = fieldEditor.text;
        
        CastDetailTVC *parent = (CastDetailTVC *)delegate;
        
        // Save the text as is in the "capitalizedName", then we can lowercase "name" in cloud code beforeSave
        [parent registerRecord:@"capitalizedName" asValue:fieldEditor.text];
    }
    
    [super completeModify];
}

- (void)selectedPhoto:(UIImage *)image {
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    
    [self.wineImageView setImage:image];
    [self.wineImageView setContentMode:UIViewContentModeScaleAspectFit];
    addPhotoLabel.alpha = 0;
    
    SHOW_HUD_FOR_VIEW(parent.navigationController.view);
    parent.wineImage = [UIImage imageWithCGImage:[image CGImage]];
    NSMutableArray *taskArray = [[NSMutableArray alloc] init];
    
    NSData *imageData = UIImageJPEGRepresentation(image, .8);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    [taskArray addObject:[imageFile saveInBackground]];
    
    UIImage *thumbnail = [AWCell imageWithImage:image scaledToSize:CGSizeMake(MIN(300, image.size.width), MIN(300, image.size.height))];
    NSData *imageDataThumb = UIImageJPEGRepresentation(thumbnail, .6);
    PFFile *imageFileThumb = [PFFile fileWithName:@"Thumbnail.jpg" data:imageDataThumb];
    [taskArray addObject:[imageFileThumb saveInBackground]];
    
    [[BFTask taskForCompletionOfAllTasksWithResults:taskArray] continueWithBlock:^id(BFTask *task) {
        HIDE_HUD_FOR_VIEW(parent.navigationController.view);
        
        if (task.error) {
            LOGGER(task.error);
            [unWineAlertView showAlertViewWithTitle:nil error:task.error];
            
            return nil;
        }
        
        LOGGER(@"Successfully uploaded image and its thumbnail");
        
        [parent registerRecord:@"image" asValue:imageFile];
        [parent registerRecord:@"thumbnail" asValue:imageFileThumb];
        
        return nil;
    }];
    
    
}

- (void)tapImage {
    CastDetailTVC *parent = (CastDetailTVC *)delegate;
    
    if(self.canModify) {
        UIStoryboard *camera = [UIStoryboard storyboardWithName:@"castCamera" bundle:nil];
        UINavigationController *base = [camera instantiateInitialViewController];
        
        APLViewController *view = [base.viewControllers objectAtIndex:0];
        view.delegate = self;
        
        [parent presentViewController:base animated:YES completion:nil];
        
        view.view.alpha = 1;
        [view.imageView setImage:addPhotoLabel.alpha == 0 ? self.wineImageView.image : VINECAST_PLACEHOLDER];
        [view.imageView setContentMode:UIViewContentModeScaleAspectFit];
    } else {
        [parent checkIn];
    }
}

- (void)cancelModify {
    [super cancelModify];
}

@end
