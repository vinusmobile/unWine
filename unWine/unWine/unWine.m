//
//  unWine.m
//  unWine
//
//  Created by Fabio Gomez on 5/20/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unWine.h"
// Import this header to let Armor know that PFObject privately provides most
// of the methods for PFSubclassing.
#import <Parse/PFObject+Subclass.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Bolts/Bolts.h>
#import <Parse/Parse.h>
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>
#import "WineCell.h"
#import <RegExCategories/RegExCategories.h>

@interface unWine () <SearchableSubclass>

@end

static BOOL allWinesLocked = NO;
static NSArray *featuredWines;
static NSInteger verifiedCount = 0;
static NSInteger weatheredCount = 0;

@implementation unWine

@dynamic imageSquare, imageLarge, capitalizedName, name, colorType, nameWOWinery, region, vineyard, vintage, wineType, trending, verified, locked, price, barrels, ratingObject, thumbnail, image, partner, checkinCount, reactions, words, hashtags, photoDims, varietal, swipeRightCounter, swipeLeftCounter,userGeneratedFlag;

@synthesize history = _history, ratings = _ratings;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"unWine";
}

+ (PFQuery *)find:(NSString *)searchString {
    // Remove numbers
    NSString *s = [NSString stringWithFormat:@"searchString = \"%@\"", searchString];
    LOGGER(s);

    NSArray *words = [searchString.lowercaseString matches:RX(@"\\w+")];
    //NSArray *words = [searchString.lowercaseString matches:RX(@"^[a-z]+$")];
    NSArray *stopWords = @[@"the", @"in", @"and", @"can", @"bottle", @"glass", @"cup"];
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    s = [NSString stringWithFormat:@"words = %@", words];
    LOGGER(s);
    
    // Used to check that search string contains no numbers
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    for (NSString *w in words) {
        if (![stopWords containsObject:w] && ![parts containsObject:w] && !([w rangeOfCharacterFromSet:notDigits].location == NSNotFound)) {
            NSString *s = [NSString stringWithFormat:@"\"%@\" is a match", w];
            LOGGER(s);
            [parts addObject:w];
        } else {
            NSString *s = [NSString stringWithFormat:@"\"%@\" is NOT match", w];
            LOGGER(s);
        }
    }
    
    s = [NSString stringWithFormat:@"parts = %@", parts];
    LOGGER(s);
    
    PFQuery *query1 = [unWine query];
    [query1 whereKey:@"words" containsAllObjectsInArray:[parts copy]];

    PFQuery *query2 = [unWine query];
    [query2 whereKey:@"name" hasPrefix:searchString.lowercaseString];

    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];

    [query includeKey:@"partner"];
    [query orderByAscending:@"name"];
    [query setLimit:20];
    
    return query;
}

