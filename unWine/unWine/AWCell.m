//
//  AWCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWCell.h"
#import "CastDetailTVC.h"

@implementation AWCell
@synthesize wine, myPath, canModify;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setup:(NSIndexPath *)indexPath {
    myPath = indexPath;
}

- (void) configure:(unWine *)wineObject {
    self.wine = wineObject;
}

- (void)dismiss {
    [self.fieldEditor resignFirstResponder];
}

- (void)modifyField:(UITapGestureRecognizer *)gesture {
}

- (void)hideEditView {
    [UIView animateWithDuration:.15 animations:^{
        self.editView.alpha = 0;
        self.fieldEditor.alpha = 0;
    } completion:^(BOOL finished) {
        [self.editView removeFromSuperview];
        [self.fieldEditor removeFromSuperview];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"])
        return NO;
    
    return YES;
}

- (void)completeModify {
    [self.fieldEditor resignFirstResponder];
    [self hideEditView];
}

- (void)cancelModify {
    [self.fieldEditor resignFirstResponder];
    [self hideEditView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self), 48)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.tintColor = UNWINE_RED;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelModify)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(completeModify)],
                           nil];
    [numberToolbar sizeToFit];
    self.fieldEditor.autocorrectionType = UITextAutocorrectionTypeNo;
    self.fieldEditor.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.fieldEditor.inputAccessoryView = numberToolbar;
    
    return YES;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
