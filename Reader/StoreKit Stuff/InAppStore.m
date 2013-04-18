//
//  InAppStore.m
//  Reader
//
//  Created by Your Name on 1/12/13.
//  Copyright (c) 2013 Your Company. All rights reserved.
//

#import "InAppStore.h"
#import "Issue.h"
#import "CoreData+MagicalRecord.h"
#import "NSData+Base64.h"
#import "JSONKit.h"


NSString *IASSubscriptionReceiptDataKey = @"com.reader.subscription.receiptData";
NSString *IASSubscriptionExpirationDateKey = @"com.reader.subscription.expiratoinDate";
NSString *IASSubscriptionValidKey = @"com.reader.subscription.valid";
NSString *IASSubscriptionLastVerifiedDateKey = @"com.reader.subscription.lastVerifiedDate";
static InAppStore *_sharedInstance = nil;

#define kMaintenanceTimerInterval 2.0
@interface InAppStore()
{
    NSData *_subscriptionReceiptData;
    NSDate *_subscriptionExpirationDate;
    NSNumber *_subscriptionValid;
    NSDate *_subscriptionLastVerifiedDate;
}
@property (nonatomic, readwrite) StoreCacheState storeCacheState;
@property (nonatomic, readwrite) InAppStoreState currentState;
@property (nonatomic, readwrite) SubscriptionState subscriptionState;
@property (nonatomic, readwrite) SubscriptionVerificationState subscriptionVerificationState;
@property (nonatomic) NSData *subscriptionReceiptData;
@property (nonatomic) NSDate *subscriptionExpirationDate;
@property (nonatomic) NSNumber *subscriptionValid;
@property (nonatomic) NSDate *subscriptionLastVerifiedDate;
@end
@implementation InAppStore

+ (InAppStore *)sharedInstance
{
    if (!_sharedInstance)
    @synchronized(self){
        _sharedInstance = [[InAppStore alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _queue = [SKPaymentQueue defaultQueue];
        [_queue addTransactionObserver:self];
        [self updateStoreCache];
        
        
        _maintenanceTimer = [NSTimer scheduledTimerWithTimeInterval:kMaintenanceTimerInterval
                                                             target:self
                                                           selector:@selector(performMaintenance)
                                                           userInfo:nil
                                                            repeats:YES];
        
        _subscriptionProducts = @[];
        _issueProducts = @[];
        if (self.subscriptionValid != nil) {
            if (![self.subscriptionValid boolValue])
                self.subscriptionState = SubscriptionStateNotSubscribed;
            else {
                self.subscriptionState = SubscriptionStateSubscribed;
                NSTimeInterval timeInt = [[NSDate date] timeIntervalSinceDate:self.subscriptionExpirationDate];
                if (timeInt > 60) {
                    [self verifySubscription];
                    NSLog(@"verify");
                }
            }
        }
        
    }
    
    return self;
}

- (void)updateStoreCache
{
    BOOL identifiersUpdated = [self updateIdentifiersIfNeeded];
    
    if (identifiersUpdated) {
        self.storeCacheState = StoreCacheStateDirty;
    }
    
    if (self.storeCacheState == StoreCacheStateDirty) {
        
//        NSLog(@"criando loadSet com array: %@", _allProductIdentifiers);
        
        NSSet *loadSet = [NSSet setWithArray:_allProductIdentifiers];
        
//        NSLog(@"loadSet criado: %@", loadSet);
        
        SKProductsRequest *_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:loadSet];
        [_productsRequest setDelegate:self];
        [_productsRequest start];
        
        self.storeCacheState = StoreCacheStateUpdating;
        
    }

}

- (BOOL)updateIdentifiersIfNeeded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultsSubscriptionIdentifiers = [defaults objectForKey:@"com.reader.subscriptionIdentifiers"];
    NSArray *defaultsIssuesIdentifiers = [defaults objectForKey:@"com.reader.issueIdentifiers"];
    BOOL ok = YES;
    
    if (![defaultsIssuesIdentifiers isEqualToArray:_subscriptionProductIdentifiers])
        ok = NO;
    if (![defaultsIssuesIdentifiers isEqualToArray:_issuesProductIdentifiers])
        ok = NO;
    
    if (!ok) {
        _subscriptionProductIdentifiers = defaultsSubscriptionIdentifiers;
        _issuesProductIdentifiers = defaultsIssuesIdentifiers;
        _allProductIdentifiers = [_subscriptionProductIdentifiers arrayByAddingObjectsFromArray:_issuesProductIdentifiers];
    }
    return !ok;
}

