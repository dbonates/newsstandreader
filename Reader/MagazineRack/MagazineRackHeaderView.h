//
//  MagazineRackHeaderView.h
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CredentialStore;
@class MagazineRackViewController;

@interface MagazineRackHeaderView : UICollectionReusableView

@property (nonatomic, strong) CredentialStore *credentialStore;

@property (nonatomic, readonly) UIButton *restoreButton;
@property (nonatomic, readonly) UIButton *subscribeButton;

@property (nonatomic, strong) MagazineRackViewController *parentViewController;


@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)getThere:(id)sender;
- (IBAction)clearToken:(id)sender;

- (NSString *)getValueForKeyFromJsonObject:(NSString *)key jsonObject:(id)jsonObject;
- (void)tokenSaved:(NSNotification *)notification;
- (void)tokenExpiredProvidences:(NSNotification *)notification;

@end
