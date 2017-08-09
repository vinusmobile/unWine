//
//  CICellar.m
//  unWine
//
//  Created by Fabio Gomez on 10/13/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CICellarCell.h"
#import "CastCheckinTVC.h"
#import "ParseSubclasses.h"

#define ADD_WISH_LIST @"Add to Wish List"
#define REMOVE_WISH_LIST @"Remove from Wish List"
#define PENDING_WISH_LIST REMOVE_WISH_LIST


@implementation CICellarCell

//@"Pending Checkin"

@synthesize hasSetup, myPath, fieldEditor, accessoryView, editView, canModify, wine;
@synthesize lastEdit, basicLabel, cellarButton;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    [super setup:indexPath];
    
    if(!hasSetup) {
        hasSetup = YES;
        
        basicLabel.backgroundColor = [UIColor clearColor];
        basicLabel.textColor = [UIColor whiteColor];
        
        cellarButton.backgroundColor = [UIColor whiteColor];
        cellarButton.layer.borderWidth = 2;
        cellarButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        cellarButton.layer.cornerRadius = 6;
        cellarButton.layer.masksToBounds = YES;
        cellarButton.clipsToBounds = YES;
        [cellarButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
        
        lastEdit.backgroundColor = [UIColor clearColor];
        [lastEdit setTintColor:[UIColor whiteColor]];
        [lastEdit setImage:SMALL_COG_ICON forState:UIControlStateNormal];
        [lastEdit.imageView setTintColor:[UIColor whiteColor]];
        [lastEdit.titleLabel setTextAlignment:NSTextAlignmentCenter];
        //[lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"N/A"] forState:UIControlStateNormal];
        [lastEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lastEdit setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (void)configure:(unWine *)wineObject {
    [super configure:wineObject];
    self.wine = wineObject;
    User *user = [User currentUser];
    
    if([user hasCellar]) {
        for(NSString *objectId in user.cellar) {
            [user.theCellar addObject:[PFObject objectWithoutDataWithClassName:[unWine parseClassName] objectId:objectId]];
        }
        user.cellar = [[NSMutableArray alloc] init];
        [user saveInBackground];
    }
    
    [self configureCellarButton];
}

- (void)configureCellarButton {
    User *user = [User currentUser];
    [[user hasWineInWishList:self.wine] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        
        BOOL inWishList = t.result.boolValue;
        [cellarButton setTitle:(inWishList ? REMOVE_WISH_LIST : ADD_WISH_LIST)
                      forState:UIControlStateNormal];
        
        return nil;
    }];
}


- (IBAction)cellarIt:(id)sender {
    CastDetailTVC *parent = (CastDetailTVC *)self.delegate;
    User *user = [User currentUser];
    
    if ([user isAnonymous]) {
        [user promptGuest:parent];
        return;
    }
    
    if (parent.isNew) {
        cellarButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self configureCellarButton];
        return;
    }
    
    BFTask *wishlistTask = nil;
    
    if ([cellarButton.titleLabel.text isEqualToString:ADD_WISH_LIST]) {
        LOGGER(@"Adding wine to wish list");
        wishlistTask = [user addWineToCellar:self.wine];
    } else {
        LOGGER(@"Removing wine from wish list");
        wishlistTask = [user removeWineFromCellar:self.wine];
    }
    
    [wishlistTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something went wrong adding/removing wine from wish list");
            LOGGER(t.error);
            
        } if ([cellarButton.titleLabel.text isEqualToString:ADD_WISH_LIST]) {
            LOGGER(@"Added wine to wish list");
            [cellarButton setTitle:REMOVE_WISH_LIST forState:UIControlStateNormal];
            
        } else {
            LOGGER(@"Removed wine from wish list");
            [cellarButton setTitle:ADD_WISH_LIST forState:UIControlStateNormal];
        }
        
        return nil;
    }];
}

@end