- (void)storeCacheUpdated
{
//    NSLog(@"%s, %s", __FILE__, __FUNCTION__);
    if (_allProductIdentifiers.count == _allProducts.count) {

        self.storeCacheState = StoreCacheStateOK;
//        NSLog(@"[linha %d] %@", __LINE__, _issueProducts);
    }
    else {
        self.storeCacheState = StoreCacheStateDirty;
    }
    

}

- (SKProduct*)productWithProductIdentifier:(NSString *)productIdentifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier];
    NSArray *filteredObjects = [_allProducts filteredArrayUsingPredicate:predicate];
    
    if (filteredObjects.count) {
        return filteredObjects[0];
    }
    
    return nil;
}

- (void)performFailureBlockWithError:(NSError*)error
{
    if (_failureBlock) {
        _failureBlock(error);
    }
    
    _failureBlock = nil;
}

- (void)performCompletionBlock
{
    if (_completionBlock) {
        _completionBlock();
    }

    _completionBlock = nil;
}

- (void)restorePurchasesWithCompletionBlock:(void (^)())completionBlock failureBlock:(void (^)(NSError *))failureBlock
{
    _completionBlock = completionBlock;
    _failureBlock = failureBlock;
    [_queue restoreCompletedTransactions];
    self.currentState = InAppStoreStateRestoring;
}