+ (PFQuery *)findByRegion:(NSString *)searchString {
    NSString *usableSearch = [[[searchString stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[usableSearch componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [parts removeObject:@""];
    
    PFQuery *query1 = [unWine query];
    [query1 whereKeyExists:@"regionParts"];
    [query1 whereKey:@"regionParts" containsAllObjectsInArray:[parts copy]];
    
    PFQuery *query2 = [unWine query];
    [query2 whereKeyExists:@"region"];
    [query2 whereKey:@"region" hasPrefix:searchString];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query includeKey:@"partner"];
    [query orderByAscending:@"name"];
    [query setLimit:20];
    
    return query;
}

+ (BFTask *)findTask:(NSString *)searchString {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [[[unWine find:searchString.lowercaseString] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (task.error) {
            LOGGER(task.error.localizedDescription);
            [theTask setError:task.error];
            return nil;
        }
        
        NSMutableArray *filtered = [[NSMutableArray alloc] init];
        NSMutableArray *control = [[NSMutableArray alloc] init];
        
        for(unWine *wine in task.result) {
            NSString *name = [wine.name lowercaseString];
            if(![control containsObject:name]) {
                [filtered addObject:wine];
                [control addObject:name];
            }
        }
        
        NSString *s = [NSString stringWithFormat:@"Found %lu wines:", (unsigned long)filtered.count];
        LOGGER(s);
        
        for (unWine *w in filtered) {
            NSLog(@"wine.id = \"%@\", wine.name = \"%@\", hashtags = \"%@\", words = \"\"", w.objectId, [w getWineName].lowercaseString, w.hashtags.description);
            NSLog(@"wine.description = %@\n\n", w.description);
        }
        
        [theTask setResult:filtered.mutableCopy];
        
        return nil;
    }];
    
    return theTask.task;
}

+ (BFTask *)findByRegionTask:(NSString *)searchString {
    return [[[unWine findByRegion:searchString] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        NSMutableArray *filtered = [[NSMutableArray alloc] init];
        
        NSMutableArray *control = [[NSMutableArray alloc] init];
        
        for(unWine *wine in task.result) {
            NSString *name = [wine.name lowercaseString];
            if(![control containsObject:name]) {
                [filtered addObject:wine];
                [control addObject:name];
            }
        }
        
        return [BFTask taskWithResult:filtered];
    }];
}

+ (BFTask *)getWineObjectTask:(NSString *)objectId {
    PFQuery *query = [unWine query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query includeKey:@"partner"];
    
    return [query getFirstObjectInBackground];
}

+ (BFTask *)getWinesTask:(NSArray<NSString *> *)objectIds {
    PFQuery *query = [unWine query];
    [query whereKey:@"objectId" containedIn:objectIds];
    [query includeKey:@"partner"];
    
    return [query findObjectsInBackground];
}


+ (BOOL)areAllWinesLocked {
    return allWinesLocked;
}

+ (void)setAllWinesLocked:(BOOL)locked {
    allWinesLocked = locked;
}

+ (NSArray *)getFeaturedWines {
    return featuredWines;
}

+ (void)setFeaturedWines:(NSArray *)featured {
    featuredWines = featured;
}

+ (NSInteger)getVerifiedCount {
    return verifiedCount;
}

+ (void)setVerifiedCount:(NSInteger)count {
    verifiedCount = count;
}

+ (NSInteger)getWeatheredCount {
    return weatheredCount;
}

+ (void)setWeatheredCount:(NSInteger)count {
    weatheredCount = count;
}

- (NSString *)getWineName {
    //LOGGER(@"Enter");
    NSString *nameString = @"";
    
    if (ISVALID(self.capitalizedName)) {
        //NSLog(@"%s - using capitalizedName", FUNCTION_NAME);
        nameString = self.capitalizedName;
    } else if (ISVALID(self.name)) {
        //NSLog(@"%s - using name", FUNCTION_NAME);
        nameString = self.name.capitalizedString;
    } else {
        //NSLog(@"%s - using nameWOWinery", FUNCTION_NAME);
        nameString = self.nameWOWinery.capitalizedString;
    }
    
    return [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (PFRelation *)history {
    if(_history == nil)
        _history = [self relationForKey:@"history"];

    return _history;
}

- (void)setHistory:(PFRelation *)history {
    _history = history;
}

- (PFRelation *)ratings {
    if(_ratings == nil)
        _ratings = [self relationForKey:@"ratings"];

    return _ratings;
}

- (void)setRatings:(PFRelation *)ratings {
    _ratings = ratings;
}

- (PFImageView *)getThumbnailImageView {
    PFImageView *view = [[PFImageView alloc] initWithImage:WINE_PLACEHOLDER];
    view.file = self.thumbnail;
    [view loadInBackground];
    return view;
}

- (PFImageView *)getLargeImageView {
    PFImageView *view = [[PFImageView alloc] initWithImage:WINE_PLACEHOLDER];
    view.file = self.image;
    [view loadInBackground];
    return view;
}

- (BFTask *)setWineImageForImageView:(PFImageView *)imageView {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    NSURL *imageURL;
    
    if (self.thumbnail) {
        imageView.image = WINE_PLACEHOLDER;
        imageView.file = self.thumbnail;
        return [imageView loadInBackground];
        
    } else if (ISVALID(self.imageSquare)) {
        imageURL = [NSURL URLWithString:self.imageSquare];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        imageView.image = WINE_PLACEHOLDER;
        [imageView setImageWithURLRequest:request placeholderImage:WINE_PLACEHOLDER success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            [source setResult:image];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            [source setError:error];
        }];
        
    } else if (self.image) {
        imageView.image = WINE_PLACEHOLDER;
        imageView.file = self.image;
        return [imageView loadInBackground];
        
    } else if (ISVALID(self.imageLarge)) {
        imageURL = [NSURL URLWithString:self.imageLarge];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        imageView.image = WINE_PLACEHOLDER;
        [imageView setImageWithURLRequest:request placeholderImage:WINE_PLACEHOLDER success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            [source setResult:image];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            [source setError:error];
        }];
        
    } else {
        imageView.image = WINE_PLACEHOLDER;
        [source setResult:WINE_PLACEHOLDER];
    }
    
    return source.task;
}

- (NSString *)getVineYardName {
    NSString *vineyard = nil;
    
    // Partner name is capitalized
    if (self.partner && ![self.partner isKindOfClass:[NSNull class]]) {
        //NSLog(@"%s - using partner", FUNCTION_NAME);
        vineyard = self.partner.name;
    }
    
    if (!ISVALID(vineyard)) {
        //NSLog(@"%s - using vineyard", FUNCTION_NAME);
        vineyard = self.vineyard.capitalizedString;
    }
    
    return vineyard != nil ? [vineyard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : nil;
}

- (void)checkIfVerified {
    if(!self.checkinCount)
        self.checkinCount = 0;
    if(!self.verified)
        self.verified = NO;
    
    if(self.checkinCount == 0 && self.partner == nil)
        self.verified = NO;
    else if(self.partner != nil)
        self.verified = YES;
    
    if(self.checkinCount > [unWine getVerifiedCount])
        self.verified = YES;
    
    //NSLog(@"Verification Status %@", self.verified ? @"YES" : @"NO");
}

- (BOOL) isEditable {
    [self checkIfVerified];
    
    return (!self.verified && !self.locked);
}

- (NSString *)getImageURL {
    NSString *urlString = self.imageSquare;
    
    if (!ISVALID(urlString)) {
        urlString = self.imageLarge;
    }
    
    if (!ISVALID(urlString)) {
        urlString = self.thumbnail.url;
    }
    
    if (!ISVALID(urlString)) {
        urlString = self.image.url;
    }
    
    if (!ISVALID(urlString)) {
        urlString = nil;
    }
    
    return urlString;
}

- (BFTask *)taskForDownloadingWineImage {
    
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    NSString *imageURL = nil;
    __block NSString *debug = nil;
    
    imageURL = [self getImageURL];
    
    if (!ISVALID(imageURL)) {
        debug = [NSString stringWithFormat:@"No Image URL for %@\n\n", self.parseClassName];
        //LOGGER(debug);
        [taskCompletionSource setResult:WINE_PLACEHOLDER];
    } else {
        debug = [NSString stringWithFormat:@"URL for %@ - %@", self.parseClassName, imageURL];
        //LOGGER(debug);
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            debug = [NSString stringWithFormat:@"Successfully downloaded image for %@\n\n", self.parseClassName];
            //LOGGER(debug);
            [taskCompletionSource setResult:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            debug = [NSString stringWithFormat:@"Failed to download image for %@\n\n", self.parseClassName];
            //LOGGER(debug);
            [taskCompletionSource setResult:WINE_PLACEHOLDER];
        }];
        [requestOperation start];
    }
    
    return taskCompletionSource.task;
    
}

- (BFTask *)checkinReactionTask {
    return [NewsFeed newsfeedObjectsFromIds:self.reactions includeKeys:NO];//[Reaction reactionsFromObjects:(NSArray<NSString *> *)self.reactions];
}

- (void)addCheckinReaction:(NewsFeed *)checkin {
    if(self.reactions == nil)
        self.reactions = [[NSMutableArray alloc] init];
    else
        self.reactions = [[NSMutableArray alloc] initWithArray:self.reactions];
    
    [self.reactions addObject:[checkin objectId]];
}

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[unWine class]]) {
        return [self.objectId isEqualToString:[(unWine *)object objectId]];
    } else
        return NO;
}

