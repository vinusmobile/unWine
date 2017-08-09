//
//  Winery.m
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "Winery.h"
#import "WineryCell.h"

@interface Winery () <SearchableSubclass>

@end

@implementation Winery
@dynamic location, name, verified, image;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Winery";
}

+ (PFQuery *)find:(NSString *)searchString {
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[searchString componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
    [parts removeObject:@""];
    
    PFQuery *query = [Winery query];
    [query whereKey:@"name" containsString:[searchString lowercaseString]];
    [query orderByAscending:@"verified,name"];
    [query setLimit:20];
    
    return query;
}

+ (BFTask *)findTask:(NSString *)searchString {
    return [[[Winery find:searchString] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        NSMutableArray *filtered = [[NSMutableArray alloc] init];
        
        NSMutableArray *control = [[NSMutableArray alloc] init];
        
        for(Winery *winery in task.result) {
            NSString *name = [winery.name lowercaseString];
            if(![control containsObject:name]) {
                [filtered addObject:winery];
                [control addObject:name];
            }
        }
        
        return [BFTask taskWithResult:filtered];
    }];
}

+ (BFTask *)getWineryObjectTask:(NSString *)objectId {
    PFQuery *query = [Winery query];
    [query whereKey:@"objectId" equalTo:objectId];
    
    return [query getFirstObjectInBackground];
}

+ (BFTask *)getWinerysTask:(NSArray<NSString *> *)objectIds {
    PFQuery *query = [Winery query];
    [query whereKey:@"objectId" containedIn:objectIds];
    
    return [query findObjectsInBackground];
}

+ (BFTask<Winery *> *)getWineriesNear:(PFGeoPoint *)point {
    PFQuery *query = [Winery query];
    [query whereKey:@"location" nearGeoPoint:point withinKilometers:250];
    [query orderByAscending:@"verified,name"];
    [query setLimit:50];
    
    return [query findObjectsInBackground];
}

+ (BFTask<Winery *> *)getNearestMatch:(Venue *)venue {
    PFQuery *query = [Winery query];
    [query whereKeyExists:@"name"];
    [query whereKey:@"location" nearGeoPoint:[venue getGeoPoint] withinKilometers:5];
    [query setLimit:1];
    
    return [[query findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if(task.error) {
            LOGGER(task.error);
            return task;
        }
        
        return [BFTask taskWithResult:task.result ? [task.result firstObject] : nil];
    }];
}

+ (BFTask<Winery *> *)getNearestMatchCreateIfNecessary:(Venue *)venue {
    return [[self getNearestMatch:venue] continueWithBlock:^id _Nullable(BFTask<Winery *> * _Nonnull task) {
        if(task.result) {
            return [BFTask taskWithResult:task.result];
        } else {
            Winery *winery = [Winery object];
            winery.name = [venue.name lowercaseString];
            winery.location = [venue getGeoPoint];
            winery.verified = NO;
            
            return [[winery saveInBackground] continueWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull task) {
                if(!task.error) {
                    return [BFTask taskWithResult:winery];
                } else {
                    LOGGER(task.error);
                }
                
                return [BFTask taskWithResult:nil];
            }];
        }
    }];
}

+ (BFTask<Winery *> *)findFirstCreateIfNecessary:(NSString *)searchString {
    return [[self findTask:searchString] continueWithBlock:^id _Nullable(BFTask<NSArray<Winery *> *> * _Nonnull task) {
        if(task.result && [task.result count] > 0) {
            return [BFTask taskWithResult:[task.result firstObject]];
        } else {
            Winery *winery = [Winery object];
            winery.name = [searchString lowercaseString];
            winery.verified = NO;
            
            return [[winery saveInBackground] continueWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull task) {
                if(!task.error) {
                    return [BFTask taskWithResult:winery];
                } else {
                    LOGGER(task.error);
                }
                
                return [BFTask taskWithResult:nil];
            }];
        }
    }];
}

- (BFTask *)setWineryImageForImageView:(PFImageView *)imageView {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    imageView.image = USER_PLACEHOLDER;
    if (self.image && ![self.image isKindOfClass:[NSNull class]]) {
        imageView.file = self.image;
        return [imageView loadInBackground];
    } else {
        [source setResult:nil];
    }
    
    return source.task;
}

- (BFTask<UIImage *> *)getWineryImage {
    if (self.image && ![self.image isKindOfClass:[NSNull class]]) {
        return [[self.image getDataInBackground] continueWithBlock:^id _Nullable(BFTask<NSData *> * _Nonnull task) {
            if(task.result)
                return [UIImage imageWithData:task.result];
            else
                return nil;
        }];
    } else {
        return [BFTask taskWithResult:USER_PLACEHOLDER];
    }
}

- (NSString *)getWineryName {
    return [self.name capitalizedString]; //[(self.verified ? [self.name stringByAppendingString:@"✓"] : self.name) capitalizedString];
}

- (NSString *)getSearchableName {
    return [self name];
}

- (Class<PFObjectCell>)getAssociatedCell {
    return [WineryCell class];
}

- (BOOL)isLikelyVenue:(Venue *)venue {
    if([[venue.name lowercaseString] isEqualToString:[self.name lowercaseString]])
        return YES;
    else if([self hasLocation])
        return [self.location distanceInKilometersTo:[venue getGeoPoint]] < .1f;

    return NO;
}

- (Venue *)getAsVenue {
    Venue *venue = [Venue object];
    venue.name = self.name;
    venue.category = @"Winery";
    if(self.location) {
        venue.latitude = @(self.location.latitude);
        venue.longitude = @(self.location.longitude);
    }
    return venue;
}

- (BOOL)hasLocation {
    return self.location && self.location.latitude != 0 && self.location.longitude != 0;
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[Winery class]] || [object isKindOfClass:[Venue class]]) {
        return [[[object objectForKey:@"name"] lowercaseString] isEqualToString:[self.name lowercaseString]];
    }
    
    return NO;
}

@end
