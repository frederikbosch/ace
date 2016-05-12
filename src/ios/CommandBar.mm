//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#import "CommandBar.h"
#import "AppBarButton.h"
#import "SymbolIcon.h"
#import "BitmapIcon.h"
#import "TabBar.h"
#import "Frame.h"
#import "OutgoingMessages.h"
#import "Utils.h"
#import "NavigationList.h"

@implementation CommandBar

- (CommandBarElementCollection*) getPrimaryCommands {
    return _primaryCommands;
}

- (CommandBarElementCollection*) getSecondaryCommands {
    return _secondaryCommands;
}

// IHaveProperties.setProperty
- (void) setProperty:(NSString*)propertyName value:(NSObject*)propertyValue {
    if ([propertyName hasSuffix:@".PrimaryCommands"]) {
        _primaryCommands = (CommandBarElementCollection*)propertyValue;
    }
    else if ([propertyName hasSuffix:@".SecondaryCommands"]) {
        _secondaryCommands = (CommandBarElementCollection*)propertyValue;
    }
    else {
        throw [NSString stringWithFormat:@"Unhandled property for %@: %@", [self class], propertyName];
    }
}

+ (void)showNavigationBar:(CommandBar*)bar on:(UIViewController*)viewController animated:(BOOL)animated {
    [Frame ShowNavigationBar];

    UINavigationItem* navItem = viewController.navigationItem;
    [CommandBar addNavigationItems:bar on:navItem];
}

+ (void)addNavigationItems:(CommandBar*)bar on:(UINavigationItem*)navigationItem {
    CommandBarElementCollection* primaryCommands = [bar getPrimaryCommands];
    CommandBarElementCollection* secondaryCommands = [bar getSecondaryCommands];

    NavigationList* primaryItems = [[NavigationList alloc] init:primaryCommands on:navigationItem left:false];
    NavigationList* secondaryItems = [[NavigationList alloc] init:secondaryCommands on:navigationItem left:true];

    [primaryItems show];
    [secondaryItems show];
}

- (void)showTabBar:(UIViewController*)viewController animated:(BOOL)animated {
    [viewController.navigationController setToolbarHidden:false animated:animated];

    if (viewController.toolbarItems != nil) {
        return;
    }

    NSMutableArray* items = [[NSMutableArray alloc] init];

    //
    // Then space
    //
    UIBarButtonItem* flexBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexBar];

    //
    // Then PrimaryCommands
    //
    if (_primaryCommands != nil) {
        unsigned long primaryItemsCount = _primaryCommands.Count;

        for (unsigned long i = 0; i < primaryItemsCount; i++) {
            id command = _primaryCommands[i];
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
                [items addObject:item];

                // Add space after all but the last item
                if (i < primaryItemsCount-1) {
                    // For centering and stretching
                    UIBarButtonItem* flexBarTemp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                    [items addObject:flexBarTemp];
                }
            }
        }
    }

    // For centering and stretching
    UIBarButtonItem* flexBar2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexBar2];

    viewController.toolbarItems = items;
}

@end