- (void)purchaseProduct:(SKProduct*)product completionBlock:(void (^)())completionBlock failureBlock:(void (^)(NSError*))failureBlock
{
    _completionBlock = completionBlock;
    _failureBlock = failureBlock;
    
    NSUInteger index = [self.subscriptionProducts indexOfObject:product];
    if (index != NSNotFound) {
        self.currentState = InAppStoreStatePurchasingSubscription;
    }
    else {
        self.currentState = InAppStoreStatePurchasingIssue;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [_queue addPayment:payment];

}
- (void)restoreComplete
{
    [self performCompletionBlock];
    self.currentState = InAppStoreStateIdle;
}

- (void)restoreFailed:(NSError*)error
{
    [self performFailureBlockWithError:error];
    self.currentState = InAppStoreStateIdle;
}

- (void)performMaintenance
{
    
    if (self.subscriptionValid != nil) {
        if (![self.subscriptionValid boolValue]) {
            if (self.subscriptionState != SubscriptionStateNotSubscribed)
                self.subscriptionState = SubscriptionStateNotSubscribed;
        }
        else {
            if (self.subscriptionState != SubscriptionStateSubscribed)
                self.subscriptionState = SubscriptionStateSubscribed;
            NSTimeInterval timeInt = [[NSDate date] timeIntervalSinceDate:self.subscriptionExpirationDate];
            if (timeInt > 60) {
                [self verifySubscription];
                NSLog(@"verify");
            }
        }
    }
    
    
//    NSLog(@"now %@", [NSDate date]);
//    NSLog(@"subscription valid %@", self.subscriptionValid);
//    NSLog(@"subscription expiration %@", self.subscriptionExpirationDate);
//    NSLog(@"subscription last verified %@", self.subscriptionLastVerifiedDate);
    if (self.subscriptionState == SubscriptionStateUnknown && self.subscriptionVerificationState == SubscriptionVerificationStateIdle) {
//#warning verify subscription
    }
    
    if (self.storeCacheState == StoreCacheStateDirty) {
        [self updateStoreCache];
    }
}

- (void)fakeSubscriber
{
    self.subscriptionExpirationDate = [NSDate dateWithTimeIntervalSince1970:10000000000000.0];
    self.subscriptionLastVerifiedDate = [NSDate date];
    self.subscriptionValid = @(YES);
    self.subscriptionState = SubscriptionStateSubscribed;
    self.subscriptionVerificationState = SubscriptionVerificationStateIdle;
    
}

- (void)verifySubscription
{
    if (self.subscriptionReceiptData) {
        NSDictionary *jsonDictionary =  @{
        @"receipt-data" : [self.subscriptionReceiptData base64Encode],
        //@"password" : @"89c6c1218a864ac89ebb01b5f3919bd6"};
        @"password" : @"d64412273fad42f6a5c0e8daae235a60"};
        NSData *jsonData = [jsonDictionary JSONData];
        
        
        NSURL *url;
        if (USE_SANDBOX)
            url = [[NSURL alloc] initWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
        else
            url = [[NSURL alloc] initWithString: @"https://itunes.apple.com/verifyReceipt"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   if (error) {
                                       self.subscriptionVerificationState = SubscriptionVerificationStateFailed;
                                   }
                                   else {
                                       NSDictionary *responseDictionary = [data objectFromJSONData];
//                                       NSLog(@"\n[%s]\n[%d]\nresponse dictionary %@", __FILE__, __LINE__, responseDictionary);
                                       if ([responseDictionary[@"status"] isEqual:@(0)]) {
                                           NSDictionary *lastReceiptDictionary = responseDictionary[@"latest_receipt_info"];
                                           NSTimeInterval expiresTimeInterval = [lastReceiptDictionary[@"expires_date"] doubleValue] / 1000;
                                           self.subscriptionExpirationDate = [NSDate dateWithTimeIntervalSince1970:expiresTimeInterval];
                                           self.subscriptionLastVerifiedDate = [NSDate date];
                                           self.subscriptionValid = @(YES);
                                           self.subscriptionState = SubscriptionStateSubscribed;
                                       }
                                       else {
                                           self.subscriptionValid = @(NO);
                                           self.subscriptionState = SubscriptionStateNotSubscribed;
                                       }
                                       self.subscriptionVerificationState = SubscriptionVerificationStateIdle;
                                   }
                                   
                                   if ([self.subscriptionValid boolValue] && self.currentState == InAppStoreStatePurchasingSubscription)
                                   {
                                       [self performCompletionBlock];
                                       self.currentState = InAppStoreStateIdle;
                                   }
                                   else if (self.currentState == InAppStoreStatePurchasingSubscription)
                                   {
                                       [self performFailureBlockWithError:nil];
                                       self.currentState = InAppStoreStateIdle;
                                   }
                                   
                               }];
        
//        NSLog(@"\n\n\n");

    }
}

#pragma mark - accessors synced with defaults
- (NSData*)subscriptionReceiptData
{
    if (!_subscriptionReceiptData){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
        _subscriptionReceiptData = [defaults valueForKey:IASSubscriptionReceiptDataKey];
    }
    return _subscriptionReceiptData;
}

- (void)setSubscriptionReceiptData:(NSData *)subscriptionReceiptData
{
    if (subscriptionReceiptData != _subscriptionReceiptData) {
        [self willChangeValueForKey:@"subscriptionReceiptData"];
        _subscriptionReceiptData = subscriptionReceiptData;
 
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:_subscriptionReceiptData forKey:IASSubscriptionReceiptDataKey];
        [defaults synchronize];
        
        [self didChangeValueForKey:@"subscriptionReceiptData"];
    }
}

- (NSDate*)subscriptionExpirationDate
{
    if (!_subscriptionExpirationDate){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _subscriptionExpirationDate = [defaults valueForKey:IASSubscriptionExpirationDateKey];
    }
    return _subscriptionExpirationDate;
}

- (void)setSubscriptionExpirationDate:(NSDate *)subscriptionExpirationDate
{
    if (subscriptionExpirationDate != _subscriptionExpirationDate) {
        [self willChangeValueForKey:@"subscriptionExpirationDate"];
        _subscriptionExpirationDate = subscriptionExpirationDate;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:_subscriptionExpirationDate forKey:IASSubscriptionExpirationDateKey];
        [defaults synchronize];
        
        [self didChangeValueForKey:@"subscriptionExpirationDate"];
    }
}

