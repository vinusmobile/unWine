//
//  ContactsInviteTVC.m
//  unWine
//
//  Created by Fabio Gomez on 6/12/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "ContactsInviteTVC.h"
#import "UITableViewController+Helper.h"
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>
#import <APAddressBook/APPhone.h>
#import <APAddressBook/APEmail.h>
#import "ContactInviteCell.h"
#import "InviteOrAddAllCell.h"
#import "unWineActionSheet.h"
#import "UIViewController+Social.h"
@interface ContactsInviteTVC () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray <APContact *> *contacts;
@property (nonatomic, strong) NSMutableArray <User *> *unWineUsers;
@property (nonatomic, strong) NSMutableArray <APContact *> *nonUnWineUsers;

@property (nonatomic, strong) NSMutableArray <User *> *filteredUsers;
@property (nonatomic, strong) NSMutableArray <APContact *> *filteredNonUsers;

@property (nonatomic, strong) UIView *resultsView;
@property (nonatomic,       ) BOOL isSearching;
@property (nonatomic, strong) ContactInviteCell *senderCell;
@property (nonatomic, strong) InviteOrAddAllCell *addAllHeader;
@property (nonatomic, strong) InviteOrAddAllCell *inviteAllHeader;
@property (nonatomic, strong) NSMutableDictionary *sendDictionary;

@end

NSString *kContactInviteCellIdentifier = @"ContactInviteCell";
NSString *kInviteAllCellIdentifier = @"InviteAllCell";
NSString *kAddAllCellIdentifier = @"AddAllCell";

@implementation ContactsInviteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UNWINE_WHITE_BACK;
    self.contacts = [[NSMutableArray alloc] init];
    self.unWineUsers = [[NSMutableArray alloc] init];
    self.nonUnWineUsers = [[NSMutableArray alloc] init];
    self.filteredUsers = [[NSMutableArray alloc] init];
    self.filteredNonUsers = [[NSMutableArray alloc] init];

    //self.tableView.separatorColor = [UIColor clearColor];
    //[self.tableView registerClass:[ContactInviteCell class] forCellReuseIdentifier:kContactInviteCellIdentifier];
    [self basicAppeareanceSetup];
    [self setUpSearchBar];
    [self loadContacts];
}

#pragma mark - Contacts stuff

- (void)loadContacts {
    SHOW_HUD.label.text = @"Looking for unWiners... 🔍";
    [[[self getContacts] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<APContact *> *> * _Nonnull t) {
        
        self.contacts = [[NSMutableArray alloc] initWithArray:t.result];
        NSString *s = [NSString stringWithFormat:@"Found %li contacts", self.contacts.count];
        LOGGER(s);
        
        
        return self.contacts.count > 0 ? [self findUnWineUsers:self.contacts] : [BFTask taskWithResult:@[]];
    
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask <NSArray *>* _Nonnull t) {
        HIDE_HUD;
        if (t.result.count > 0) {
            [self.unWineUsers removeAllObjects];
            [self.nonUnWineUsers removeAllObjects];
            
            for (int i=0; i<t.result.count; i++) {
                id c = [t.result objectAtIndex:i];
                
                if ([c isKindOfClass:[User class]]) {
                    if ([c isTheCurrentUser]) {
                        LOGGER(@"Ignoring current user");
                        continue;
                    }

                    [self.unWineUsers addObject:(User *)c];
                    
                } else if ([c isKindOfClass:[APContact class]]) {
                    [self.nonUnWineUsers addObject:(APContact *)c];
                    
                } else {
                    NSString *s = [NSString stringWithFormat:@"Leftover Object of class %@ at index %i", [c class], i];
                    LOGGER(s);
                }
            }
            [self.tableView reloadData];
            
        } else if (t.result.count == 0) {
            [unWineAlertView showAlertViewWithTitle:@"Spilled some wine!" message:@"For some reason, we couldn't load your contacts" theme:unWineAlertThemeError];
        } else if (t.error) {
            [Analytics trackError:t.error withName:@"Error loading contacts" withMessage:@"Something happened"];
            [unWineAlertView showAlertViewWithTitle:@"Spilled some wine!" error:t.error];
        }
        
        return nil;
    }];
}

