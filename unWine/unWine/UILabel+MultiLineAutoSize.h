//
//  UILabel+MultiLineAutoSize.h
//  unWine
//
//  Created by Fabio Gomez on 6/30/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MultiLineAutoSize)
- (void)adjustFontSizeToFit;
- (float)resizeToFit;
- (float)expectedHeight;
@end