- (NSDate*)subscriptionLastVerifiedDate
{
    if (!_subscriptionLastVerifiedDate){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _subscriptionLastVerifiedDate = [defaults valueForKey:IASSubscriptionLastVerifiedDateKey];
    }
    return _subscriptionLastVerifiedDate;
}

- (void)setSubscriptionLastVerifiedDate:(NSDate *)subscriptionLastVerifiedDate
{
    if (subscriptionLastVerifiedDate != _subscriptionLastVerifiedDate) {
        [self willChangeValueForKey:@"subscriptionLastVerifiedDate"];
        _subscriptionLastVerifiedDate = subscriptionLastVerifiedDate;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:_subscriptionLastVerifiedDate forKey:IASSubscriptionLastVerifiedDateKey];
        [defaults synchronize];
        
        [self didChangeValueForKey:@"subscriptionLastVerifiedDate"];
    }
}

- (NSNumber*)subscriptionValid
{
    if (!_subscriptionValid) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _subscriptionValid = [defaults valueForKey:IASSubscriptionValidKey];
    }
    
    return _subscriptionValid;
}

- (void)setSubscriptionValid:(NSNumber*)subscriptionValid
{
    if (subscriptionValid != _subscriptionValid) {
        [self willChangeValueForKey:@"subscriptionValid"];
        _subscriptionValid = subscriptionValid;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:_subscriptionValid forKey:IASSubscriptionValidKey];
        [defaults synchronize];
        
        [self didChangeValueForKey:@"subscriptionValid"];
    }
}
#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    
    if (self.storeCacheState != StoreCacheStateUpdating)
        return;

//    NSLog(@"response.products: %@", response.products);

    if (!response.products.count) {
        self.storeCacheState = StoreCacheStateDirty;
//        NSLog(@"product request no products");
        return;
    }
    

//    NSLog(@"response.products.count: %d", response.products.count);
    
    for (SKProduct *p in response.products) {
//        NSLog(@"====================");
//        NSLog(@"productIdentifier: %@", p.productIdentifier);
//        NSLog(@"====================");
        
    }
    
//    NSLog(@"TODAS AS EDIÇÕES: %@", _issuesProductIdentifiers);
//    NSLog(@"TODAS AS ASSINATURAS: %@", _subscriptionProductIdentifiers);
    
    NSPredicate *newSubscriptionsPredicate = [NSPredicate predicateWithFormat:@"NOT self.productIdentifier IN %@", _issuesProductIdentifiers];
    NSPredicate *newIssuesPredicate = [NSPredicate predicateWithFormat:@"NOT self.productIdentifier IN %@", _subscriptionProductIdentifiers];
    
    NSArray *newSubscriptions = [response.products filteredArrayUsingPredicate:newSubscriptionsPredicate];
    NSArray *newIssues = [response.products filteredArrayUsingPredicate:newIssuesPredicate];
    
//    NSLog(@"Assinaturas atualizadas:");
    for (SKProduct *s in newSubscriptions) {
//        NSLog(@"newSubscription : %@", s.productIdentifier);
    }
//    NSLog(@"Edições atualizadas:");
    for (SKProduct *e in newIssues) {
//        NSLog(@"newIssue : %@", e.productIdentifier);
    }
    

    BOOL subscriptionsUpdated = NO;
    BOOL issuesUpdated = NO;
    
    if (_subscriptionProducts.count != newSubscriptions.count) {
        subscriptionsUpdated = YES;
        _subscriptionProducts = newSubscriptions;
    }
//    NSLog(@"_subscriptionProducts.count: %d", _subscriptionProducts.count);
//    NSLog(@"newSubscriptions.count: %d", newSubscriptions.count);
//    NSLog(@"subscriptionsUpdated? %d", subscriptionsUpdated);
    
    if (_issueProducts.count != newIssues.count) {
        issuesUpdated = YES;
        _issueProducts = newIssues;
    }
