//
//  IssueManager.m
//  Reader
//
//  Created by  Basispress on 12/31/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "IssueManager.h"
#import <NewsstandKit/NewsstandKit.h>
#import "JSONKit.h"
#import "CoreData+MagicalRecord.h"
#import "InAppStore.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "CredentialStore.h"




NSString *ProductIdentifierKey = @"product_identifier";
NSString *NameKey = @"name";
NSString *CoverKey = @"cover";
NSString *PreviewsKey = @"data";
NSString *TOCKey = @"contents";
NSString *DateKey = @"created_at";
NSString *FreeKey = @"free";
NSString *FreeURLKey = @"url";
NSString *DescriptionKey = @"description";

static NSArray *_subscriptionOptions;

static IssueManager *_sharedInstance;

NSString * IssueManagerProgressNotification = @"com.reader.issueManager.downloadNotification";
NSString * IssueManagerFirstStartDownloadedAllNotification = @"com.reader.issueManger.postFirstStartNotification";

@implementation IssueManager
{
    BOOL printSubscriber;
}
+ (IssueManager*)sharedInstance
{
    if (!_sharedInstance) 
    @synchronized (self){
        _sharedInstance = [[IssueManager alloc] init];
        _subscriptionOptions = nil;
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
#pragma warning "TODO: Alterar para verificar se existe info antes de definir NO"
        self.credentialStore = [[CredentialStore alloc] init];
        
        /*[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenExpiredProvidences:) name:@"token-expired" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenSaved:) name:@"token-changed" object:nil];
        */
        printSubscriber = [self.credentialStore isLoggedIn];
    }
    
    return self;
}

- (NSArray*)subscriptionOptions
{
    return _subscriptionOptions;
}
- (void)update
{
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    NSURL *url = [NSURL URLWithString:[UPDATE_URL stringByAppendingString:[NSBundle mainBundle].bundleIdentifier]];
    
    NSLog(@"updatetURL :: url: %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *responseData, NSError*error) {
                               if (!error) {
                                   //NSLog(@"*** SEM ERRO");
                                   [self handleUpdateResponse:responseData];
                               }
                               else {
                                   //NSLog(@"*** COM ERRO: %@", [error description]);
                                   [self handleUpdateFailed:error];
                               }
                           }];
    
    [self resumeUnfinishedDownloads];
}


