//
//  PhotoNameCell.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "PhotoNameCell.h"
#import "RegistrationTVC.h"
#import "ActionSheetPicker.h"
#import "ParseSubclasses.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImage-JTColor.h"

#define ADD_PHOTO_LABEL_TAG 1515

@interface PhotoNameCell () <UIGestureRecognizerDelegate, ActionSheetCustomPickerDelegate, UITextViewDelegate>
@property (nonatomic, strong) RegistrationTVC *parent;
@end

@implementation PhotoNameCell

@synthesize parent, photoView, nameTextView;

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.nameTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextView.backgroundColor = [UIColor clearColor];
    self.nameTextView.textColor = [UIColor whiteColor];
    self.nameTextView.font = UNWINE_FONT_TEXT_XSMALL;
    
    self.photoView.layer.cornerRadius = 5;
    self.photoView.clipsToBounds = YES;
    self.photoView.layer.borderWidth = 0.5;
    self.photoView.layer.borderColor = CELL_TEXT_BACKGROUND_COLOR.CGColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addPhotoLabelToImage {
    
    if ([self.photoView viewWithTag:ADD_PHOTO_LABEL_TAG]) {
        return;
    }
    
    UILabel *addPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(SEMIWIDTH(self.photoView) - 60,
                                                                       .70 * HEIGHT(self.photoView),
                                                                       120,
                                                                       30)];
    addPhotoLabel.tag = ADD_PHOTO_LABEL_TAG;
    addPhotoLabel.backgroundColor = [UIColor clearColor];
    [addPhotoLabel setFont:UNWINE_FONT_TEXT_XSMALL];
    [addPhotoLabel setTextColor:[UIColor whiteColor]];
    [addPhotoLabel setTextAlignment:NSTextAlignmentCenter];
    [addPhotoLabel setText:@"Add Photo"];
    
    [self.photoView addSubview:addPhotoLabel];
}

- (void)removeAddPhotoLabel {
    UILabel *addPhotoLabel = (UILabel *)[self.photoView viewWithTag:ADD_PHOTO_LABEL_TAG];
    
    [addPhotoLabel removeFromSuperview];
}

- (void)setUpWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    self.nameTextView.placeholder = @"John Smith";
    self.nameTextView.delegate = self;
    //self.nameTextView.returnKeyType = UIReturnKeyDone;
    
    self.nameTextView.textColor = [UIColor whiteColor];
    self.nameTextView.text = self.parent.form[FORM_NAME] ? self.parent.form[FORM_NAME] : @"";
    
  
    UIImage *defaultImage = [UIImage imageWithColor:[UIColor darkGrayColor]];
    [self addPhotoLabelToImage];
    
    
    if (self.parent.form[FORM_FB_URL]) {
        LOGGER(@"Loading Facebook Photo");
        [self.photoView setImageWithURL:[NSURL URLWithString:self.parent.form[FORM_FB_URL]] placeholderImage:defaultImage];
        [self removeAddPhotoLabel];
    } else if (self.parent.form[FORM_PHOTO]) {
        if ([self.parent.form[FORM_PHOTO] isKindOfClass:[PFFile class]]) {
            LOGGER(@"Using PFFile");
            self.photoView.file = self.parent.form[FORM_PHOTO];
            self.photoView.image = defaultImage;
            [self.photoView loadInBackground];
            [self removeAddPhotoLabel];
        } else {
            LOGGER(@"Using Regular Image");
            self.photoView.image = self.parent.form[FORM_PHOTO];
            [self removeAddPhotoLabel];
        }
    } else {
        LOGGER(@"Using Placeholder");
        self.photoView.image = defaultImage;
        [self addPhotoLabelToImage];
    }
    
    
    
    
    
    
    self.photoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePicker)];
    gesture.numberOfTapsRequired = 1;
    
    [self.photoView addGestureRecognizer:gesture];
    
    gesture.delegate = self;
}

/*

- (void)loadFacebookPhoto {
    if (self.facebookPhotoURL) {
        LOGGER(@"Loading Facebook Photo");
        [self.photoView setImageWithURL:[NSURL URLWithString:self.facebookPhotoURL] placeholderImage:USER_PLACEHOLDER];
        self.parent.form[FORM_FB_URL] = self.facebookPhotoURL;
        [self.parent.form removeObjectForKey:FORM_PHOTO];
    } else {
        LOGGER(@"Please set Facebook Photo URL");
    }
}

 */


/*
- (void)setPhotoViewWithImage:(UIImage *)image {
    if (image) {
        self.photoView.image = image;
    }
}
 */

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    //NSLog(@"shouldChangeCharactersInRange");
    //NSLog(@"location = %lu, length = %lu", (unsigned long)range.location, (unsigned long)range.length);
    //NSLog(@"replacementString = %@", string);
    
    if ([string isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    
    NSMutableString *str = [NSMutableString stringWithString:textView.text];
    
    if ([string isEqualToString:@""]) {
        [str deleteCharactersInRange:NSMakeRange(range.location, range.length)];
    } else if ([string isEqualToString:@"\n"] == NO) {
        [str insertString:string atIndex:range.location];
    }
    
    //NSLog(@"theText = \"%@\"", str);
    
    if (str.length > 50) {
        return NO;
    }
    
    self.parent.form[FORM_NAME] = str;
    // Save string here in case the cell goes out of view
    
    
    
    return YES;
}

static NSString *dialogTakePhoto = @"Take a Photo";
static NSString *dialogChoosePhoto = @"Choose a Photo";
static NSString *dialogImportFacebook = @"Import Facebook Photo";

- (void)showImagePicker {
    NSArray *buttons = ([[User currentUser] hasFacebook] && self.parent.mode == EDIT_MODE)
    ? @[dialogTakePhoto, dialogChoosePhoto, dialogImportFacebook]
    : @[dialogTakePhoto, dialogChoosePhoto];
    
    unWineActionSheet *action = [[unWineActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:buttons];
    
    [action showFromTabBar:self.parent.navigationController.view];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogTakePhoto]) {
        [self.parent showImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogChoosePhoto]) {
        [self.parent showImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogImportFacebook]) {
        self.parent.form[FORM_FB_URL] = [[User currentUser] getFacebookImageURL];
        [self.parent.form removeObjectForKey:FORM_PHOTO];
        [self setUpWithParent:self.parent];
    }
}


- (UIViewController *)actionSheetPresentationViewController {
    return self.parent;
}

@end