- (NSString *)getSearchableName {
    return [self getWineName];
}

- (Class<PFObjectCell>)getAssociatedCell {
    return [WineCell class];
}

- (UIImage *)getImage {
    return self.image != nil ? [UIImage imageWithData:[self.image getData]] : WINE_PLACEHOLDER;
}

- (BFTask *)increaseSwipeRightCounter {
    if (self.swipeRightCounter < 1) {
        self.swipeRightCounter = 1;
        LOGGER(@"Setting Swipe Right Counter for first time");
        
    } else {
        self.swipeRightCounter += 1;
    }
    
    return [self saveInBackground];
}

- (BFTask *)increaseSwipeLeftCounter {
    if (self.swipeLeftCounter < 1) {
        self.swipeLeftCounter = 1;
        LOGGER(@"Setting Swipe Left Counter for first time");
        
    } else {
        self.swipeLeftCounter += 1;
    }
    
    return [self saveInBackground];
}

+ (Records *)createObject:(unWine *)wine withField:(NSString *)field asValue:(id)value {
    User *user = [User currentUser];
    
    Records *record = [Records new];
    if(wine != nil)
        record.wine = wine;
    record.editor = user;
    record.field = field;
    record.value = [[NSMutableArray alloc] initWithObjects:value, nil];
    
    return record;
}

