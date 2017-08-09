//
//  venueCell.h
//  unWine
//
//  Created by Anggi Arlandi Priatmadi on 1/14/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface venueCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *venueName;
@property (weak, nonatomic) IBOutlet UILabel *venueLocation;
@property (weak, nonatomic) IBOutlet UIImageView *venueIcon;

@end