- (void)resumeUnfinishedDownloads
{
    NSLog(@"[%d] %s", __LINE__, __FUNCTION__);
    
    NSUInteger nkUnfinishedDownloads = 0;
    NKLibrary *library = [NKLibrary sharedLibrary];
    
    for (NKIssue *issue in library.issues) {
        for (NKAssetDownload *assetDownload in issue.downloadingAssets) {
            [assetDownload downloadWithDelegate:self];
            nkUnfinishedDownloads ++;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", assetDownload.URLRequest.URL.absoluteString];
            Asset *asset = [Asset MR_findFirstWithPredicate:predicate];
            if (asset) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                    Asset *localAsset = (Asset*)[localContext objectWithID:asset.objectID];
                    localAsset.issue.downloadingValue = YES;
                }];
            }
        }
    }
    
    NSLog(@"[%d] %s", __LINE__, __FUNCTION__);
    
    if (nkUnfinishedDownloads) {
                  NSLog(@"resumed nk downloads");
    }
    else {
        NSLog(@"[%d] %s", __LINE__, __FUNCTION__);
        NSArray *unfinishedDownloads = [Asset MR_findByAttribute:@"downloaded" withValue:@NO];
//        if (!unfinishedDownloads.count)
  //          unfinishedDownloads = [Asset MR_findByAttribute:@"downloaded" withValue:nil];
        NSLog(@"unfinished downloads %@", unfinishedDownloads);
        for (Asset *asset in unfinishedDownloads) {
            NKIssue *nkIssue = [library issueWithName:asset.issue.productIdentifier];
                        
            NSURL *url = [NSURL URLWithString:asset.url];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:request];

            
            [assetDownload downloadWithDelegate:self];
            NSLog(@"resumed download");
            
            if ([asset.type isEqualToString:AssetTypeDocument]) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                    Asset *localAsset = (Asset*)[localContext objectWithID:asset.objectID];
                    localAsset.issue.downloadingValue = YES;
                }];
            }
        }
    }
}
- (void)handleUpdateResponse:(NSData*)responseData
{
    //NSString* newStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"*** responseData: %@", newStr);
    
    NSDictionary *responseDictionary = [responseData objectFromJSONData];
    
    //NSLog(@"*** responseDictionary: %@", responseDictionary);
    
    NSArray *issuesArray = responseDictionary[@"issues"];
    NSArray *subscriptionsArray = responseDictionary[@"subscriptions"];
    
    NSMutableArray *issuesProductIdentifiers = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *subscriptionsProductIdentifiers = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *issue in issuesArray) {
        if ([issue[FreeKey] boolValue])
            continue;
        [issuesProductIdentifiers addObject:issue[@"product_identifier"]];
    }
    for (NSDictionary *subscription in subscriptionsArray) {
        [subscriptionsProductIdentifiers addObject:subscription[@"product_identifier"]];
    }
    
    _subscriptionOptions = responseDictionary[@"subscriptions"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:issuesProductIdentifiers forKey:@"com.reader.issueIdentifiers"];
    [defaults setObject:subscriptionsProductIdentifiers forKey:@"com.reader.subscriptionIdentifiers"];
    [defaults synchronize];
    
    
    
    NSMutableArray *newIssuesArray = [NSMutableArray arrayWithArray:issuesArray];
    NKLibrary *library = [NKLibrary sharedLibrary];
    
    for (NSDictionary *issueDictionary in issuesArray) {
        NKIssue *issue = [library issueWithName:issueDictionary[ProductIdentifierKey]];
        if (issue) {
            [newIssuesArray removeObject:issueDictionary];
        }
    }
    

    if (newIssuesArray.count) {
        BOOL isSubscribed;
        if (!FREE_APP) {
            // se a app não é free, ainda tenho que verificar se o usuário é assinante da impressa
            if (printSubscriber) {
                isSubscribed = YES;
            }
            else
            {
                isSubscribed = [InAppStore sharedInstance].subscriptionState == SubscriptionStateSubscribed;
            }
        }
        else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            isSubscribed = [defaults boolForKey:@"freeSubscriptionEnabled"];
        }
        
        for (NSDictionary *issueDictionary in newIssuesArray) {
            NSLog(@"montando como subscriber: %d", isSubscribed);
            
            [self addNewIssue:issueDictionary downloadEverything:isSubscribed];
        }
    }
}

- (void)addNewIssue:(NSDictionary*)issueDictionary downloadEverything:(BOOL)downloadEverything
{
    __block Issue *issue = [Issue MR_findFirstByAttribute:@"productIdentifier" withValue:issueDictionary[ProductIdentifierKey]];

    if (issue == nil) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            NSDate *date = [dateFormatter dateFromString:issueDictionary[DateKey]];
            
            issue = [Issue MR_createInContext:localContext];
            issue.productIdentifier = issueDictionary[ProductIdentifierKey];
            issue.name = issueDictionary[NameKey];
            issue.toc = [issueDictionary[TOCKey] JSONString];
            issue.stateValue = IssueStateAdded;
            issue.state = @(IssueStateAdded);
            issue.date = date;
            issue.issueDescription = issueDictionary[DescriptionKey];
            if (issueDictionary[FreeKey] != nil) {
                issue.freeValue  = [issueDictionary[FreeKey] boolValue];
//                Asset *asset = [Asset MR_createInContext:localContext];
//                asset.url = issueDictionary[FreeURLKey];
//                asset.downloaded = @NO;
//                asset.type = AssetTypeDocument;
//                asset.orderIndex = 0;
//                [issue addAssetsObject:asset];
            }

            
            Asset *asset = [Asset MR_createInContext:localContext];
            asset.url = issueDictionary[CoverKey];
            asset.downloaded = @NO;
            asset.type = AssetTypeCover;
            [issue addAssetsObject:asset];
    
            asset.orderIndex = 0;
            
            NSUInteger orderIndex = 0;
            
            for (NSString *url in issueDictionary[PreviewsKey]) {
                if (!url || [url isEqualToString:@""])
                    continue;
                Asset *asset = [Asset MR_createInContext:localContext];
                asset.url = url;
                asset.downloaded = @NO;
                asset.type = AssetTypePreview;
                [issue addAssetsObject:asset];
                asset.orderIndex = @(orderIndex++);
            }
            
        }];
        
        NKLibrary *library = [NKLibrary sharedLibrary];
        
        NKIssue *nkIssue = [library issueWithName:issue.productIdentifier];
        
        if (!nkIssue) {
            nkIssue = [library addIssueWithName:issue.productIdentifier date:issue.date];
        }
        
        for (Asset *asset in issue.assets) {
            if ([asset.type isEqualToString:AssetTypeDocument])
                continue;
            NSURL *url = [NSURL URLWithString:asset.url];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];

            NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:request];
            [assetDownload downloadWithDelegate:self];
        }
        
        if (downloadEverything)
            [self downloadDocumentForIssue:issue];
    }
}