/*
 - Gets wine fields that are going to change
 - Set those fields into wine
 - Create Records objects for each field changed
 - Add Record objects to wine history field
 - Saving order:
 - Save Records first
 - Set Records to wine field
 - Save contributions to user
 
 */
- (BFTask *)createRecordsAndSaveWineWithRegisters:(NSDictionary *)registers {
    
    if (registers == nil || (registers && registers.count < 1)) {
        LOGGER(@"No registers to save");
        if (self.isDirty) {
            LOGGER(@"Saving in backgroune");
            return [self saveInBackground];
        } else {
            LOGGER(@"Nothing to save");
            return [BFTask taskWithResult:@(true)];
        }
    }

    if(self.checkinCount <= 0) {
        self.checkinCount = 0;
    }
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];
    __block NSMutableArray<Records *> *objects = [[NSMutableArray alloc] init];
    
    LOGGER(@"Saving Register values to Wine");
    for(NSString *key in registers) {
        id value = [registers objectForKey:key];
        NSString *s = [NSString stringWithFormat:@"key => value: %@ => %@", key, value];
        LOGGER(s);
        [self setValue:value forKey:key];
    }
    
    [[[[[self saveInBackground] continueWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        // Create record objects
        LOGGER(@"Creating Record objects");
        NSMutableArray<BFTask *> *tasks = [[NSMutableArray alloc] init];
        
        for(NSString *key in registers) {
            id value = [registers objectForKey:key];
            NSString *s = [NSString stringWithFormat:@"key => value: %@ => %@", key, value];
            LOGGER(s);
            Records *object = [unWine createObject:self withField:key asValue:value];
            [objects addObject:object];
            [tasks addObject:[object saveInBackground]];
        }
        
        return [BFTask taskForCompletionOfAllTasks:tasks];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Saving contributions to user");
        PFRelation *contributions = user.contributions;
        for(Records *record in objects)
            [contributions addObject:record];
        
        return [user saveInBackground];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Saving history to wine");
        PFRelation *history = [self relationForKey:@"history"];
        for(Records *record in objects)
            [history addObject:record];
        
        return [self saveInBackground];
    
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            [theTask setError:t.error];
        
        } else {
            LOGGER(@"Done");
            [Analytics trackUserEditedWine:self];
            [theTask setResult:@(true)];
        }
        
        return nil;
    }];
    
    return theTask.task;
}


@end
