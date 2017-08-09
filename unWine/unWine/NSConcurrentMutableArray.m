//
//  NSConcurrentMutableArray.m
//  unWine
//
//  Created by Bryce Boesen on 12/7/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "NSConcurrentMutableArray.h"

@implementation NSConcurrentMutableArray
@synthesize array = _array;

- (id)init {
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    @synchronized(_array) {
        return [_array objectAtIndex:index];
    }
}

- (id)lastObject {
    @synchronized(_array) {
        return [_array lastObject];
    }
}

- (void)addObject:(id)anObject {
    @synchronized(_array) {
        [_array addObject:anObject];
    }
}

- (void)insertObject:(id)obj atIndex:(NSUInteger)index {
    @synchronized(_array) {
        [_array insertObject:obj atIndex:index];
    }
}

- (void)removeObject:(id)anObject {
    @synchronized(_array) {
        [_array removeObject:anObject];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    @synchronized(_array) {
        [_array removeObjectAtIndex:index];
    }
}

- (void)removeAllObjects {
    @synchronized(_array) {
        [_array removeAllObjects];
    }
}

- (NSUInteger)count {
    @synchronized(_array) {
        return [_array count];
    }
}

@end