- (BFTask <NSArray <APContact *> *> *)getContacts {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    // Get contacts
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    addressBook.fieldsMask = APContactFieldAll;
    addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.phones.count > 0;
    };
    
    addressBook.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES]
                                    ];

    [addressBook loadContacts:^(NSArray <APContact *> *contacts, NSError *error) {
        // hide activity
        if (!error) {
            // do something with contacts array
            NSString *s = [NSString stringWithFormat:@"Have %lu contacts", contacts.count];
            LOGGER(s);
            [theTask setResult:[contacts copy]];
            
        } else {
            // show error
            LOGGER(@"Something hapened while getting contacts");
            LOGGER(error);
            [theTask setError:error];
        }
    }];
    
    return theTask.task;
}

- (BFTask <NSArray *> *)findUnWineUsers:(NSArray <APContact *> *)contacts {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    BFTask *orTask = nil;
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    for (APContact *c in contacts) {
        //if (c.emails.count > 1) {
        [tasks addObject:[self findUnWineUserWithContact:c]];
        //}
    }
    
    orTask = (tasks.count > 0) ? [BFTask taskForCompletionOfAllTasksWithResults:tasks] : [BFTask taskWithResult:@[]];
    
    [orTask continueWithBlock:^id _Nullable(BFTask <NSArray *>* _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something happened when finding unWineUsers");
            
            [theTask setError:t.error];
            return nil;
        }
        
        // Loop through results and
        NSString *s = [NSString stringWithFormat:@"Found %lu friends in unWine from contacts with potential nulls", ((NSArray *)t.result).count];
        LOGGER(s);
        
        NSMutableArray *results = [[NSMutableArray alloc] initWithArray:t.result];
        [results removeObjectIdenticalTo:[NSNull null]];

        s = [NSString stringWithFormat:@"Found %lu friends in unWine from contacts after removing potential nulls", results.count];
        LOGGER(s);
        
        [theTask setResult:results];
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask <User *>*)findUnWineUserWithContact:(APContact *)c {
    if (c.emails == nil || (c.emails && c.emails.count == 0) ) {
        return [BFTask taskWithResult:c];
    }
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    for (APEmail *email in c.emails) {
        [tasks addObject:[self findUserWithEmail:email.address]];
    }
    
    [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSMutableArray *results = [[NSMutableArray alloc] initWithArray:(NSArray *)t.result];
        [results removeObjectIdenticalTo:[NSNull null]];

        if (t.error || (results && results.count < 1)) {
            //NSString *s = [NSString stringWithFormat:@"Something happened when finding unWine user with contact \"%@\"", c.name.compositeName];
            //LOGGER(s);
            [theTask setResult:c];
        
        } else if (results.count > 0) {
            User *user = nil;
            for (int i=0; i<results.count; i++) {
                id usr = [results objectAtIndex:i];
                if ([usr isKindOfClass:[User class]]) {
                    user = (User *)usr;
                    break;
                }
            }
            
            if (user) {
                [theTask setResult:user];
                
            } else {
                [theTask setResult:c];
            }
            
        } else {
            [theTask setResult:c];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)findUserWithEmail:(NSString *)contactEmail {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block User *usr = nil;
    PFQuery *query = [User query];
    [query whereKey:@"email" equalTo:contactEmail];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    
    [[[[query getFirstObjectInBackground] continueWithSuccessBlock:^id _Nullable(BFTask <User *>* _Nonnull t) {
        BFTask *task = nil;
        LOGGER(@"Checking if current user");

        if ([t.result isTheCurrentUser]) {
            LOGGER(@"It is the currentUser");
            task = [BFTask taskWithError:[NSError errorWithDomain:@"Current User" code:1 userInfo:nil]];
        } else {
            LOGGER(@"Checking that the user is friends with current user");
            usr = t.result;
            task = [[User currentUser] isFriendsWithUser:usr];
        }
        
        return task;
        
    }] continueWithBlock:^id _Nullable(BFTask <NSNumber *>* _Nonnull t) {
        BFTask *task = nil;
        
        if (t.result.boolValue == TRUE) {
            LOGGER(@"User is friends with current user. Returning nil");
            task = [BFTask taskWithResult:nil];
            
        } else {
            LOGGER(@"User is NOT friends with current user");
            task = [BFTask taskWithResult:usr];
        }
        
        return task;
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            //NSString *s = [NSString stringWithFormat:@"Something happened finding user with email \"%@\". Error:\n%@", contactEmail, t.error];
            //LOGGER(s);
            if (t.error.code != kPFErrorCacheMiss) {
                [theTask setResult:[NSNull null]];
            } else {
                LOGGER(@"Cache Miss Error");
            }
            
        } else if (t.result == nil) {
            NSString *s = [NSString stringWithFormat:@"Could not find user with email \"%@\".", contactEmail];
            LOGGER(s);
            [theTask setResult:[NSNull null]];
            
        } else {
            User *usr = (User *)t.result;
            NSString *s = [NSString stringWithFormat:@"Found user with name \"%@\" and objectId \"%@\"", usr.canonicalName, usr.objectId];
            LOGGER(s);
            
            [theTask setResult:usr];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

#pragma mark - Search Controller stuff

- (void)setUpSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    self.searchBar.placeholder = @"Search contacts by name or email";
    self.searchBar.barTintColor = UNWINE_WHITE_BACK;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    for (id object in [[[self.searchBar subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            UITextField *textFieldObject = (UITextField *)object;
            textFieldObject.layer.masksToBounds = YES;
            textFieldObject.layer.borderColor = [[UIColor grayColor] CGColor];
            textFieldObject.layer.borderWidth = 0.5f;
            textFieldObject.layer.cornerRadius = 3.f;
            break;
        }
    }
    
    //self.searchBar.layer.borderColor = UNWINE_GRAY_LIGHT.CGColor;
    //self.searchBar.layer.borderWidth = 0.5f;
    //self.searchBar.layer.cornerRadius = 3.f;
    self.searchBar.layer.borderColor = [UIColor clearColor].CGColor;
    
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setDelegate:self];
    [self setUpToolbar];
    
    self.tableView.tableHeaderView = self.searchBar;
    //self.tableView.tableHeaderView.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setUpToolbar {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.searchBar action:@selector(resignFirstResponder)];
    barButton.tintColor = UNWINE_RED;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    self.searchBar.inputAccessoryView = toolbar;
}

// Actual logic
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText length] != 0) {
        LOGGER(@"Text DID change");
        self.isSearching = YES;
        [self filterContacts];

    } else {
        LOGGER(@"Text did not change");
        self.isSearching = NO;
        [self.filteredUsers removeAllObjects];
        [self.filteredNonUsers removeAllObjects];
        //[self.view endEditing:YES];
        [self.tableView reloadData];
    }
    
    //[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    LOGGER(@"Enter");
    [self filterContacts];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    LOGGER(@"Enter");
    [self.filteredUsers removeAllObjects];
    [self.filteredNonUsers removeAllObjects];
    self.isSearching = NO;
    [self.tableView reloadData];
}

- (void)filterContacts {
    LOGGER(@"Enter");
    [self.filteredUsers removeAllObjects];
    [self.filteredNonUsers removeAllObjects];
    
    if(![self.searchBar.text isEqualToString:@""]) {
        for(User *c in self.unWineUsers) {
            if ([c isTheCurrentUser]) {
                LOGGER(@"Ignoring current user");
                continue;
            }
            
            NSString *name = [c getName];
            NSString *email = c.email;
            
            if (ISVALID(name) && [name.lowercaseString containsString:[self.searchBar.text lowercaseString]]) {
                NSString *s = [NSString stringWithFormat:@"unWine Users - Adding contact \"%@\" by name", name];
                LOGGER(s);
                [self.filteredUsers addObject:c];
                continue;
            }
            
            if (ISVALID(email) && [email.lowercaseString containsString:[self.searchBar.text lowercaseString]]) {
                NSString *s = [NSString stringWithFormat:@"unWine Users - Adding contact \"%@\" by email %@", name, email];
                LOGGER(s);
                [self.filteredUsers addObject:c];
                break;
            }
        }

        for(APContact *c in self.nonUnWineUsers) {
            if ([c.name.compositeName.lowercaseString containsString:[self.searchBar.text lowercaseString]]) {
                NSString *s = [NSString stringWithFormat:@"Non unWine Users - Adding contact \"%@\" by name", c.name.compositeName];
                LOGGER(s);
                [self.filteredNonUsers addObject:c];
                continue;
            }
            
            for (APEmail *email in c.emails) {
                if ([email.address.lowercaseString containsString:[self.searchBar.text lowercaseString]]) {
                    NSString *s = [NSString stringWithFormat:@"Non unWine Users - Adding contact \"%@\" by email \"%@\"", c.name.compositeName, email.address];
                    LOGGER(s);
                    [self.filteredNonUsers addObject:c];
                    break;
                }
            }
        }
        NSString *s = [NSString stringWithFormat:@"Found %lu filtered users and %lu filtered nonUsers", (unsigned long)self.filteredUsers.count, (unsigned long)self.filteredNonUsers];
        LOGGER(s);
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view UI stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
    
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.isSearching) {
        if (section == 0) {
            count = self.filteredUsers.count;
        } else {
            count = self.filteredNonUsers.count;
        }
    } else {
        if (section == 0) {
            count = self.unWineUsers.count;
        } else {
            count = self.nonUnWineUsers.count;
        }
    }
    
    return count;
}
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isSearching == YES) {
        return nil;
    }
    
    UIView *view = nil;
    
    if (section == 0) {
        self.addAllHeader = [tableView dequeueReusableCellWithIdentifier:kAddAllCellIdentifier];
        self.addAllHeader.delegate = self;
        self.addAllHeader.tag = INVITE_CELL_ADD_ALL;
        
        if (self.unWineUsers && self.unWineUsers.count > 0) {
            self.addAllHeader.inviteLabel.text = [NSString stringWithFormat:@"%lu friends in your contacts", (unsigned long)self.unWineUsers.count];
        }
        
        // Check if userdefaults
        //[self checkIfAllUnWineUsersAdded];
        
        view = self.addAllHeader;

    } else if (section == 1) {
        self.inviteAllHeader = [tableView dequeueReusableCellWithIdentifier:kInviteAllCellIdentifier];
        self.inviteAllHeader.delegate = self;
        self.inviteAllHeader.tag = INVITE_CELL_INVITE_ALL;
        view = self.inviteAllHeader;
    }

    return view;
}

- (void)checkIfAllUnWineUsersAdded {
    BOOL allUsersInvited = YES;
    for (int i=0; i<self.unWineUsers.count; i++) {
        ContactInviteCell *cell = (ContactInviteCell *)[self.tableView dequeueReusableCellWithIdentifier:kContactInviteCellIdentifier forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.addButton.userInteractionEnabled == TRUE) {
            LOGGER(@"Breaking");
            allUsersInvited = FALSE;
            break;
        } else {
            LOGGER(@"Interaction Enabled");
        }
    }
    
    if (allUsersInvited) {
        LOGGER(@"All unWine Users invited");
        [self.addAllHeader setLayoutToAllUsersInvited];
    
    } else {
        LOGGER(@"NOT All unWine Users invited");
        [self.addAllHeader setLayoutToDefault];
    }
}

- (void)addAll {
    // Send batch unWine follow/friend requests
    LOGGER(@"Enter");
    SHOW_HUD;
    [[self addAllUnWineUsers:self.unWineUsers] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD;
        
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            [self.addAllHeader setLayoutToDefault];
            [self showAlertWithHeader:@"Spilled some wine"
                              message:@"Invites failed to send."
                        andButtonText:@"OK"
                                error:YES];
        }

        LOGGER(@"Successfully sent invite to ALL unWine Users");
        [self.tableView reloadData];
        
        return nil;
    }];
}

