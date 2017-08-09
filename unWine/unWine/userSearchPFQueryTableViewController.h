//
//  userSearchPFQueryTableViewController.h
//  unWine
//
//  Created by Fabio Gomez on 4/28/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface userSearchPFQueryTableViewController : PFQueryTableViewController<UISearchBarDelegate>

@property (strong, nonatomic) NSString *gSearchString;


@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


@end
