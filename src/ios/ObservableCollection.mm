//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#import "ObservableCollection.h"

@implementation ObservableCollection

- (id)init {
    self = [super init];
    _array = [[NSMutableArray alloc] init];
    return self;
}

- (void)addListener:(NSObject<IRecieveCollectionChanges>*)listener {
    if (_listeners == nil)
        _listeners = [[NSMutableArray alloc] init];

    [_listeners addObject:listener];

    // Notify listener about any items added before listening
    if (_array.count > 0) {
        for (int i = 0; i < _array.count; i++) {
            [listener add:self item:_array[i]];
        }
    }
}

- (void)removeListener:(NSObject<IRecieveCollectionChanges>*)listener {
    if (_listeners != nil)
        [_listeners removeObject:listener];
}

- (void)Add:(id)obj {
    [_array addObject:obj];
    if (_listeners != nil) {
        // Notify any listeners
        for (int i = 0; i < _listeners.count; i++) {
            [_listeners[i] add:self item:obj];
        }
    }
}

- (unsigned long)Count {
    return _array.count;
}

- (void)Clear {
    int itemCount = _array.count;

    [_array removeAllObjects];
    if (_listeners != nil) {
        // Notify any listeners
        for (int i = 0; i < _listeners.count; i++) {
            for (int j = 0; j < itemCount; j++) {
                [_listeners[i] removeAt:self index:j];
            }
        }
    }
}

- (void)RemoveAt:(int)index {
    [_array removeObjectAtIndex:index];
    if (_listeners != nil) {
        // Notify any listeners
        for (int i = 0; i < _listeners.count; i++) {
            [_listeners[i] removeAt:self index:index];
        }
    }
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return _array[index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    _array[index] = obj;
}

@end
