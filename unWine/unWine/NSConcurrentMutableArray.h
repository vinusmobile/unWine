//
//  NSConcurrentMutableArray.h
//  unWine
//
//  Created by Bryce Boesen on 12/7/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSConcurrentMutableArray<ObjectType> : NSObject

@property (nonatomic) NSMutableArray<ObjectType> *array;

- (id)init;

- (id)lastObject;
- (void)addObject:(id)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (void)insertObject:(id)obj atIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;
- (NSUInteger)count;

@end
