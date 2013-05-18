//
//  RootViewController.h
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagazineRackViewController.h"
#import "MagazineDetailViewController.h"
#import "FPPopoverController.h"

@class CredentialStore;

@interface RootViewController : UIViewController <FPPopoverControllerDelegate>

@property (nonatomic, strong) CredentialStore *credentialStore;


@property (strong, nonatomic) MagazineRackViewController *magazineRackViewController;
@property (strong, nonatomic) MagazineDetailViewController *magazineDetailViewController;


- (IBAction)getThere:(id)sender;
- (IBAction)clearToken:(id)sender;

- (NSString *)getValueForKeyFromJsonObject:(NSString *)key jsonObject:(id)jsonObject;
- (void)tokenSaved:(NSNotification *)notification;
- (void)tokenExpiredProvidences:(NSNotification *)notification;



@end