- (void)inviteAll {
    // Send Batch friend invite via email
    LOGGER(@"Enter");
    ANALYTICS_TRACK_EVENT(EVENT_USER_PRESSED_SELECT_ALL_BUTTON);
    [self showAlertWithHeader:@"Invite All"
                      message:@"Coming soon."
                andButtonText:@"OK"
                        error:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;

    if (self.isSearching == NO) {
        if (section == 0 && self.unWineUsers.count > 0) {
            height = 114;
        } else if (section == 1 && self.nonUnWineUsers.count > 0) {
            height = 60;
        }
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    printf("\n\n");
    ContactInviteCell *cell = (ContactInviteCell *)[tableView dequeueReusableCellWithIdentifier:kContactInviteCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        LOGGER(@"Cell is nil");
        cell = [[ContactInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactInviteCellIdentifier];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Display recipe in the table cell
    id contact = nil;
    
    if (self.isSearching) {
        LOGGER(@"Using filtered array");
        if (indexPath.section == 0) {
            LOGGER(@"filteredUsers");
            contact = [self.filteredUsers objectAtIndex:indexPath.row];
        } else {
            LOGGER(@"filteredNonUsers");
            contact = [self.filteredNonUsers objectAtIndex:indexPath.row];
        }
        
    } else {
        LOGGER(@"Using contacts array");
        if (indexPath.section == 0) {
            LOGGER(@"unWineUsers");
            contact = [self.unWineUsers objectAtIndex:indexPath.row];
        } else {
            LOGGER(@"nonUnWineUsers");
            contact = [self.nonUnWineUsers objectAtIndex:indexPath.row];
        }
    }

    if ([contact isKindOfClass:[User class]]) {
        [cell configureWithUser:(User *)contact];
    } else {
        [cell configureWithContact:(APContact *)contact];
    }

    return cell;
}

#pragma mark - Add/Invite Logic

- (void)inviteContact:(APContact *)contact fromSender:(ContactInviteCell *)cell {
    LOGGER(@"Hola");
    NSString *phone = contact.phones.count > 0 ? contact.phones.firstObject.number : @"nada";
    NSString *email = contact.emails.count > 0 ? contact.emails.firstObject.address : @"nada";
    NSString *s = [NSString stringWithFormat:@"Inviting contact with name \"%@\", phone \"%@\", and email \"%@\"",
                   contact.name.compositeName, phone, email];

    LOGGER(s);
    self.senderCell = cell;
    self.sendDictionary = [[NSMutableDictionary alloc] init];
    
    for (APPhone *phone in contact.phones) {
        [self.sendDictionary setObject:@"phone" forKey:phone.number];
    }
    
    for (APEmail *email in contact.emails) {
        [self.sendDictionary setObject:@"email" forKey:email.address];
    }
    
    if (self.sendDictionary.count == 1) {
        NSString *phoneOrEmail = self.sendDictionary.allKeys.firstObject;
        NSString *type = [self.sendDictionary objectForKey:phoneOrEmail];
        
        if ([type isEqualToString: @"phone"]) {
            [self inviteText:phoneOrEmail];
        } else if ([type isEqualToString: @"email"]) {
            [self inviteEmail:phoneOrEmail];
        } else {
            LOGGER(@"Neither phone or email?");
        }
        
    } else {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Send invite to:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (NSString *key in self.sendDictionary.allKeys) {
            UIAlertAction *ok = [UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *phoneOrEmail = [self.sendDictionary objectForKey:action.title];
                if ([phoneOrEmail isEqualToString:@"phone"]) {
                    [self inviteText:key];
                    
                } else if ([phoneOrEmail isEqualToString:@"email"]) {
                    [self inviteEmail:key];
                }
            }];
            [actionSheet addAction:ok];
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDestructive handler:nil];
        [actionSheet addAction:cancelAction];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    for (NSString *key in self.sendDictionary.allKeys) {
        if ([title isEqualToString:key]) {
            NSString *phoneOrEmail = [self.sendDictionary objectForKey:key];
            if ([phoneOrEmail isEqualToString:@"phone"]) {
                [self inviteText:key];
                
            } else if ([phoneOrEmail isEqualToString:@"email"]) {
                [self inviteEmail:key];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