- (void)downloadDocumentForIssue:(Issue*)iss
{
    __block Issue *issue = iss;
    NSString *productID = iss.productIdentifier;
    NSLog(@"Baixar revista com productIdentifier: %@", iss.productIdentifier);
    if (issue.downloadingValue)
    {
        NSLog(@"issue.downloadingValue já definido: ");
        return;
    }
    NSString *baseURL = [RECEIPT_URL stringByAppendingFormat:@"%@&",[NSBundle mainBundle].bundleIdentifier];
    // NSLog(@"baseURL: %@", baseURL);
    
    
    if (issue.purchasedValue) {
        NSLog(@"iissue.purchasedValue");
        NSString *base64Receipt = [issue.receiptData base64Encode];
        
                
        NSString *requestURLString = [NSString stringWithFormat:@"%@data=%@",baseURL, base64Receipt];
        NSLog(@"requestURLString: %@", requestURLString);

        
        NSURL *url = [NSURL URLWithString:requestURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   NSDictionary *responseDictionary = [data objectFromJSONData];
                                   NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   dataString =[dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                                   responseDictionary = [dataString objectFromJSONString];
//                                   NSLog(@"\n[%s]\n[%d]\nresponse dictionary %@", __FILE__, __LINE__, responseDictionary);
                                   if ([responseDictionary[@"status"] isEqualToString:@"ok"]) {
                                       NSString *downloadURL = responseDictionary[@"download_url"];
                                       [self downloadDocumentForIssue:iss withURL:downloadURL productID:productID];
                                   }
                               }];
    }
    else if ([self.credentialStore isLoggedIn]) // usuario não comprou mas está logado como assinante.
    {
        NSLog(@"usuário assinante da revista impressa!");
        NSString *printed = @"receipt";
        NSString *requestURLString = [NSString stringWithFormat:@"%@printed=%@&product_identifier=%@",baseURL, printed, productID];
//        NSLog(@"requestURLString: %@", requestURLString);
        NSURL *url = [NSURL URLWithString:requestURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   NSDictionary *responseDictionary = [data objectFromJSONData];
                                   NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   dataString =[dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                                   responseDictionary = [dataString objectFromJSONString];
//                                   NSLog(@"\n[%s]\n[%d]\nresponse dictionary %@", __FILE__, __LINE__, responseDictionary);
                                   if ([responseDictionary[@"status"] isEqualToString:@"ok"]) {
                                       NSString *downloadURL = responseDictionary[@"download_url"];
                                       [self downloadDocumentForIssue:iss withURL:downloadURL productID:productID];
                                   }
                               }];
    }
    else if ([InAppStore sharedInstance].subscriptionState == SubscriptionStateSubscribed) {
        
        NSLog(@"usuário assinante digital");
        
        NSString *base64Receipt = [[InAppStore sharedInstance].subscriptionReceiptData base64Encode];
        NSString *requestURLString = [NSString stringWithFormat:@"%@data=%@&product_identifier=%@",baseURL, base64Receipt, issue.productIdentifier];
        NSURL *url = [NSURL URLWithString:requestURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        NSLog(@"1 ***** URL: %@", url);
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   
//                                   NSDictionary *jsonPeople = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                   NSLog(@"***\nresponse description: %@\n***", jsonPeople);
                                   
                                   NSDictionary *responseDictionary = [data objectFromJSONData];
                                   NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   dataString =[dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                                   responseDictionary = [dataString objectFromJSONString];
                                   NSLog(@"\n[%s]\n[%d]\nresponse dictionary %@", __FILE__, __LINE__, responseDictionary);
                                   if ([responseDictionary[@"status"] isEqualToString:@"ok"]) {
                                       NSString *downloadURL = responseDictionary[@"download_url"];
                                       NSLog(@"! issue product id%@", issue.productIdentifier);
                                       [self downloadDocumentForIssue:iss withURL:downloadURL productID:productID];
                                   }
                               }];
    }
    else if (issue.freeValue) {
        NSLog(@"edição grátis!");
        NSString *requestURLString = [NSString stringWithFormat:@"%@product_identifier=%@",baseURL, issue.productIdentifier];
        NSURL *url = [NSURL URLWithString:requestURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSLog(@"URL para esta edição: %@", requestURLString);
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                   NSDictionary *responseDictionary = [data objectFromJSONData];
                                   NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   dataString =[dataString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                                   responseDictionary = [dataString objectFromJSONString];
                                   NSLog(@"\n[%s]\n[%d]\nresponse dictionary %@", __FILE__, __LINE__, responseDictionary);
                                   if ([responseDictionary[@"status"] isEqualToString:@"ok"]) {
                                       NSString *downloadURL = responseDictionary[@"download_url"];
                                       NSLog(@"! issue product id%@", issue.productIdentifier);
                                       [self downloadDocumentForIssue:iss withURL:downloadURL productID:productID];
                                   }
                               }];
//
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issue = %@ AND type = %@", issue, AssetTypeDocument];
//        Asset *asset = [Asset MR_findFirstWithPredicate:predicate];
//        [self downloadDocumentForIssue:issue withURL:asset.url productID:issue.productIdentifier];

    }

}

