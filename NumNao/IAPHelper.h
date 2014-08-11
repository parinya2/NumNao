//
//  IAPHelper.h
//  NumNao
//
//  Created by PRINYA on 8/6/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString * const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductWithCompletinoHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductWithCompletinoHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

@end
