//
//  PartnerCell.h
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface PartnerCell : PFTableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end