- (void)downloadDocumentForIssue:(Issue *)issue withURL:(NSString*)url productID:(NSString*)productID
{
    NSLog(@"got request to download document with url %@ %d", url, issue.downloadingValue);
    if (issue.downloadingValue)
        return;
    NSLog(@"passed if %@", issue.productIdentifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issue == %@ AND type == %@", issue, AssetTypeDocument];
    __block Asset *asset = [Asset MR_findFirstWithPredicate:predicate];
    NSLog(@"asset %@", asset);
    
    if (!asset) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            asset = [Asset MR_createInContext:localContext];
            Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
            asset.url = url;
            asset.issue = localIssue;
            asset.type = AssetTypeDocument;
            asset.downloadedValue = NO;
            
         
            localIssue.downloadingValue = YES;
        }];
    }
    else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            asset = (Asset*)[localContext objectWithID:asset.objectID];
            Issue *localIssue = (Issue*)[localContext objectWithID:issue.objectID];
            asset.downloadedValue = NO;
            asset.issue = localIssue;
            asset.url = url;
            localIssue.downloadingValue = YES;
        }];
    }
    
    NKLibrary *library = [NKLibrary sharedLibrary];
    NSLog(@"issue %@", issue);
    NSLog(@"issue %@", issue.productIdentifier);
    NSLog(@"product id %@", productID);
    NKIssue *nkIssue;
    if (issue.productIdentifier != nil)
        nkIssue =  [library issueWithName:issue.productIdentifier];
    else
        nkIssue = [library issueWithName:productID];
    NSLog(@"nkIssue %@", nkIssue);
    NSURL *downloadURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:request];
    [assetDownload downloadWithDelegate:self];
    NSLog(@"asset dowonload %@", assetDownload);
    NSLog(@"urlrequest %@", request);
    
}
- (void)handleUpdateFailed:(NSError*)error
{
    
}


