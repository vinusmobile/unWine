

@interface UIPlaceHolderTextView : UITextView <UITextViewDelegate>

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic) NSInteger maximumLength;

-(void)textChanged:(NSNotification*)notification;

@end