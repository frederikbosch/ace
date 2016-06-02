//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#import "AppBarButton.h"
#import "BitmapIcon.h"
#import "Color.h"
#import "OutgoingMessages.h"
#import "SymbolIcon.h"
#import "TabBar.h"
#import "Utils.h"
#import "UIViewHelper.h"

@implementation TabBar

- (id) init {
    _tabBar = [[UITabBar alloc] init];
    _tabBar.delegate = self;
    return self;
}

// IHaveProperties.setProperty
- (void) setProperty:(NSString*)propertyName value:(NSObject*)propertyValue {
    if (![UIViewHelper setProperty:_tabBar propertyName:propertyName propertyValue:propertyValue]) {
        if ([propertyName hasSuffix:@".PrimaryCommands"] ||
            [propertyName hasSuffix:@".Children"]) {
            if (propertyValue == nil) {
                [items removeListener:self];
                items = nil;
            }
            else {
                items = (CommandBarElementCollection*)propertyValue;
                // Listen to collection changes
                [items addListener:self];
            }
        }
        else if ([propertyName hasSuffix:@".TintColor"]) {
            _tabBar.tintColor = [Color fromObject:propertyValue withDefault:nil];
        }
        else if ([propertyName hasSuffix:@".BarTintColor"]) {
            _tabBar.barTintColor = [Color fromObject:propertyValue withDefault:nil];
        }
        else {
            throw [NSString stringWithFormat:@"Unhandled property for %@: %@", [self class], propertyName];
        }
    }
}

// IRecieveCollectionChanges.add
- (void) add:(NSObject*)collection item:(NSObject*)item {
    [self updateTabBar];
}

// IRecieveCollectionChanges.removeAt
- (void) removeAt:(NSObject*)collection index:(int)index {
    [self updateTabBar];
}

- (void) updateTabBar {
    if (_controller != nil) {
        [self displayTabs:false];
        [_controller viewWillLayoutSubviews];
        [self displayBadges];
        [_controller viewWillLayoutSubviews];

        if (selectedIndex != -1 && [_tabBar.items count] > selectedIndex && [_tabBar.items objectAtIndex:selectedIndex] != nil) {
            _tabBar.selectedItem = (UITabBarItem*)_tabBar.items[selectedIndex];
        }
    }
}

- (void)tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem*)item {
    selectedIndex = item.tag;
    [OutgoingMessages raiseEvent:@"click" instance:items[selectedIndex] eventData:nil];
}

- (void)showTabBar:(UIViewController*)viewController animated:(BOOL)animated {
    [viewController.view addSubview:_tabBar];

    // Remember the tab bar
    [viewController.view.layer setValue:_tabBar forKey:@"Ace.TabBar"];

    // display tabs and badges
    [self displayTabs:animated];
    [viewController.navigationController viewWillLayoutSubviews];
    [self displayBadges];

    if (_tabBar.items.count > 0) {
        // Automatically select the first tab, which happens automatically on Android
        selectedIndex = 0;
        _tabBar.selectedItem = (UITabBarItem*)_tabBar.items[0];
        [OutgoingMessages raiseEvent:@"click" instance:items[0] eventData:nil];
    }

    // Refresh layout
    [viewController.navigationController viewWillLayoutSubviews];
    _controller = viewController.navigationController;
}

- (void) displayTabs:(BOOL)animated {
    NSMutableArray* tabs = [[NSMutableArray alloc] init];

    if (items != nil) {
        unsigned long itemsCount = items.Count;

        for (unsigned long i = 0; i < itemsCount; i++) {
            id command = items[i];
            UITabBarItem* tab = nil;

            if ([command isKindOfClass:[AppBarButton class]]) {
                AppBarButton* abb = (AppBarButton*)command;
                if (true) { //TODO: if visible
                    if ([abb.Icon isKindOfClass:[SymbolIcon class]] || abb.Icon == nil) {
                        if (abb.hasSystemIcon)
                            tab = [[UITabBarItem alloc] initWithTabBarSystemItem:abb.systemIcon tag:i];
                        else
                            tab = [[UITabBarItem alloc] initWithTitle:abb.Label image:nil tag:i];
                    }
                    else if ([abb.Icon isKindOfClass:[BitmapIcon class]]) {
                        NSString* source = ((BitmapIcon*)abb.Icon).UriSource;
                        NSString* sourceOn = [source stringByReplacingOccurrencesOfString:@"{platform}" withString:@"ios-on"];
                        NSString* sourceOff = [source stringByReplacingOccurrencesOfString:@"{platform}" withString:@"ios-off"];
                        UIImage* onImage = [Utils getImage:sourceOn];
                        UIImage* offImage = [Utils getImage:sourceOff];
                        if (offImage == nil) {
                            offImage = [Utils getImage:source];
                        }
                        tab = [[UITabBarItem alloc] initWithTitle:abb.Label image:offImage tag:i];
                        tab.selectedImage = onImage;
                    }
                    else if (abb.Icon == nil) {
                        tab = [[UITabBarItem alloc] initWithTitle:abb.Label image:nil tag:i];
                    }
                    else {
                        throw @"Unhandled AppBarButton icon type";
                    }

                    if (abb.Badge != nil) {
                        [tab setBadgeValue:abb.Badge];
                    }
                }
            }
            else {
                throw @"Unhandled command bar item type";
            }

            if (tab != nil) {
                [tabs addObject:tab];
            }
        }

        [_tabBar setItems:tabs animated:animated];
    }
}

- (void) displayBadges {
    if (items != nil) {
        unsigned long itemsCount = items.Count;
        for (unsigned long i = 0; i < itemsCount; i++) {
            id command = items[i];
            AppBarButton* abb = (AppBarButton*)command;


        }
    }
}

@end
