//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#import "AppBarButton.h"
#import "SymbolIcon.h"
#import "BitmapIcon.h"
#import "TabBar.h"
#import "Frame.h"
#import "NavigationList.h"
#import "OutgoingMessages.h"
#import "Utils.h"

@implementation NavigationList

- (id)init:(CommandBarElementCollection*)items_ on:(UINavigationItem*)navigationItem_ left:(BOOL)left_ {
    self = [super init];
    items = items_;
    navigationItem = navigationItem_;
    left = left_;
    listeners = false;
    return self;
}

- (void)show {
    NSMutableArray* list = [[NSMutableArray alloc] init];

    if (items != nil) {
        if (listeners == false) {
            [items addListener:self];
            listeners = true;
        }

        unsigned long itemsCount = items.Count;

        for (unsigned long i = 0; i < itemsCount; i++) {
            id command = items[i];
            UIBarButtonItem* item = nil;

            if ([command isKindOfClass:[AppBarButton class]]) {
                AppBarButton* abb = (AppBarButton*)command;
                if (true) { //TODO: if visible
                    if ([abb.Icon isKindOfClass:[SymbolIcon class]] || abb.Icon == nil)
                    {
                        if (abb.hasSystemIcon)
                            item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:abb.systemIcon target:abb action:@selector(onClick:)];
                        else
                            item = [[UIBarButtonItem alloc] initWithTitle:abb.Label style:UIBarButtonItemStylePlain target:abb action:@selector(onClick:)];
                    }
                    else if ([abb.Icon isKindOfClass:[BitmapIcon class]]) {
                        NSString* source = ((BitmapIcon*)abb.Icon).UriSource;
                        // TODO: Need util:
                        UIImage* image;
                        if ([source hasPrefix:@"ms-appx:///"]) {
                            image = [UIImage imageNamed:[source substringFromIndex:11]];
                        }
                        else if ([source containsString:@"://"]) {
                            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:source]]];
                        }
                        else {
                            image = [UIImage imageNamed:source];
                        }

                        item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:abb action:@selector(onClick:)];
                    }
                    else
                        throw @"Unhandled AppBarButton icon type";
                }
            }
            else {
                throw @"Unhandled command bar item type";
            }

            if (item != nil) {
                [list addObject:item];
            }
        }
    }

    if (left) {
        navigationItem.leftBarButtonItems = list;
    } else {
        navigationItem.rightBarButtonItems = list;
    }
}

// IRecieveCollectionChanges.add
- (void) add:(NSObject*)collection item:(NSObject*)item {
    [self show];
}

// IRecieveCollectionChanges.removeAt
- (void) removeAt:(NSObject*)collection index:(int)index {
    [self show];
}

@end
