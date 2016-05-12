//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#import "CommandBarElementCollection.h"
#import "IRecieveCollectionChanges.h"

@interface NavigationList : NSObject  <IRecieveCollectionChanges>
{
    CommandBarElementCollection* items;
    UINavigationItem* navigationItem;
    BOOL left;
    BOOL listeners;
}

- (id)init:(CommandBarElementCollection*)items_ on:(UINavigationItem*)navigationItem_ left:(BOOL)left_;
- (void)show;

@end