//    NSLog(@"_issueProducts: %d", _issueProducts.count);
//    NSLog(@"newIssues: %d", newIssues.count);
//    NSLog(@"issuesUpdated? %d", issuesUpdated);
    
    if (issuesUpdated || subscriptionsUpdated) {
        _allProducts = [_subscriptionProducts arrayByAddingObjectsFromArray:_issueProducts];
        [self storeCacheUpdated];
    }
    


    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.storeCacheState != StoreCacheStateUpdating)
        return;
    
    self.storeCacheState = StoreCacheStateDirty;
//#warning log this
    NSLog(@"SKRequest failed with error %@", error);
}

#pragma mark - SKPaymentQueueTransactionObserver

- (BOOL)purchaseIsSubscription:(SKPaymentTransaction *)purchase
{
    NSUInteger index = [_subscriptionProductIdentifiers indexOfObject:purchase.payment.productIdentifier];
    return index != NSNotFound;
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (_currentState == InAppStoreStateRestoring) {
        return;
    }
    
    NSArray *purchasedTransactions;
    NSArray *purchasingTransactions;
    NSArray *failedTransactions;
    NSArray *restoredTransactions;
    
    purchasedTransactions = [transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionState == %d", SKPaymentTransactionStatePurchased]];
    purchasingTransactions = [transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionState == %d", SKPaymentTransactionStatePurchasing]];
    failedTransactions = [transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionState == %d", SKPaymentTransactionStateFailed]];
    restoredTransactions = [transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionState == %d", SKPaymentTransactionStateRestored]];
    
    if (purchasingTransactions.count) {
        NSLog(@"Skipped %d transactions - SKPaymentTransactionStatePurchasing", purchasingTransactions.count);
    }
    
    if (purchasedTransactions.count) {
        NSLog(@"Skipped %d transactions - SKPaymentTransactionStatePurchased", purchasedTransactions.count);
        switch (self.currentState) {
            case InAppStoreStatePurchasingIssue:  {
                
                SKPaymentTransaction *latestTransaction = nil;
                for (SKPaymentTransaction *transaction in purchasedTransactions) {
                        if (![self purchaseIsSubscription:transaction]){
                        Issue *issue = [Issue MR_findFirstByAttribute:@"productIdentifier" withValue:transaction.payment.productIdentifier];
                        if (issue) {
                            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                                Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
                                localIssue.purchasedValue = YES;
                                localIssue.receiptData = transaction.transactionReceipt;
                            }];
                        }
                        continue;
                    }
                    if (latestTransaction == nil) {
                        latestTransaction = transaction;
                        continue;
                    }
                    
                    if ([latestTransaction.transactionDate compare:transaction.transactionDate] == NSOrderedAscending) {
                        latestTransaction = transaction;
                    }
                    
                }
                
                if (latestTransaction) {
                    self.subscriptionReceiptData = latestTransaction.transactionReceipt;
                    [self verifySubscription];
                }
                
                [self performCompletionBlock];
            }
                break;
            case InAppStoreStatePurchasingSubscription: {
                
                SKPaymentTransaction *latestTransaction = nil;
                for (SKPaymentTransaction *transaction in purchasedTransactions) {
                    if (![self purchaseIsSubscription:transaction]){
                        Issue *issue = [Issue MR_findFirstByAttribute:@"productIdentifier" withValue:transaction.payment.productIdentifier];
                        if (issue) {
                            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                                Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
                                localIssue.purchasedValue = YES;
                                localIssue.receiptData = transaction.transactionReceipt;
                            }];
                        }
                        continue;
                    }
                    if (latestTransaction == nil) {
                        latestTransaction = transaction;
                        continue;
                    }
                    
                    if ([latestTransaction.transactionDate compare:transaction.transactionDate] == NSOrderedAscending) {
                        latestTransaction = transaction;
                    }
                    
                }
                
                if (latestTransaction) {
                    self.subscriptionReceiptData = latestTransaction.transactionReceipt;
                    [self verifySubscription];
                }
            }
                break;
                
            default:
                break;
        }
        for (SKPaymentTransaction *transaction in purchasedTransactions) {
            [_queue finishTransaction:transaction];
        }
    }
    
    if (failedTransactions.count) {
        NSLog(@"Skipped %d transactions - SKPaymentTransactionStateFailed", failedTransactions.count);
        switch (self.currentState) {
            case InAppStoreStatePurchasingIssue:
            case InAppStoreStatePurchasingSubscription: {
                [self performFailureBlockWithError:nil];
            }
                break;
                
            default:
                break;
        }
        for (SKPaymentTransaction *transaction in failedTransactions) {
            [_queue finishTransaction:transaction];
        }

    }
    
    if (restoredTransactions.count) {
        NSLog(@"Skipped %d transactions - SKPaymentTransactionStateRestored", restoredTransactions.count);
        
        SKPaymentTransaction *latestTransaction = nil;
        for (SKPaymentTransaction *transaction in restoredTransactions) {
            if (![self purchaseIsSubscription:transaction]){
                Issue *issue = [Issue MR_findFirstByAttribute:@"productIdentifier" withValue:transaction.payment.productIdentifier];
                if (issue) {
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                        Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
                        localIssue.purchasedValue = YES;
                        localIssue.receiptData = transaction.transactionReceipt;
                    }];
                }
                continue;
            }
            if (latestTransaction == nil) {
                latestTransaction = transaction;
                continue;
            }
            
            if ([latestTransaction.transactionDate compare:transaction.transactionDate] == NSOrderedAscending) {
                latestTransaction = transaction;
            }
            
        }
        
        if (latestTransaction) {
            self.subscriptionReceiptData = latestTransaction.transactionReceipt;
            [self verifySubscription];
        }
        
        for (SKPaymentTransaction *transaction in restoredTransactions) {
            [_queue finishTransaction:transaction];
        }

    }
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"queue transactions for restore %@", queue.transactions);
    if (self.currentState != InAppStoreStateRestoring)
        return ;

    NSPredicate *subscriptionPredicate = [NSPredicate predicateWithFormat:@"self.payment.productIdentifier IN %@", _subscriptionProductIdentifiers];
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"self.payment.productIdentifier IN %@", _issuesProductIdentifiers];
    
    NSArray *subscriptionPurchases = [queue.transactions filteredArrayUsingPredicate:subscriptionPredicate];
    NSArray *itemPurchases = [queue.transactions filteredArrayUsingPredicate:itemPredicate];
    
    for (SKPaymentTransaction *transaction in itemPurchases) {
        Issue *issue = [Issue MR_findFirstByAttribute:@"productIdentifier" withValue:transaction.payment.productIdentifier];
        NSLog(@"restoring transaction for issue %@", issue.productIdentifier);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
            localIssue.purchasedValue = YES;
            NSLog(@"set to purchased %@, %d",issue.productIdentifier, issue.purchasedValue);
            issue.receiptData = transaction.transactionReceipt;
        }];
    }
    
    SKPaymentTransaction *latestTransaction = nil;
    
    for (SKPaymentTransaction *transaction in subscriptionPurchases) {
        if (latestTransaction == nil) {
            latestTransaction = transaction;
            continue;
        }
        
        if ([latestTransaction.transactionDate compare:transaction.transactionDate] == NSOrderedAscending) {
            latestTransaction = transaction;
        }
    }
    

    
    if (latestTransaction) {
        self.subscriptionReceiptData = latestTransaction.transactionReceipt;
        [self verifySubscription];
    }
    else {
        self.subscriptionState = SubscriptionStateNotSubscribed;
        self.subscriptionReceiptData = nil;
        self.subscriptionValid = nil;
        self.subscriptionLastVerifiedDate = nil;
        self.subscriptionExpirationDate = nil;
    }
    
    for (SKPaymentTransaction *transaction in subscriptionPurchases) {
        [_queue finishTransaction:transaction];
    }
    [self restoreComplete];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self restoreFailed:error];
}

@end