#pragma mark - NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"did fail with error %@ \n\n %@", error, connection.originalRequest.URL.absoluteString);
}
- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSString *absoluteString = connection.originalRequest.URL.absoluteString;
    Asset *asset = [Asset MR_findFirstByAttribute:@"url" withValue:absoluteString];
    if (![asset.type isEqualToString:AssetTypeDocument])
        return;
    float progress = (float)totalBytesWritten / (float)expectedTotalBytes;
    
    NSDictionary *userInfo = @{@"progress" : @(progress), @"asset":asset};
    NSLog(@"progress %f", progress);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:IssueManagerProgressNotification object:self userInfo:userInfo];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSString *absoluteString = connection.originalRequest.URL.absoluteString;
    Asset *asset = [Asset MR_findFirstByAttribute:@"url" withValue:absoluteString];
    
    if (![asset.type isEqualToString:AssetTypeDocument])
        return;
    float progress = (float)totalBytesWritten / (float)expectedTotalBytes;
    
    NSDictionary *userInfo = @{@"progress" : @(progress), @"asset":asset};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:IssueManagerProgressNotification object:self userInfo:userInfo];
    
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        NSString *absoluteString = connection.originalRequest.URL.absoluteString;
        
        Asset *asset = [Asset MR_findFirstByAttribute:@"url" withValue:absoluteString inContext:localContext];
     
        
        Issue *issue = asset.issue;
        
        NKLibrary *library = [NKLibrary sharedLibrary];
        NKIssue *nkIssue = [library issueWithName:issue.productIdentifier];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.%@.%d.%@", issue.productIdentifier, asset.type,asset.orderIndex.intValue, destinationURL.pathExtension];
        
        NSLog(@"arquivo no download: %@", fileName);
        
        NSURL *fileURL = [nkIssue.contentURL URLByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL moved;
        NSError *error = nil;
        moved = [fileManager moveItemAtURL:destinationURL toURL:fileURL error:&error];
        if (moved) {
            asset.downloaded = @YES;
            asset.filePath = fileURL.path;
        }
        else {
            NSLog(@"this really shouldn't have happened %@", error);
            asset.downloaded = @YES;
            asset.filePath = fileURL.path;
        }
        
        NSUInteger assetsLeftToDownload = 0;
        
        BOOL documentDownloaded = NO;
        for (asset in issue.assets) {
            if (!asset.downloadedValue && ![asset.type isEqualToString:AssetTypeDocument]) {
                assetsLeftToDownload ++;
            }
            if ([asset.type isEqualToString:AssetTypeDocument] && asset.downloadedValue) {
                documentDownloaded = YES;
            }
        }
        
        if (!assetsLeftToDownload) {
            issue.stateValue = IssueStateReadyForDisplayInShelf;
//            Asset *coverAsset = [Asset MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND issue == %@", AssetTypeCover, issue]];
//            Issue *latestIssue = [Issue MR_findAllSortedBy:@"date" ascending:NO][0];
//            if ([issue.objectID isEqual:latestIssue.objectID]) {
//                UIImage *image = [UIImage imageWithContentsOfFile:coverAsset.filePath];
//                NSLog(@"image %@", image);
//                [[UIApplication sharedApplication] setNewsstandIconImage:image];
//            }

        }
        if (!assetsLeftToDownload && documentDownloaded) {
            issue.downloadingValue = NO;
            issue.stateValue = IssueStateReadyForReading;
            
        }
        
        
        NSLog(@"download complete");
    }];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state != %d AND state != %d", IssueStateReadyForReading, IssueStateReadyForDisplayInShelf];
    NSArray *unfinishedIssues = [Issue MR_findAllWithPredicate:predicate];
    NSArray *allIssues = [Issue MR_findAll];
    if (allIssues.count && unfinishedIssues.count == 0) {
        if ([defaults boolForKey:@"firstLaunch"]) {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [defaults setBool:NO forKey:@"firstLaunch"];
            [defaults synchronize];
            [center postNotificationName:IssueManagerFirstStartDownloadedAllNotification object:self];
        }
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate setCoverImage];
    }
    
}
@end
