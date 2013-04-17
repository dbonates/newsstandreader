//
//  IssueManager.h
//  Reader
//
//  Created by  Basispress.com on 12/31/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Issue.h"
#import "Asset.h"
extern NSString * IssueManagerProgressNotification;
extern NSString * IssueManagerFirstStartDownloadedAllNotification;

@class CredentialStore;

@interface IssueManager : NSObject <NSURLConnectionDownloadDelegate>

@property (nonatomic, strong) CredentialStore *credentialStore;


+ (IssueManager*)sharedInstance;

/*
- update checks with the server if there are new issues. If there are new issues it will download the cover and preview assets. If the user is subscribed it will make an additional call to -downloadDocumentForIssue: to download the document too.
*/
- (void)update;
/*
- downloadDocumentForIssue: downloads the document asset for the issue if the issue is purchased or the user is subscribed
 */
- (void)downloadDocumentForIssue:(Issue*)issue;
/*
- subscriptionOptions returns an array of dictionaries containing the subscription options received from the server.
 The keys used for accessing the info in the dictionaries are "name" and "product_identifier".
 */
- (NSArray*)subscriptionOptions;




@end
