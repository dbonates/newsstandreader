//
//  InAppStore.h
//  Reader
//
//  Created by Basispress.com on 1/12/13.
//  Copyright (c) 2013 Basispress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum {
    SubscriptionVerificationStateIdle,
    SubscriptionVerificationStateVerifying,
    SubscriptionVerificationStateFailed
} SubscriptionVerificationState;

typedef enum {
    SubscriptionStateUnknown,
    SubscriptionStateSubscribed,
    SubscriptionStateNotSubscribed,
}SubscriptionState;

typedef enum {
    InAppStoreStateIdle,
    InAppStoreStateRestoring,
    InAppStoreStatePurchasingIssue,
    InAppStoreStatePurchasingSubscription
}InAppStoreState;

typedef enum {
    StoreCacheStateDirty,
    StoreCacheStateOK,
    StoreCacheStateUpdating
}StoreCacheState;
@interface InAppStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKPaymentQueue *_queue;

// store cache stuff
    NSArray *_allProductIdentifiers;
    NSArray *_subscriptionProductIdentifiers;
    NSArray *_issuesProductIdentifiers;
    
    NSArray *_allProducts;
    NSArray *_subscriptionProducts;
    NSArray *_issueProducts;
    
    
    StoreCacheState _storeCacheState;
    InAppStoreState _currentState;
    SubscriptionState _subscriptionState;
    
    NSTimer *_maintenanceTimer;
    
    void (^_completionBlock)();
    void (^_failureBlock)(NSError*);
}
/*
 storeCacheState reflets the current state of the store cache. You should not make any calls to - productWithProductIdentifier:  or -purchaseProduct:completionBlock:failureBlock: if the storeCacheState is different than StoreCacheStateOK;
 */
@property (nonatomic, readonly) StoreCacheState storeCacheState;
@property (nonatomic, readonly) InAppStoreState currentState;
/*
 subscriptionState reflets the current state of the subscription.
 */

@property (nonatomic, readonly) SubscriptionState subscriptionState;
/*
allProducts is an array containing all the products in the store cache
 */
@property (nonatomic, readonly) NSArray *allProducts;
/*
 subscriptionProducts is an array containing all the subscription products in the store cache
 */
@property (nonatomic, readonly) NSArray *subscriptionProducts;
/*
 subscriptionReceiptData is the data of the last receipt. 
 */
@property (nonatomic, readonly) NSData *subscriptionReceiptData;

+ (InAppStore *)sharedInstance;

- (SKProduct*)productWithProductIdentifier:(NSString*)productIdentifier;

- (void)restorePurchasesWithCompletionBlock:(void (^)())completionBlock failureBlock:(void (^)(NSError *))failureBlock;
- (void)purchaseProduct:(SKProduct*)product completionBlock:(void (^)())completionBlock failureBlock:(void (^)(NSError*))failureBlock;

- (void)fakeSubscriber;

@end
